### PRII - Data preparation script - R ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# Load packages
library(sf)
library(terra)
library(rnaturalearth)




# ---- Derive African continent boundary ----
getAfricanBoundary <- function() {
  
  # Acquire country boundaries (rnaturalearth package)
  Africa_countries <- ne_countries(continent = "Africa", returnclass = "sf")

  # Transform to study CRS
  Africa_countries_54009 <- st_transform(Africa_countries, study_crs)

# Derive continental boundary (make geometry valid and dissolve countries)
Africa_boundary <- st_union(st_make_valid(Africa_countries_54009))

return(Africa_boundary)
}



# ---- Derive region of interest (ROI) ----
# Sources:https://r-spatial.github.io/sf/reference/geos_combine.html, https://r-spatial.github.io/sf/reference/geos_unary.html?q=st_convex_hull#ref-usage

derive_roi <- function(roads, buffering_distance) {
  # Function that uses RRE to construct study area geometry (with adjustable buffering distance)

  # Dissolve road geometries into single geometry
  roads_dissolved <- st_union(x = roads)

  # Apply convex hull to form min bounding geometry
  ROI_convexed <- st_convex_hull(roads_dissolved)

  # Buffer geometry outwards to include nearby areas from edge roads
  ROI_buffered <- st_buffer(ROI_convexed, dist = buffering_distance)

  # Use getAfricanBoundary to define continental geom
  Africa <- getAfricanBoundary()

  # Clip to continental Africa to exclude Gulf of Guinea (water, islands)
  ROI_final <- st_intersection(ROI_buffered, Africa)

  return(ROI_final)
}




# ---- Save ROI to disk ----
save_roi <- function(roi) {
  # This function will save the geometry of the ROI to disk (data) since it will be used throughout the study

  st_write(roi, "intermediate/ROI.gpkg", driver = "GPKG", delete_dsn = TRUE)
}

# Run the function and have it create a global variable for the ROI (will be used repeatedly)
ROI <- derive_roi(recent_roads, buffering_distance = 50000)
save_roi(ROI)

# ---- Clipping the datasets to the ROI ----

# Function to clip the dataset (will take the dataset as input)

clip_data <- function(data_to_be_clipped) {
  
  # Call function to get ROI with 50 km, and save it to disk
  clip_extent <- ROI

}
