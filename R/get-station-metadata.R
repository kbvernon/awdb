#' Get Station Metadata From USDA NWCC AWDB
#'
#' Get station metadata from the USDA National Water and Climate Center Air and
#' Water Database REST API. Each station is uniquely identified by a station
#' triplet of the form `station:state:network`.
#'
#' @inheritParams get_station_data
#' @param return_forecast_metadata scalar boolean, whether to return a list
#' column with forecast metadata. Default is `FALSE`.
#' @param return_reservoir_metadata scalar boolean, whether to return a list
#' column with reservoir metadata. Default is `FALSE`.
#' @param return_element_metadata scalar boolean, whether to return a list
#' column with element metadata. Default is `FALSE`.
#'
#' @return an `sf` table with station data. The number of rows is equal to the
#' number of stations found. If requested, forecast, reservoir,
#' and element metadata for each station are stored in their respective list
#' columns.
#'
#' @details
#' If you just want the locations, set all metadata options to `FALSE`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#'
#' pnw <- sf::st_bbox(c(
#'   xmin = -123.9745334,
#'   ymin = 42.689170,
#'   xmax = -117.212106,
#'   ymax = 48.591128
#' ))
#'
#' pnw <- sf::st_as_sfc(pnw, crs = 4326)
#'
#' # get locations and element metadata for stations with snow water equivalent
#' # (WTEQ) and soil moisture percent (SMS:*, * = any depth) measurements
#' get_station_metadata(
#'   pnw,
#'   elements = c("WTEQ", "SMS:*"),
#'   return_element_metadata = TRUE
#' )
#'
#' # get just locations for stations with snow water equivalent measurements
#' get_station_metadata(pnw, elements = "WTEQ")
#' }
get_station_metadata <- function(
  aoi,
  elements,
  networks = "*",
  durations = "DAILY",
  return_forecast_metadata = FALSE,
  return_reservoir_metadata = FALSE,
  return_element_metadata = FALSE,
  request_size = 10L
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"))
  check_character(elements)
  check_character(networks)
  check_bool(return_forecast_metadata)
  check_bool(return_reservoir_metadata)
  check_bool(return_element_metadata)
  check_number_whole(request_size)

  elements <- paste0(elements, collapse = ", ")

  stations <- get_stations(
    aoi,
    elements,
    networks,
    durations = durations
  )

  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "stations"
  )

  json <- make_requests(
    endpoint,
    stations[["station_triplet"]],
    request_size,
    elements = elements,
    durations = durations
  )

  # parse vector of json strings
  df <- parse_station_metadataset_json(json)

  if (all(lengths(df[["station_elements"]]) == 0)) {
    df[["station_elements"]] <- NULL
  } else {
    class(df[["station_elements"]]) <- "list"
  }

  class(df[["geometry"]]) <- c("sfc_POINT", "sfc")

  df
}
