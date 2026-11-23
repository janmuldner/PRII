### PRII - Data download script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory


# This script downlaods the datasets used in the thesis project in their available raw format. Some datasets can not
# be accessed through URL and must be obtained manually. 
  # Downloadable through this script: RRE, IFL
  # Non-downlaodable: IUCN, AOH, and concessions datasets.
# Empty directories will be created for non-downlaodable datasets automatically inside of the data directory. The README
# specifies how to obtain the datasets which are not downloaded automatically and how to place them into their dirs.

# Load libraries
library(terra)
library(sf)


# Prepare general directories
if (!dir.exists("data")){
  dir.create("data")
}

if (!dir.exists("intermediate")){
  dir.create("intermediate")
}

if (!dir.exists("output")){
  dir.create("output")
}



# Preparing empty directories for non-downloadable data (IUCN, AOH, concessions)
if (!dir.exists("data/iucn")){
  dir.create("data/iucn")
}

if (!dir.exists("data/aoh")){
  dir.create("data/aoh")
}

if (!dir.exists("data/concessions")){
  dir.create("data/concessions")
}





# ---- DEFINE DATASET URLS ----
  # ..using a named list
  # This is done to reduce number of global variables
  # see data_sources.md for references of data used

dataset_urls <- list(
  # Recent road expansion dataset
  RRE = "https://zenodo.org/records/20201702/files/forestroads_afr_2019-01_2025-12.zip?download=1",
  # Intact Forest Landscapes datasets
  IFL_2016 = "https://intactforests.org/shp/IFL_2016.gpkg",
  IFL_2020 = "https://intactforests.org/shp/IFL_2020.gpkg",
  IFL_2025 = "https://intactforests.org/shp/IFL_2025.gpkg"
)



# ---- FN: DOWNLOAD INDIVIDUAL DATASETS  ----
downloadDatasets <- function(dataset_name, destfile) {

# Set timeout to 5 minutes (can be increased if needed later)
# Source: https://stat.ethz.ch/R-manual/R-devel/library/base/html/options.html
  options(timeout = 300)

# Avoid downloading twice
  if (!file.exists(destfile)) {

    dir.create(dirname(destfile), recursive = TRUE, showWarnings = FALSE) # Creates the dir necessary (from the destfile name)

    download.file(url=dataset_urls[[dataset_name]],
      destfile = destfile,
      method = "libcurl", # access websites
      mode = "wb") # ensures binary (good GIS practice)
    }
}


# ---- FN: DOWNLOAD ZIPPED DATASETS  ----
downloadZipDatasets <- function(dataset_name, destfile, exdir, final_file) {

# Avoid downloading twice by checking if the desired final_file exists (empty exdirs will not be considered as successful downlaod)
  if (!file.exists(final_file)) {

    download.file(url=dataset_urls[[dataset_name]], # takes in url from dataset_urls upon calling name of dataset (see names(dataset_urls))
      destfile = destfile, 
      method = "libcurl", # granting permission from websites
      mode = "wb") # binary handling (mostly for .zip files)
    
    unzip(destfile, exdir = exdir)

    file.remove(destfile)
  }
}



## DOWNLOADABLE DATASETS ##
# find out whether concessions could be added here as well

# ---- ROAD EXPANSION DATA ----
# Downloads both .shp and .gjson (.shp seems to be faster for processing)
downloadZipDatasets("RRE", "data/rre.zip", "data/road_expansion", "data/road_expansion/forestroads_afr_2019-01_2025-12.shp")

# ---- IFL ---- 
# The years obtained are (2016, 2020, 2025)
downloadDatasets("IFL_2016", "data/ifl/ifl_2016.gpkg")
downloadDatasets("IFL_2020", "data/ifl/ifl_2020.gpkg")
downloadDatasets("IFL_2025", "data/ifl/ifl_2025.gpkg")







## NON-DOWNLAODABLE DATASETS - WEBSITES REDIRECT OR THROW 403 ERRORS ##

# ---- IUCN RED LIST - PHASE I ---- 
# Based on conjunctive selection using IUCNs' Advanced Search
  # Autumn 2026 changes
  # Might have to be added manually (not API accessible)

# ---- AOH ---- - DOESN'T WORK AUTOMATICALLY DUE TO WEBSITE RESTRICTION
# The only raster dataset. Has to be split up per order
# As final_file, the name of the first .tif file obtained is inserted (this step could be enhanced later..)
#downloadZipDatasets("AOH_carnivora", "data/aoh_car.zip", "data/aoh", "data/aoh/Acinonyx_jubatus.tif")





# ---- CLEANUP -----
rm(dataset_urls) # not used outside of this script