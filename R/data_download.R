### PRII - Data download script - R ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# # PRII to be set as working directory

# NOTES:
  #

# Load libraries
library(terra)
library(sf)

# Prepare directories
if (!dir.exists("data")){
  dir.create("data")
}

if (!dir.exists("output")){
  dir.create("output")
}


## Define variables for the URLs of datasets used ##  (see data_sources.md for references)

# Recent road expansion dataset
RRE_url <- "https://zenodo.org/records/20201702/files/forestroads_afr_2019-01_2025-12.zip?download=1"
# IUCN Red List terrestrial mammals dataset
IUCNRL_url <- 
# Area of Habitat mammals dataset (might have to be split up into multiple)
AOH_url <- 
# Intact Forest Landscapes dataset
IFL_url <-


## Download to data directory ##
  
# Recent road expansion dataset (as .shp and .gejson, .shp seems to be much faster in further processing)
download.file(url = RRE_url, destfile = "data/road_expansion.zip", method = "libcurl", mode = "wb") # method for granting permission from website, mode for binary handling (since it is a .zip file)
unzip("data/road_expansion.zip", exdir = "data")
file.remove("data/road_expansion.zip")