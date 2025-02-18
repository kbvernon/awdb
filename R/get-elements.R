#' Get Station Elements
#'
#' Get station elements from the  USDA National Water and Climate Center Air and
#' Water Database REST API. Elements are soil, snow, stream, and weather
#' variables measured at AWDB stations.
#'
#' @param aoi `sfc` POLYGON scalar, the area of interest used for performing
#' a spatial filter on available stations in `network`. If `NULL` (the default),
#' no spatial filter is performed.
#' @param elements character vector, abbreviations or codes for variables of
#' interest (e.g., "SMS" for "Soil Moisture Percent"). See Details for available
#' elements and codes.
#' @param awdb_options an `awdb_options` list with additional query parameters.
#' @param as_sf boolean scalar, whether to return the data as an `sf` table.
#' Default is `FALSE`. Repeating the spatial data across each station element
#' and its time series can be costly.
#'
#' @return if `as_sf`, an `sf` table, otherwise a simple data.frame. The number
#' of rows depends on the number of stations and element parameters. Time series
#' data are included as a list column named `"element_values"`.
#'
#' @details
#' This endpoint will accept the following query parameters via `set_options()`:
#' - `duration`
#' - `begin_date`
#' - `end_date`
#' - `period_reference`
#' - `central_tendency`
#' - `return_flags`
#' - `return_original_values`
#' - `return_suspect_values`
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
#' See `set_options()` for more details.
#'
#' @export
#'
#' @examples
#' get_elements(bear_lake, elements = "WTEQ")
#'
get_elements <- function(
  aoi = NULL,
  elements,
  awdb_options = set_options(),
  as_sf = FALSE
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"), allow_null = TRUE)
  check_character(elements, call = rlang::caller_call())
  check_awdb_options(awdb_options)
  check_bool(as_sf, rlang::caller_call())

  stations <- filter_stations(
    aoi,
    elements = collapse(elements),
    awdb_options
  )

  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "data"
  )

  json <- make_requests(
    endpoint,
    station_triplets = stations[["station_triplet"]],
    elements = collapse(elements),
    duration = awdb_options[["duration"]],
    beginDate = awdb_options[["begin_date"]],
    endDate = awdb_options[["end_date"]],
    request_size = awdb_options[["request_size"]]
  )

  # parse vector of json strings
  df <- parse_station_dataset_json(json)

  class(df[["element_values"]]) <- "list"

  if (as_sf) {
    df <- merge(
      stations[, c("station_triplet", "geometry")],
      df,
      by = "station_triplet"
    )
  }

  df
}
