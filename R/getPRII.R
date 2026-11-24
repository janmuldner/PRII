### PRII - Script with PRII model ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

 # Create new raster from grid, one that will store the PRII value in a single layer
    # PRII has to accumulate to 0-1 score (0 = lowest, 1 = highest p. impact)
    # A formula has to be carried out here
      # Species richness has to be scaled (currently it is 1-56 approximately, scale those values to 0-1)
      # Formula takes that scaled value for each cell
      # IFL's are either present or not, this means that the previous value from the SR get multiplied by:
        # x 0.75 if no IFL prence
        # x 1 if IFL is present

# Load packages
library(sf)
library(terra)







getPRII <- function () {

  # Load grid 20x20km
  empty_grid <- getGrid()

  # Load species richness 20km
  SR_20km <- rast("output/species_richness_20000.tif")

  # Load 2016 IFL
  ifl_2016 <- st_read("intermediate/ifl_2016.gpkg")

  # Scale species richness to 0-1 using the maximum observed richness
  SRmax <- terra::global(SR_20km, "max", na.rm = TRUE)[1,1]

  SR_scaled <- SR_20km / SRmax

  # Create IFL presence raster (1 = IFL present, 0 = IFL absent)
  IFL_presence <- terra::rasterize(
    ifl_2016,
    empty_grid,
    field = 1,
    background = 0
  )

  # Create IFL weighting raster
  IFL_weight <- IFL_presence
  IFL_weight[IFL_weight == 0] <- 0.75

  # Calculate PRII
  PRII <- SR_scaled * IFL_weight

  # Name raster layer
  names(PRII) <- "PRII"

  writeRaster(PRII, "output/prii.tif", overwrite = TRUE)

  return(PRII)
}




# SOME STATS
PRII_v1 <- getPRII()

PRII_values <- terra::values(PRII_v1, na.rm = TRUE)

# Summary statistics
summary(PRII_values)

# Standard deviation
sd(PRII_values, na.rm = TRUE)

# Histogram
hist(
  PRII_values,
  breaks = 30,
  main = "Distribution of PRII values",
  xlab = "PRII",
  col = "lightblue"
)






getImpactfulRoads <- function() {

  # Load in roads
  roads <- st_read("intermediate/forest_roads.gpkg")

  # Run PRII v1
  PRII_v1 <- getPRII()

  # Identify cells with PRII > 0.8
  high_impact_cells <- terra::ifel(
    PRII_v1 > 0.8,
    1,
    NA
  )

  # Convert high-impact cells to polygons
  high_impact_cells <- terra::as.polygons(
    high_impact_cells,
    dissolve = FALSE,
    na.rm = TRUE
  )

  high_impact_cells_sf <- st_as_sf(high_impact_cells)

  # Ensure roads have the same CRS
  roads <- st_transform(
    roads,
    st_crs(high_impact_cells_sf)
  )

  # Identify road segments intersecting high-impact cells
  road_intersections <- st_intersects(
    roads,
    high_impact_cells_sf
  )

  # Extract NetworkIDs of intersecting road segments
  impactful_network_ids <- unique(
    roads$NetworkID[lengths(road_intersections) > 0]
  )

  # Keep all segments belonging to impactful networks
  impactful_roads <- roads %>%
    filter(NetworkID %in% impactful_network_ids)

  # Write to output
  st_write(impactful_roads, "output/impactful_roads.gpkg", driver = "GPKG", delete_layer = TRUE)

  return(impactful_roads)
}


# Run it
immpactful_roads <- getImpactfulRoads()
