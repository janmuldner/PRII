### PRII - Main R Script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII directory to be set as working directory

library(sf)
library(terra)

# Source scripts
source("R/data_download.R")
source("R/data_preparation.R")

# Call function to get ROI with 50 km
ROI <- derive_roi(recent_roads, buffering_distance = 50000)

# Call function that will save the ROI to disk
save_roi(ROI)
