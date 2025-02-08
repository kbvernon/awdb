#' Get Station Metadata From USDA NWCC AWDB
#'
#' Get station metadata from the USDA National Water and Climate Center Air and
#' Water Database REST API. Metadata is provided for station elements,
#' forecasts, and reservoirs.
#'
#' @inheritParams get_elements
#' @param metadata character vector, what station components to get metadata
#' for. Possible values include `element`, `forecast`, and `reservoir`.
#' @param as_sf boolean scalar, whether to return the data as an `sf` table.
#' Default is `FALSE`. Repeating the spatial data across each station element
#' and its time series can be costly.
#'
#' @return if `as_sf`, an `sf` table, otherwise a simple data.frame. The number
#' of rows depends on the number of stations and element parameters. Time series
#' data are included as a list column named `"values"`.
#'
#' @details
#' If you just want the locations, set all metadata options to `FALSE`.
#'
#' @export
#'
#' @name metadata
#'
#' @examples
#' # get element metadata for stations with snow water equivalent (WTEQ) and
#' # soil moisture percent (SMS:*, * = any depth) measurements
#' get_metadata(bear_lake, elements = c("WTEQ", "SMS:*"))
#'
#' # get just locations for stations with snow water equivalent measurements
#' get_metadata(pnw, elements = "WTEQ")
#'
get_metadata <- function(
  aoi,
  elements,
  metadata,
  awdb_options = set_options(),
  as_sf = FALSE
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"))
  check_character(elements, call = rlang::caller_call())
  check_character(metadata, call = rlang::caller_call())
  check_awdb_options(awdb_options)
  check_bool(as_sf, call = rlang::caller_call())

  rlang::arg_match(
    metadata,
    values = c(
      "element",
      "forecast",
      "reservoir"
    ),
    multiple = TRUE,
    error_call = rlang::caller_call()
  )

  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "stations"
  )

  return_forecast <- "forecast" %in% metadata
  return_reservoir <- "reservoir" %in% metadata
  return_element <- "element" %in% metadata

  json <- make_requests(
    endpoint,
    stations[["station_triplet"]],
    request_size,
    elements = elements,
    durations = awdb_options[["duration"]],
    returnForecastPointMetadata = return_forecast,
    returnReservoirMetadata = return_reservoir,
    returnStationElements = return_element
  )

  # parse vector of json strings
  df <- parse_station_metadataset_json(json)

  if (return_forecast && all(lengths(df[[""]]) == 0)) {}

  if (return_reservoir && all(lengths(df[[""]]) == 0)) {}

  if (return_element && all(lengths(df[["station_elements"]]) == 0)) {
    cli::cli_abort(
      "Failed to retrieve metadata for station elements.",
      call = rlang::caller_call()
    )
  }

  class(df[["station_elements"]]) <- "list"

  df
}
