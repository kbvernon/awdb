#' Get Station Metadata
#'
#' Get station metadata from the USDA National Water and Climate Center Air and
#' Water Database REST API. This includes their spatial coordinates.
#'
#' @inheritParams get_elements
#'
#' @return an `sf` table with station metadata.
#'
#' @details
#' This endpoint will accept the following query parameters via `set_options()`:
#' - `station_names`
#' - `dco_codes`
#' - `county_names`
#' - `hucs`
#' - `return_forecast_metadata`
#' - `return_reservoir_metadata`
#' - `return_element_metadata`
#' - `active_only`
#'
#' You may also specify `networks`. The `networks` parameter is used internally
#' to build unique station triplet identifiers of the form
#' `station:state:network`, so it serves to filter stations to just those
#' networks.
#'
#' See `set_options()` for more details.
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
#' # get stations with WTEQ elements that are in the SNTL network
#' get_stations(
#'   bear_lake,
#'   elements = "WTEQ",
#'   awdb_options = set_options(networks = "SNTL")
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
    elements = collapse(elements),
    awdb_options
  )
}
