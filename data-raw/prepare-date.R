## code to prepare datasets

library(dplyr)
library(readr)
library(sf)

# just an arbitrary box around bear lake that catches some
# SNOTEL network stations
bear_lake <- st_bbox(
  c(
    xmin = -111.78018123253392,
    ymin = 41.61717091518987,
    xmax = -110.84089305248634,
    ymax = 42.432769736865424
  ),
  crs = 4326
)

bear_lake <- st_as_sfc(bear_lake)

usethis::use_data(bear_lake, overwrite = TRUE)

# just an arbitrary box around the Cascades in Oregon
cascades <- st_bbox(
  c(
    xmin = -122.99948199993241,
    ymin = 43.486155156558915,
    xmax = -121.49548455805616,
    ymax = 44.37787452173634
  ),
  crs = 4326
)

cascades <- st_as_sfc(cascades)

usethis::use_data(cascades, overwrite = TRUE)

# element codes
# element_codes <- read_csv("data-raw/element-codes.csv") |>
#   select(code, name, unit) |>
#   arrange(code)

# usethis::use_data(element_codes, overwrite = TRUE)

# network codes
# network_codes <- read_csv("data-raw/network-codes.csv") |>
#   select(code, description) |>
#   arrange(code)

# usethis::use_data(network_codes, overwrite = TRUE)
