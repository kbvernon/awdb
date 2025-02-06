#' Get Stations From USDA NWCC AWDB
#'
#' Get stations from the USDA National Water and Climate Center Air and Water
#' Database REST API that fall in area of interest. Returns `sf` table with a
#' `station_triplet` column containing a unique "station triplet" identifier of
#' the form `station:state:network`.
#'
#' @inheritParams get_station_data
#' @param call from rlang: "the defused call with which the function running in
#' the frame was invoked."
#' @param ... key-value pairs passed as query parameters to `req_url_query()`
#'
#' @return a character vector of station tripletsc having the form
#' `station:state:network`, with `state` being the state code for each station
#' (e.g., "OR" for "Oregon") and `network` the abbreviation or "code" of the
#' station network that each station is part of (e.g., "USGS" refers to all USGS
#' soil monitoring stations). Note that the `*` wildcard can be used to select
#' all of `station`, `state`, or `network`. The triplet `*:*:*` will return the
#' entire database.
#'
#' @keywords internal
#' @noRd
#'
get_stations <- function(
  aoi,
  elements,
  networks,
  call = rlang::caller_call(),
  ...
) {
  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "stations"
  )

  request_url <- httr2::req_url_query(
    httr2::request(endpoint),
    stationTriplets = paste0("*:*:", networks, collapse = ","),
    elements = elements,
    ...,
    returnForecastPointMetadata = FALSE,
    returnReservoirMetadata = FALSE,
    returnStationElements = FALSE
  )

  response <- httr2::req_perform(
    request_url,
    error_call = call
  )

  json <- httr2::resp_body_string(response)

  df <- parse_station_metadataset_json(json)
  df <- df[, c("station_triplet", "geometry")]

  class(df[["geometry"]]) <- c("sfc_POINT", "sfc")

  df <- sf::st_transform(df, sf::st_crs(aoi))

  df <- sf::st_filter(df, aoi)

  df
}

#' Make Requests in Parallel
#'
#' @inheritParams get_station_data
#' @param endpoint character scalar, the base url for the API plus the endpoint
#' @param call from rlang: "the defused call with which the function running in
#' the frame was invoked."
#' @param ... key-value pairs passed as query parameters to `req_url_query()`
#'
#' @details
#' The AWDB REST API rate limits requests to 1000 elements. That's the number of
#' elements at each station, not the number of stations, which is difficult to
#' estimate directly (the metadata is also rate limited in this way). The
#' solution is to to limit the number of stations to a small number, then use
#' `httr2::req_perform_parallel()`. If any requests fail, this will emit a
#' warning with a list of failed stations.
#'
#' @keywords internal
#' @noRd
#'
make_requests <- function(
  endpoint,
  station_triplets,
  request_size,
  call = rlang::caller_call(),
  ...
) {
  station_triplets_list <- split(
    station_triplets,
    f = ceiling(seq_along(station_triplets) / request_size)
  )

  base_request_url <- httr2::request(endpoint)

  requests <- lapply(
    station_triplets_list,
    function(.x) {
      httr2::req_url_query(
        base_request_url,
        stationTriplets = paste0(.x, collapse = ","),
        ...
      )
    }
  )

  responses <- httr2::req_perform_parallel(requests, on_error = "continue")

  errors <- vapply(
    responses,
    FUN = httr2::resp_is_error,
    FUN.VALUE = logical(1L),
    USE.NAMES = FALSE
  )

  if (any(errors)) {
    missing_stations <- unlist(station_triplets_list[errors])

    cli::cli_alert(
      "Request failed for these stations: {missing_stations}",
      call = call
    )
  }

  vapply(
    responses[!errors],
    FUN = httr2::resp_body_string,
    FUN.VALUE = character(1L),
    USE.NAMES = FALSE
  )
}

#' Check For Valid `sfc` Scalar
#'
#' @keywords internal
#' @noRd
#'
check_sfc_scalar <- function(aoi, shape, call = rlang::caller_call()) {
  is_sfc <- rlang::inherits_any(aoi, "sfc")
  is_scalar <- length(aoi) == 1
  is_shape <- sf::st_geometry_type(aoi) %in% shape

  if (!is_sfc || !is_scalar || !is_shape) {
    cli::cli_abort(
      "`aoi` must be an {.cls sfc} containing a single feature with geometry type {shape}.",
      call = call
    )
  }

  if (!sf::st_is_valid(aoi)) {
    cli::cli_abort(
      "`aoi` is not a valid geometry.",
      "i" = "Consider running `sf::st_make_valid(aoi)`.",
      call = call
    )
  }
}

#' Check For Date String With Proper Format
#'
#' @keywords internal
#' @noRd
#'
check_date_scalar <- function(date, call = rlang::caller_call()) {
  check_string(date, call = call)

  if (!grepl("^\\d{4}-\\d{2}-\\d{2}$", date)) {
    cli::cli_abort(
      "`date` must be of the form `\"YYYY-MM-DD\"`.",
      call = call
    )
  }
}
