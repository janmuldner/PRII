### PRII - Data preparation script - R ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII directory to be set as working directory

# Load packages
library(sf)
library(terra)
library(rnaturalearth)

# Read in datasets as (global) variables
recent_roads <- st_read("data/road_expansion/forestroads_afr_2019-01_2025-12.shp")




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