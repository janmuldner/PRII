### PRII - Species richness from Threatened mammals script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# Load packages
library(sf)
library(terra)
library(dplyr)


myowngetSpeciesRichness <- function() {
  # First, read in the threatened mammals
  threatened_mammals <- st_read("intermediate/threatened_mammals.gpkg")

  # Now dissolve those per sci_name in order to occupy each row with only one shared geometry of species (will combine presence 1 and 3)
  threatened_mammals_dissolved <- summarise(
    group_by(threatened_mammals, sci_name),
    geom = st_union(geom)
  )

  # Load in the grid
  empty_grid <- getGrid()

  # Fill grid layer values with how many species ranges overlap each cell

}






getSpeciesRichness <- function() {

  # First, read in the threatened mammals
  threatened_mammals <- st_read("intermediate/threatened_mammals.gpkg")

  # Dissolve ranges by species name
  threatened_mammals_dissolved <- summarise(
    group_by(threatened_mammals, sci_name),
    geom = st_union(geom)
  )

  # Load in the empty grid
  empty_grid <- getGrid()

  # Convert raster grid cells to polygons
  grid_cells <- terra::as.polygons(
    empty_grid,
    values = FALSE,
    na.rm = FALSE,
    dissolve = FALSE
  )

  grid_sf <- st_as_sf(grid_cells)

  # Ensure both datasets have the same CRS
  threatened_mammals_dissolved <- st_transform(
    threatened_mammals_dissolved,
    st_crs(grid_sf)
  )

  # Count the number of species intersecting each grid cell
  species_per_cell <- lengths(
    st_intersects(grid_sf, threatened_mammals_dissolved)
  )

  # Add species richness values to the grid polygons
  grid_cells$richness <- species_per_cell

  # Rasterize the richness values using the original grid as template
  species_richness <- terra::rasterize(
    grid_cells,
    empty_grid,
    field = "richness",
    background = NA
  )

  species_richness[species_richness == 0] <- NA

  # Name the raster layer
  names(species_richness) <- "species_richness"

  # Save it to outputs
  writeRaster(species_richness, "output/species_richness.tif", overwrite = TRUE)

  return(species_richness)
}

SpeciesRichness <- getSpeciesRichness()
