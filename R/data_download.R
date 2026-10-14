### PRII - Data download and preaparation script - R ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# # PRII directory must be set as working directory

# Load necessary libraries


# Define variables for directories
data_dir <- "data"
output_dir <- "output"

# Prepare directories
if (!dir.exists(data_dir)){
  dir.create(data_dir)
}

if (!dir.exists(output_dir)){
  dir.create(output_dir)
}


## Define variables for the URLs of datasets used ##
# All data are refferred in the data_sources.md file present in the main repository branch

# URL for the Recent road expansion dataset
RRE_url <- 

#URL for the IUCN Red List terrestrial mammals dataset
IUCNRL_url <- 

# URL for the Area of Habitat mammals dataset (might have to be split up into multiple)
AOH_url <- 

# URL for the Intact Forest Landscapes dataset
IFL_url <-