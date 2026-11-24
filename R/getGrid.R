### PRII - Deriving default Grid ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# This grid will be used by both richness rasters.
# For now, it will be derived from the AOH rasters, matching their parameters (cell size, alignment..)
# Later, we could come up with our own grid with ideally coarses cell size.


# Load packages
library(sf)
library(terra)

getGrid <- function () {
  # Create empty raster covering the rectangular extent of ROI
  grid <- rast(
    ext(ROI_SpatVect),
    resolution = 20000,
    crs = study_crs
  )

  # Fill raster with NA values
  values(grid) <- NA

  return(grid)
}
