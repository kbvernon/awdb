#' Get Station Forecasts
#'
#' Get station forecasts from the USDA National Water and Climate Center Air and
#' Water Database REST API. These will almost always be streamflow forecasts,
#' set with `elements = "SRVO"`, but some others are also available, albeit with
#' extremely limited spatial representation (see Details).
#'
#' @inheritParams get_elements
#'
#' @return if `as_sf`, an `sf` table, otherwise a simple data.frame. The number
#' of rows depends on the number of stations and element parameters. Time series
#' data are included as a list column named `"forecast_values"`.
#'
#' @details
#' This endpoint will accept the following query parameters via `set_options()`:
#' - `begin_publication_date`
#' - `end_publication_date`
#' - `exceedence_probabilities`
#' - `forecast_periods`
#'
#' The following can also be passed to filter stations:
#' - `station_names`
#' - `dco_codes`
#' - `county_names`
#' - `hucs`
#' - `active_only`
#'
#' You may also specify `networks` and `request_size`. The `networks` parameter
#' is used internally to build unique station triplet identifiers of the form
#' `station:state:network` which are then passed to the endpoint, so it serves
#' to filter stations to just those networks. The `request_size` parameter is
#' for handling rate limits, which are based on the number of elements - a hard
#' value to measure directly, so this parameter is more a rule of thumb than a
#' strict standard. If processing is slow for you, you may find experimenting
#' with this parameter useful.
#'
#' Note that the `duration` parameter is ignored - or, more precisely, it is set
#' to `NULL`.
#'
#' See `set_options()` for more details.
#'
#' ## Forecast Elements
#' Almost all forecasts are reported in `SRVO``, the adjusted streamflow set
#' which accounts for upstream operations such as reservoir operations and
#' diversions. `JDAY`, `RESC`, and `REST` are hardly used at all, mostly to
#' maintain historical forecasts made at Lake Tahoe (the birthplace of the snow
#' survey). In general, it's recommended to use `SRVO`.
#'
#' @export
#'
#' @examples
#' # get streamflow forecasts
#' get_forecasts(cascades, elements = "SRVO")
#'
get_forecasts <- function(
  aoi = NULL,
  elements,
  awdb_options = set_options(),
  as_sf = FALSE
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"), allow_null = TRUE)
  check_character(elements, call = rlang::caller_call())
  check_awdb_options(awdb_options)
  check_bool(as_sf, call = rlang::caller_call())

  awdb_options["duration"] <- list(NULL)

  stations <- filter_stations(
    aoi,
    elements = collapse(elements),
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
