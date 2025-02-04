#' Get Station Data From USDA NWCC AWDB
#'
#' Get station data from the USDA National Water and Climate Center Air and
#' Water Database REST API.
#'
#' @param aoi `sfc` POLYGON scalar, the area of interest used for performing
#' a spatial filter on available stations in `network`.
#' @param elements character vector, abbreviations or codes for variables of
#' interest (e.g., "SMS" for "Soil Moisture Percent"). See Details for available
#' elements and codes.
#' @param networks character vector, abbreviations or codes for station networks
#' of interest (e.g., "USGS" refers to all USGS soil monitoring stations).
#' Default is `*`, for "all networks". See Details for available networks and
#' codes.
#' @param duration character scalar, the temporal resolution of the element
#' measurements. Available values include `DAILY` (default), `HOURLY`,
#' `SEMIMONTHLY`, `MONTHLY`, `CALENDAR_YEAR`, `WATER_YEAR`.
#' @param begin_date character scalar, start date for time period of interest.
#' Date must be in format `"YYYY-MM-DD"`.
#' @param end_date character scalar, end date for time period of interest. Date
#' must be in format `"YYYY-MM-DD"`.
#' @param request_size integer scalar, number of individual stations to include
#' in each query. This helps to meet rate limits imposed by the API. If you are
#' getting a request error, you might try lowering this number. Default is
#' `10L`.
#' @param as_sf boolean scalar, whether to return the data as an `sf` table.
#' Default is `FALSE`. Repeating the spatial data across each station element
#' and its time series can be costly.
#'
#' @return if `as_sf`, an `sf` table, otherwise a simple data.frame. The number
#' of rows depends on the number of stations and element parameters. Time series
#' data are included as a list column named `"values"`.
#'
#' @details
#' TODO: add table of possible networks and elements
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
#' get_station_data(pnw, elements = "WTEQ", networks = "SNTL")
#' }
get_station_data <- function(
  aoi,
  elements,
  networks = "*",
  duration = "DAILY",
  begin_date,
  end_date,
  request_size = 10L,
  as_sf = FALSE
) {
  check_sfc_scalar(aoi, shape = c("POLYGON", "MULTIPOLYGON"))
  check_character(networks)
  check_character(elements)
  check_date_scalar(begin_date)
  check_date_scalar(end_date)
  check_number_whole(request_size)

  elements <- paste0(elements, collapse = ", ")

  stations <- get_stations(
    aoi,
    elements,
    networks,
    durations = duration,
    beginDate = begin_date,
    endDate = end_date
  )

  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "data"
  )

  requests <- split_requests(
    endpoint,
    stations[["station_triplet"]],
    request_size,
    elements = elements,
    duration = duration,
    beginDate = begin_date,
    endDate = end_date
  )

  responses <- perform_requests(requests)

  dfs <- lapply(responses, parse_station_dataset_json)

  df <- do.call("rbind", dfs)

  class(df[["values"]]) <- "list"

  if (as_sf) {
    df <- merge(df, stations, by = "station_triplet")
  }

  df
}
