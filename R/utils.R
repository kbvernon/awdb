#' Get Station Locations From USDA NWCC AWDB in Area of Interest
#'
#' @inheritParams get_elements
#'
#' @keywords internal
#' @noRd
#'
filter_stations <- function(
  aoi,
  elements,
  networks,
  durations,
  call = rlang::caller_call()
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
    networks = networks,
    durations = durations,
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

  df <- sf::st_as_sf(
    df,
    coords = c("longitude", "latitude"),
    crs = 4326
  )

  df <- sf::st_transform(df, sf::st_crs(aoi))

  df <- sf::st_filter(df, aoi)

  if (nrow(df) == 0) {
    cli::cli_abort(
      "No stations found in {.var aoi}.",
      call = call
    )
  }

  df
}

#' Make Requests in Parallel
#'
#' @param endpoint character scalar, the base url for the API plus the endpoint
#' @param station_triplets character vector, the unique ID for each station with
#' format `station:state:network`.
#' @param ... key-value pairs passed as query parameters to `req_url_query()`
#' @inheritParams set_options
#' @param call from rlang: "the defused call with which the function running in
#' the frame was invoked."
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
  ...,
  request_size,
  call = rlang::caller_call()
) {
  station_triplets_list <- split(
    station_triplets,
    f = ceiling(seq_along(station_triplets) / request_size)
  )

  requests <- lapply(
    station_triplets_list,
    function(.x) {
      httr2::req_url_query(
        httr2::request(endpoint),
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
      "Request failed for these stations: {.val {missing_stations}}.",
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

#' Check For `awdb_options` List
#'
#' @keywords internal
#' @noRd
#'
check_awdb_options <- function(awdb_options, call = rlang::caller_call()) {
  if (!rlang::inherits_all(awdb_options, c("awdb_options", "list"))) {
    cli::cli_abort(
      "{.var awdb_options} must be an {.cls awdb_options} list.",
      call = call
    )
  }
}
