#' Get Station Metadata From USDA NWCC AWDB
#'
#' Get station metadata from the USDA National Water and Climate Center Air and
#' Water Database REST API. Each station is uniquely identified by a station
#' triplet of the form `station:state:network`.
#'
#' @inheritParams get_station_data
#'
#' @return a `data.frame` with number of rows equal to
#' `length(station_triplets)`. Element metadata for each station is stored in a
#' list column named "station_elements".
#'
#' @examples
#' get_station_metadata("302:OR:SNTL")
#'
get_station_metadata <- function(station_triplets) {
  check_character(station_triplets)

  # TODO: handle rate limit of 1000 elements per request
  # TODO: process additional query parameters

  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "stations"
  )

  request_url <- httr2::req_url_query(
    httr2::request(endpoint),
    stationTriplets = station_triplets
  )

  response <- httr2::req_perform(
    request_url,
    error_call = rlang::caller_call()
  )

  json <- httr2::resp_body_string(response)

  df <- parse_station_metadataset_json(json)
  class(df[["geometry"]]) <- c("sfc_POINT", "sfc")

  df
}
