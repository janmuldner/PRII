### PRII - Main (R) Script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

library(sf)
library(terra)

# Source scripts
source("R/data_download.R")
source("R/data_preparation.R")




# Load obtained files as global objects (later, this will probably be removed and main will 
# only do things like adjustable visualisations)
recent_roads <- st_read("data/road_expansion/forestroads_afr_2019-01_2025-12.shp")

# other datasets here will be loaded only after they are clipped (if ever)