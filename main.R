### PRII - Main (R) Script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# It is advised to run line by line.

library(sf)
library(terra)

# Source scripts
source("R/data_download.R")
# BEFORE PROCEEDING, FOLLOW STEP X FROM README (otherwise will give an error for missing data)

source("R/data_prep_vector.R.R")
source("R/data_prep_raster.R")




# Load obtained files as global objects (later, this will probably be removed and main will 
# only do things like adjustable visualisations)
recent_roads <- st_read("data/road_expansion/forestroads_afr_2019-01_2025-12.shp")

# other datasets here will be loaded only after they are clipped (if ever)