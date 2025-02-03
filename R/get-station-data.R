#' Get Station Data From USDA NWCC AWDB
#'
#' Get station data from the USDA National Water and Climate Center Air and
#' Water Database REST API. Each station is uniquely identified by a station
#' triplet of the form `station:state:network`.
#'
#' @param station_triplets character vector, a vector of station triplets having
#' the form `station:state:network`, with `state` being the state code for each
#' station (e.g., "OR" for "Oregon") and `network` the abbreviation of the
#' station network that each station is part of (e.g., "SCAN" for "Soil Climate
#' Adaptation Network"). Note that the `*` wildcard can be used to select all of
#' `station`, `state`, or `network`. The triplet `*:*:*` will return the entire
#' database. See Details for all networks.
#' @param elements character vector, the abbreviation of the variable for which
#' measurements are sought (e.g., "SMS" for "Soil Moisture Percent"). See
#' Details for all elements.
#'
#' @return a `data.frame`` with station data. The number of rows depends on the
#' number of stations and elements measured at each. Time series data are
#' included as a list column named "values" (the name used by the API).
#'
#' @details
#' TODO: add table of possible networks
#'
#' @examples
#' get_station_data("302:OR:SNTL", elements = "WTEQ")
#'
get_station_data <- function(station_triplets, elements, begin_date, end_date) {
  check_character(station_triplets)
  check_character(elements)
  check_string(begin_date)
  check_string(end_date)

  # TODO: handle rate limit of 1000 elements per request
  # TODO: process additional query parameters

  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "data"
  )

  request_url <- httr2::req_url_query(
    httr2::request(endpoint),
    stationTriplets = station_triplets,
    elements = elements,
    beginDate = begin_date,
    endDate = end_date
  )

  response <- httr2::req_perform(
    request_url,
    error_call = rlang::caller_call()
  )

  json <- httr2::resp_body_string(response)

  df <- parse_station_dataset_json(json)
  class(df[["values"]]) <- "list"

  df
}
