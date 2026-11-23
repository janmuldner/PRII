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
# Reads in dataset and handles reprojection simultaneously
loadData <- function(file) {
  st_transform(st_read(file), study_crs)
}

# ---- FN: CLIP DATASETS TO ROI AND WRITE TO INTERMEDIATE ----
# Function that clips a dataset to the ROI and writes output as GPKG into intermediate directory.

clipData <- function(data_to_be_clipped, exfile) {
  
  # Clip dataset to the extent
  clipped <- st_intersection(data_to_be_clipped, ROI)

  # Create dir in between in case some dataset requires one (commented out for now)
    # (like ifl for IFLs - it will literally construct a new dir in between if needed. Will still work for simple exfile names which are put into intermediate directly)
    #dirname() does the magic by extracting the path
  #dir.create(dirname(paste0("intermediate/", exfile)), recursive = TRUE, showWarnings = FALSE)

  # Save output as GPKG (#intermediate dir set)
  st_write(clipped, paste0("intermediate/", exfile, ".gpkg"), driver = "GPKG", delete_layer = TRUE)
}








## DATA PREPARATION - ALL VECTOR DATASETS ##

# ---- READ IN DATASETS, REPROJECT ----
recent_roads <- loadData("data/road_expansion/forestroads_afr_2019-01_2025-12.shp")
concessions <- loadData("data/concessions/OFAC_merged_concessions_no_overlaps_MW_industrial_singlepart_gt1km2.shp")
ifl_2016 <- loadData("data/ifl/ifl_2016.gpkg")
ifl_2020 <- loadData("data/ifl/ifl_2020.gpkg")
ifl_2025 <- loadData("data/ifl/ifl_2025.gpkg")
iucn <- loadData("data/iucn/RQ1_Phase_I.gpkg") # has to be put in data dir manually (IUCN requires registered user)



# ---- PREPARING ROAD EXPANSION DATA ----
clipData(recent_roads, "forest_roads") # For the recent roads, this is redundant, but still useful if anything changes in the future (CRS and ROI conditions already met)


# ---- PREPARING CONCESSION DATA ---- # Concessions do meet CRS and ROI, but contain invalid geometries
# Repair self-intersecting rings which occur on many of these poylgons
concessions <- st_make_valid(concessions)
# Clip & write to int.
clipData(concessions, "concessions")


# ---- PREPARING IFL DATA ----
# Clip each individually to keep them separate (rbind could be used, but unnecessary)
clipData(ifl_2016, "ifl_2016")
clipData(ifl_2020, "ifl_2020")
clipData(ifl_2025, "ifl_2025")


# ---- PREPARING IUCN DATA (THREATENED MAMMALS SUBSET) ----
# (Phase II of RQ1)

# Removing all "presence" polygons other than Extant or Possibly extant (1, 3)
  # initially, Phase I comes with 264 unique species and 994 rows
iucn_removed_presence <- iucn[iucn$presence %in% c(1,3), ] # note: this step removed 110 rows (multipolygons)

# Fix geometries for the IUCN subset (3 self-intersections)
iucn_valid <- st_make_valid(iucn_removed_presence)

# Clipping to ROI, thus obtaining final subset
clipData(iucn_valid, "threatened_mammals")








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
