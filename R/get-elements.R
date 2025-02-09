#' Get Element Data From Stations in the USDA NWCC AWDB
#'
#' Get element data for stations in the Air and Water Database REST API that
#' fall in area of interest.
#'
#' @param aoi `sfc` POLYGON scalar, the area of interest used for performing
#' a spatial filter on available stations in `network`.
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
#' TODO!
#'
#' @export
#'
#' @examples
#' get_elements(bear_lake, elements = "WTEQ")
#'
get_elements <- function(
  aoi,
  elements,
  awdb_options = set_options(),
  as_sf = FALSE
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"))
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
    stations[["station_triplet"]],
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
