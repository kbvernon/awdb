#' Get Station Forecasts From USDA NWCC AWDB
#'
#' Get station forecasts from the USDA National Water and Climate Center Air and
#' Water Database REST API.
#'
#' @inheritParams get_elements
#'
#' @return if `as_sf`, an `sf` table, otherwise a simple data.frame. The number
#' of rows depends on the number of stations and element parameters. Time series
#' data are included as a list column named `"forecast_values"`.
#'
#' @details
#' TODO!
#'
#' @export
#'
#' @examples
#' # get forecasts for snow water equivalent (WTEQ)
#' get_forecasts(bear_lake, elements = "WTEQ")
#'
get_forecasts <- function(
  aoi,
  elements,
  awdb_options = set_options(),
  as_sf = FALSE
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"))
  check_character(elements, call = rlang::caller_call())
  check_awdb_options(awdb_options)
  check_bool(as_sf, call = rlang::caller_call())

  stations <- filter_stations(
    aoi,
    elements = elements,
    awdb_options
  )

  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "forecasts"
  )

  # note: the query parameter for forecasts is "elementCodes," rather than
  # "elements," like it is for the other endpoints
  json <- make_requests(
    endpoint,
    stations[["station_triplet"]],
    elementCodes = collapse(elements),
    beginPublicationDate = awdb_options[["begin_publication_date"]],
    endPublicationDate = awdb_options[["end_publication_date"]],
    exceedenceProbabilities = awdb_options[["exceedence_probabilities"]],
    forecastPeriods = awdb_options[["forecast_periods"]],
    request_size = awdb_options[["request_size"]]
  )

  # parse vector of json strings
  df <- parse_station_forecast_set_json(json)

  class(df[["forecast_values"]]) <- "list"

  if (as_sf) {
    df <- merge(
      stations[, c("station_triplet", "geometry")],
      df,
      by = "station_triplet"
    )
  }

  df
}
