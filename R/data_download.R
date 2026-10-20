### PRII - Data download script - R ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# Load libraries
library(terra)
library(sf)

# Prepare directories
if (!dir.exists("data")){
  dir.create("data")
}

if (!dir.exists("intermediate")){
  dir.create("intermediate")
}

if (!dir.exists("output")){
  dir.create("output")
}


# ---- Define main CRS for study as global variable ----
study_crs <- "ESRI:54009"




# ---- Define URLs of datasets through a named list----
  # This is done to reduce number of global variables
  # see data_sources.md for references of data used

dataset_urls <- list(
  # Recent road expansion dataset
  RRE = "https://zenodo.org/records/20201702/files/forestroads_afr_2019-01_2025-12.zip?download=1",
  # IUCN Red List terrestrial mammals dataset
  IUCN_RL = "",
  # Intact Forest Landscapes dataset
  IFL = "",
  # Area of Habitat mammals dataset (might have to be split up into multiple)
  AOH = ""
)


# ---- Function to download the data using the named list ----
download.datasets <- function(dataset_name, destfile, exdir) {

# avoid downloading twice by checking if the desired directory exists (this could also be improved by adding a final_file as a means of checking to prevent empty exdirs being taken as successful downlaod)
  if (!dir.exists(exdir)) {

    download.file(url=dataset_urls[[dataset_name]], # takes in url from dataset_urls
      destfile = destfile, 
      method = "libcurl", # granting permission from websites
      mode = "wb") # binary handling (mostly for .zip files)
    
    unzip(destfile, exdir = exdir)

    file.remove(destfile)
  }
}

# Calling the function to download individual datasets
  # see names(dataset_urls) for available inputs

# Obtaining the recent road expansion dataset (RRE)
  # Downloads both .shp and .gjson (.shp seems to be faster for processing)
download.datasets("RRE", "data/rre.zip", "data/road_expansion")

# Obtaining the IUCN Red List terrestrial mammals dataset (IUCN_RL)

# Obtaining the Intact Forest Landscapes dataset (IFL)

# Obtaining the Area of Habitat mammals dataset 
  # (might have to be split up into multiple steps)
  # writeRaster() could be useful here to write it directly to disk



