### PRII - Data preparation script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# This script reads in downloaded datasets in the study CRS. It defines the ROI (study area),
# clips all datasets to it, and stores them in the "intermediate" directory in the GPKG format,
# along with the ROI.

# Load packages
library(sf)
library(terra)
library(rnaturalearth)




# Define CRS (Mollewide) for study as global variable
# Source: https://epsg.io/54009
study_crs <- "ESRI:54009"

# Read in downloaded datasets, convert their CRS
recent_roads <- st_transform(st_read("data/road_expansion/forestroads_afr_2019-01_2025-12.shp"), study_crs)
iucn <- st_transform(st_read("data/iucn/RQ1_Phase_I.gpkg"), study_crs)
#ifl <- 
#aoh <- 

# Define six countries of the Congo Basin
Congo_countries_vector <- c("Central African Republic", "Cameroon", "Equatorial Guinea", "Gabon", "Republic of the Congo", "Democratic Republic of the Congo")




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
      country = Congo_countries_vector,
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
# Run the function and have it create a global variable for the ROI (will be used repeatedly)
ROI <- deriveROI()





# ---- FN: CLIP DATASETS TO ROI AND WRITE TO INTERMEDIATE ----
# Function that clips a dataset to the ROI and writes output as GPKG into intermediate directory.

clipData <- function(data_to_be_clipped, exfile) {
  
  # Clip dataset to the extent
  clipped <- st_intersection(data_to_be_clipped, ROI)

  # Save output as GPKG  (intermediate dir)
  st_write(clipped, paste0(exfile, ".gpkg"), driver = "GPKG", delete_layer = TRUE)

}


# ---- PREPARING IUCN RQ1 SUBSET DATA ----
# Phase II of RQ1
  # Removing all "presence" polygons other than Extant or Possibly extant (1, 3)
  # Clipping to ROI

# Removing unwanted "presence" categories
iucn_removed_presence <- iucn[iucn$presence %in% c(1,3), ] # note: this stepped removed 110 rows (multipolygons)

# Clipping to ROI
threatened_mammals <- clipData(iucn_removed_presence, "intermediate/threatened_mammals")

threatened_mammals <- st_read("intermediate/threatened_mammals.gpkg")

# Creating dummy subset with leopard for testing
leopard_testing <- threatened_mammals[threatened_mammals$sci_name == "Panthera pardus", ]
plot(leopard_testing)
nrow(leopard_testing)
st_write(leopard_testing, "intermediate/test.gpkg", driver = "GPKG", delete_layer = TRUE)

leopard_aoh <- rast("data/Panthera_pardus.tif")
leopard_aoh <- project(leopard_aoh, study_crs)
leopard_aoh_clipped <- crop(leopard_aoh, ROI)
