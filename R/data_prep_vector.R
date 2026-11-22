### PRII - Data preparation script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# This script reads in downloaded vector datasets, projected into the study CRS. It clips all datasets to the ROI,
#  and writes them in the "intermediate" directory in the GPKG format, cleaning global variables.


# Load packages
library(sf)
library(terra)


## FN: LOAD DATA & TRANSFORM CRS ##
loadData <- function(file) {
  st_transform(st_read(file), study_crs)
}



# Read in downloaded datasets, convert their CRS
recent_roadss <- loadData("data/road_expansion/forestroads_afr_2019-01_2025-12.shp")
iucn <- loadData("data/iucn/RQ1_Phase_I.gpkg") # has to be put in data dir manually (IUCN requires registered user)
ifl_2016 <- loadData("data/ifl/ifl_2016.gpkg")
ifl_2020 <- loadData("data/ifl/ifl_2020.gpkg")
ifl_2025 <- loadData("data/ifl/ifl_2025.gpkg")
concessions <- loadData("data/concessions/OFAC_merged_concessions_no_overlaps_MW_industrial_singlepart_gt1km2.shp")




# ---- FN: CLIP DATASETS TO ROI AND WRITE TO INTERMEDIATE ----
# Function that clips a dataset to the ROI and writes output as GPKG into intermediate directory.

clipData <- function(data_to_be_clipped, exfile) {
  
  # Clip dataset to the extent
  clipped <- st_intersection(data_to_be_clipped, ROI)

  # Save output as GPKG  (intermediate dir)
  st_write(clipped, paste0(exfile, ".gpkg"), driver = "GPKG", delete_layer = TRUE)

}


# ---- PREPARING ROAD EXPANSION DATA ----
clipData(recent_roads, )

# ---- PREPARING IFL DATA ----
clipData(data_to_be_clipped = )

# ---- PREPARING AOH DATA ----





# ---- PREPARING IUCN DATA (THREATENED MAMMALS SUBSET) ----
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





# ---- CLEANUP -----
rm(iucn_removed_presence) # only used for obtaining Threatened Mammals from phase I
