### PRII - Data preparation script ###
# Jan Müldner
# Wageningen University & Research
# 2026/2027
# PRII to be set as working directory

# This script identifies AOH rasters relevant by pairing them to the sci_name of Threatened Mammals subset. It further
# prepares those by clipping the AOH extent to the ROI, and saving into the intermediate directory.


# Sci_names as list obtained from Threatened Mammals


# FN that reads AOH, reprojects to study CRS, clips, and saves to intermediate. Does this iteratively to prevent
# RAM going too high up.