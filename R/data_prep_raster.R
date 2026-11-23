### PRII - Data preparation script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# This script identifies AOH rasters relevant by pairing them to the sci_name of Threatened Mammals subset. It
# further prepares those by reprojecting the cells, clipping their AOH extent to the ROI,
# and saving into the intermediate directory.


# Loading the threatened mammals subset
threatened_mammals <- st_read("intermediate/threatened_mammals.gpkg")

# Deriving sci_names as list of species
species_list <- unique(threatened_mammals$sci_name)

# FN that reads AOH, reprojects to study CRS, clips, and saves to intermediate. Does this iteratively to prevent
# RAM going too high up.