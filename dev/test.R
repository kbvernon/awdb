library(sf)

pnw <- sf::st_bbox(
  c(
    xmin = -123.9745334,
    ymin = 42.689170,
    xmax = -117.212106,
    ymax = 48.591128
  ),
  crs = 4326
)

pnw <- sf::st_as_sfc(pnw)

get_station_metadata(
  pnw,
  elements = c("WTEQ", "SMS:*"),
  return_element_metadata = TRUE
)

get_station_data(
  pnw,
  elements = c("WTEQ", "SMS:*"),
  begin_date = "2020-05-01",
  end_date = "2020-05-25"
)
