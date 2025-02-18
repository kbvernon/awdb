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
#' # get all stations in aoi
#' get_stations(
#'   bear_lake,
#'   elements = "*"
#' )
#'
#' # get all stations in aoi that measure WTEQ
#' get_stations(
#'   bear_lake,
#'   elements = "WTEQ"
#' )
#'
#' # get all stations in aoi that are part of SNTL network
#' get_stations(
#'   bear_lake,
#'   elements = "*",
#'   awdb_options = set_options(networks = "SNTL")
#' )
#'
get_stations <- function(
  aoi = NULL,
  elements,
  awdb_options = set_options()
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"), allow_null = TRUE)
  check_character(elements, call = rlang::caller_call())
  check_awdb_options(awdb_options)

  df <- filter_stations(
    aoi,
    elements = collapse(elements),
    awdb_options
  )

  if (awdb_options[["return_element_metadata"]]) {
    class(df[["element_metadata"]]) <- "list"
  }

  if (awdb_options[["return_forecast_metadata"]]) {
    class(df[["forecast_metadata"]]) <- "list"
  }

  if (awdb_options[["return_reservoir_metadata"]]) {
    class(df[["reservoir_metadata"]]) <- "list"
  }

  df
}
