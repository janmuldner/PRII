### PRII - Region of Interest (ROI) defining script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# This script sets the study CRS as a global variable and defines the ROI of the study used by for clipping datasets
# in consecutive scripts. The process is described in the function definition lower.

# Load packages
library(sf)
library(terra)
library(rnaturalearth)


## Define global variables ##

# Study CRS (World Mollweide, ESRI:54009)
# Source: https://epsg.io/54009
study_crs <- "ESRI:54009"

# Define six countries of the Congo Basin
congo_countries_vector <- c("Central African Republic", "Cameroon", "Equatorial Guinea", "Gabon", "Republic of the Congo", "Democratic Republic of the Congo")



# --- FN: DERIVE ROI & WRITE TO DISK ---
# Sources:
  # https://www.rdocumentation.org/packages/rnaturalearth/versions/1.2.0/topics/ne_countries
  # https://r-spatial.github.io/sf/reference/st_bbox.html

# This function derives the region of interest for the study by taking outer border of Congo Basin countries, defining
# latitude limits, clipping those together & buffering by 50km, and finally clipping to continental Africa to remove Bioko

deriveROI <- function() {

  ## Step 1: Get geometry of Congo Basin countries
  # Acquire country boundaries (rnaturalearth package)
  getGeometryCountries <- function() { 
    
    # Produces result in WGS84
    Congo_countries <- ne_countries(
      continent = "Africa",
      country = congo_countries_vector,
      returnclass = "sf")

    # Dissolve to retain only geometry
    CountriesBoundary <- st_union(Congo_countries)

    return(CountriesBoundary)
  }


  ## Step 2: Create latitude limits of 6°N and 6°S
  # Set a bbox with latitude limits (longitude restrained only to speed up processing)
  lat_bbox <- st_bbox(c(xmin = -20, ymin = -6, xmax = 55, ymax = 6), crs = st_crs(4326))
  
  # Convert that bbox to sf polygon
  latitude_limits <- st_as_sfc(lat_bbox)


  ## Step 3: Derive the boundaries of continental Africa
  getAfricanBoundary <- function() {
    
    # Acquire country boundaries of all African countries
    Africa_countries <- ne_countries(continent = "Africa", returnclass = "sf")

    # Transform to study CRS
    Africa_countries_54009 <- st_transform(Africa_countries, study_crs)

  # Derive continental boundary (make geometry valid and dissolve countries)
  Africa_boundary <- st_union(st_make_valid(Africa_countries_54009))

  return(Africa_boundary)
  }


  ## Step 4: Create ROI
  # Call fn to get Congo countries
  countries <- getGeometryCountries()

  # Clip countries to the latitude limits
  ROI <- st_intersection(countries, latitude_limits)

  # Project result to study CRS
  ROI_54009 <- st_transform(ROI, study_crs)

  # Buffer ROI by 50km to ensure outer AOH or range gets considered for outmost roads
  ROI_buffered <- st_buffer(ROI_54009, dist = 50000)

  # Call fn to get African boundary
  AfricanBoundary <- getAfricanBoundary()

  ROI_final <- st_intersection(ROI_buffered, AfricanBoundary)

  # Write ROI to disk
  st_write(ROI_final, dsn = "intermediate/ROI.gpkg", layer = "ROI", driver = "GPKG", delete_dsn = TRUE)

  return(ROI_final)
}



# --- DERIVING & SAVING ROI ---
# Run the function and have it create a global variable for the ROI (will be used repeatedly) + load ROI globally
ROI <- deriveROI()