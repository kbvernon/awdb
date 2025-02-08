#' Get Stations From USDA NWCC AWDB in Area of Interest
#'
#' Get stations and their coordinates from the Air and Water Database REST API
#' that fall in area of interest.
#'
#' @param aoi `sfc` POLYGON scalar, the area of interest used for performing
#' a spatial filter on available stations in `network`.
#' @param elements character vector, abbreviations or codes for variables of
#' interest (e.g., "SMS" for "Soil Moisture Percent"). See Details for available
#' elements and codes.
#' @param awdb_options an `awdb_options` list with additional query parameters.
#'
#' @return an `sf` table with station data.
#'
#' @details
#' You can also subset stations by specifying `networks` and `duration` in
#' [set_options()].
#'
#' @export
#'
#' @examples
#' # get stations with WTEQ elements
#' get_stations(
#'   bear_lake,
#'   elements = "WTEQ"
#' )
#'
#' # get stations with WTEQ elements that are in the SNTL (and SCAN) network
#' get_stations(
#'   bear_lake,
#'   elements = "WTEQ",
#'   awdb_options = set_options(networks = "SNTL")
#' )
#'
#' # get stations with WTEQ elements that are measured daily
#' get_stations(
#'   bear_lake,
#'   elements = "WTEQ",
#'   awdb_options = set_options(durations = "DAILY")
#' )
#'
get_stations <- function(
  aoi,
  elements,
  awdb_options = set_options()
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"))
  check_character(elements, call = rlang::caller_call())
  check_awdb_options(awdb_options)

  filter_stations(
    aoi,
    elements,
    networks = awdb_options[["networks"]],
    durations = awdb_options[["duration"]]
  )
}
