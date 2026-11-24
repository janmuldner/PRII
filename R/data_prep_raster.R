### PRII - Raster data preparation script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# This script identifies AOH rasters relevant by pairing them to the sci_name of Threatened Mammals subset and
# obtaining them from the full AOH download dataset. It further prepares those by reprojecting the cells, 
# clipping their AOH extent to the ROI, and saving into the intermediate directory.


# Load packages
library(sf)
library(terra)

# Create empty directory for the AOH
if (!dir.exists("intermediate/aoh")) {
  dir.create("intermediate/aoh")
}

# Create a SpatVector of the ROI and latitude limits, so that it can be used for cropping and 
# masking in the loop (reused later, thus created out here)
# Source: https://rdrr.io/cran/terra/man/vect.html
ROI_SpatVect <- vect(ROI)
latitude_limits_SpatVect <- vect(latitude_limits)


# ---- FN: GET AOH FOR THREATENED MAMMALS ----
# This function creates a dataframe to gather sci_names of species from threatened mammals (iucn format) in one column,
# and relative paths to their corresponding AOH from /dat in the second column. It then iteratively takes
# the rasters one by one, does a series of cropping/reprojecting/masking, and writes the outputs one by one
# into the intermediate/aoh directory. The output should therefore be 124 prepared rasters.

getAOHRasters <- function() {

  # Load the threatened mammals subset
  threatened_mammals <- st_read("intermediate/threatened_mammals.gpkg")

  # Create dataframe for species names and their AOH relative paths
    speciesDF <- data.frame(sci_name = unique(threatened_mammals$sci_name), aoh_path = "", aoh_exists = TRUE) # 2 clmns, path left empty for now

    # Fill the aoh_path column with the corresponding paths
    speciesDF$aoh_path <- paste0("data/aoh/", speciesDF$sci_name, ".tif")

    # Replace the space with an underscore (final step for having correct relative paths)
    # Source:https://stackoverflow.com/questions/11936339/replace-specific-characters-within-strings
    speciesDF$aoh_path <- gsub(" ", "_", speciesDF$aoh_path)
  
    # Finally, check whether an AOH file actually exists (set to FALSE if not)
      # This should now produce all as TRUE, since some old/new scientific names had to be handled manually
      # Still useful for reproducibility (fn will run and simply flag the AOH that weren't found)
    for (i in 1:nrow(speciesDF)) {
      if (!file.exists(speciesDF$aoh_path[i])) {
          speciesDF$aoh_exists[i] <- FALSE  # all other remain set to TRUE
        }
    }

  
  # LOOP for eeach AOH raster (read, crop, reproject, crop, mask, write to /intermediate/aoh)

    for (i in 1:nrow(speciesDF)) { # ...for each item in the DF (1 through nrow, "i" will be the row index here)

      # Check if the AOH file actually exists first using if statement
      if (speciesDF$aoh_exists[i]) { # .. no need to compare it to TRUE since it is boolean
      
        # Read in raster (originally in WGS84)
        loop_object <- rast(speciesDF$aoh_path[i]) # Making a variable which will get removed at the end of each loop iteration

        # Crop to the latitude_limits broad rectangle (both are in WGS84) for saving computational expense
        loop_object <- crop(loop_object, latitude_limits_SpatVect)

        # Reproject to study CRS (now before cropping further)
        loop_object <- project(loop_object, study_crs, method = "near") # nearest neighbour resampling preserves categorical values

        # Crop to the RECTANGULAR extent of the ROI (that's how crop works..)
          # (both in 54009 at this point)
        loop_object <- crop(loop_object, ROI_SpatVect)

        # Mask values that are outside of ROI
        loop_object <- mask(loop_object, ROI_SpatVect) # gives NA to cells outside of ROI

        # Save to intermediate/aoh
        writeRaster(x = loop_object, filename = paste0("intermediate/aoh/", speciesDF$sci_name[i], ".tif"))
      }
    }
  return(speciesDF)
}





## RUN THE FUNCTION
speciesDF <- getAOHRasters() # call this so that the DF gets returned as global var., useful for inspecting missing AOH


# ---- CLEANUP -----
#rm(latitude_limits) - potentially, but they might still be usefl

excluded_mammals <- read.csv("data/Mammls_list_excluded.csv")
