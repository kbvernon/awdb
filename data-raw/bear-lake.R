## code to prepare `bear-lake` dataset goes here

# just an arbitrary box around bear lake that catches some
# SNOTEL network stations
bear_lake <- sf::st_bbox(
  c(
    xmin = -111.78018123253392,
    ymin = 41.61717091518987,
    xmax = -110.84089305248634,
    ymax = 42.432769736865424
  ),
  crs = 4326
)

bear_lake <- sf::st_as_sfc(bear_lake)

usethis::use_data(bear_lake, overwrite = TRUE)
