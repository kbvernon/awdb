rextendr::document()

get_stations(
  bear_lake,
  elements = "*"
)

get_stations(cascades, elements = "RESC")

get_forecasts(cascades, elements = "SRVO")

lapply(
  c(
    "dcos",
    "durations",
    "elements",
    "forecastPeriods",
    "functions",
    "instruments",
    "networks",
    "physicalElements",
    "states",
    "units"
  ),
  get_references
)
