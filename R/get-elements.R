#' Get Element Data From Stations in the USDA NWCC AWDB
#'
#' Get element data for stations in the Air and Water Database REST API that
#' fall in area of interest.
#'
#' @inheritParams get_stations
#' @param as_sf boolean scalar, whether to return the data as an `sf` table.
#' Default is `FALSE`. Repeating the spatial data across each station element
#' and its time series can be costly.
#'
#' @return if `as_sf`, an `sf` table, otherwise a simple data.frame. The number
#' of rows depends on the number of stations and element parameters. Time series
#' data are included as a list column named `"values"`.
#'
#' @export
#'
#' @examples
#' get_elements(bear_lake, elements = "WTEQ", networks = "SNTL")
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

  elements <- paste0(elements, collapse = ", ")

  stations <- filter_stations(
    aoi,
    elements,
    networks = awdb_options[["networks"]],
    durations = awdb_options[["duration"]]
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
    elements = elements,
    duration = awdb_options[["duration"]],
    beginDate = awdb_options[["begin_date"]],
    endDate = awdb_options[["end_date"]],
    request_size = awdb_options[["request_size"]]
  )

  # parse vector of json strings
  df <- parse_station_dataset_json(json)

  class(df[["values"]]) <- "list"

  if (as_sf) {
    df <- merge(
      stations[, c("station_triplet", "geometry")],
      df,
      by = "station_triplet"
    )
  }

  df
}
