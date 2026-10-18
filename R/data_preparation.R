### PRII - Data preparation script - R ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# # PRII directory to be set as working directory

# Load packages
library(sf)
library(terra)

## Deriving ROI of study ##

# Load recent expansion
roads <- st_read("data/forestroads_afr_2019-01_2025-12.shp")

# Derive info
print(st_crs(roads))
    # Note: World_Mollweide used as crs with ESRI:54009 code (it is an equal area crs)

# Dissolve all roads into single feature

# Fit minimum bounding geom using convex hull

# Buffer the result (approx. 50 km), this is final ROI for study


# Do quick visual check
plot()
