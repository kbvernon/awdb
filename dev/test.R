# get stations with WTEQ elements
get_stations(
  bear_lake,
  elements = "SMS:*",
  awdb_options = set_options(
    begin_date = "2015-06-01",
    end_date = "2015-06-03"
  )
)

get_elements(
  bear_lake,
  elements = "SMS:*",
  awdb_options = set_options(
    begin_date = "2015-06-01",
    end_date = "2015-06-03"
  )
) |> tidyr::unnest(element_values)

get_forecasts(bear_lake, elements = "REST")
get_stations(
  bear_lake,
  elements = "WTEQ",
  awdb_options = set_options(return_forecast_metadata = TRUE)
)[["forecast_metadata"]]
