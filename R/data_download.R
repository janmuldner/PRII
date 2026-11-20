### PRII - Data download script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory


# This script downlaods the datasets used in the thesis project in their available raw format.

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




# ---- DEFINE DATASET URLS ----
  # ..using a named list
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


# ---- FN: DOWNLOAD DATASETS  ----
downloadDatasets <- function(dataset_name, destfile, exdir) {

# avoid downloading twice by checking if the desired directory exists (this could also be improved by adding a final_file as a means of checking to prevent empty exdirs being taken as successful downlaod)
  if (!dir.exists(exdir)) {

    download.file(url=dataset_urls[[dataset_name]], # takes in url from dataset_urls upon calling name of dataset (see names(dataset_urls))
      destfile = destfile, 
      method = "libcurl", # granting permission from websites
      mode = "wb") # binary handling (mostly for .zip files)
    
    unzip(destfile, exdir = exdir)

    file.remove(destfile)
  }
}



# ---- DOWNLOADING DATASETS ----
# Road expansion dataset (RRE)
  # Downloads both .shp and .gjson (.shp seems to be faster for processing)
downloadDatasets("RRE", "data/rre.zip", "data/road_expansion")

# IUCN Red List terrestrial mammals dataset (IUCN_RL)
  # Autumn 2026 changes
  # 'generlaised' polygon attribute (to hide precise location of threatened taxon, or when data limited)

# Intact Forest Landscapes dataset (IFL)
  # All years will be obtained

# Area of Habitat mammals dataset 
  # Might be possible through IUCN now
  # (might have to be split up into multiple steps)
  # writeRaster() could be useful here to write it directly to disk



