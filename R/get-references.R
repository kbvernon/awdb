#' Get Data Dictionary
#'
#' Get references from the USDA National Water and Climate Center Air and Water
#' Database REST API. References provide descriptions of all codes used in the
#' AWDB.
#'
#' @param reference_type character scalar, the name of the reference. Potential
#' values include `dcos`, `durations`, `elements` (default), `forecastPeriods`,
#' `functions`, `instruments`, `networks`, `physicalElements`, `states`, and
#' `units`.
#'
#' @return a data.frame
#'
#' @export
#'
#' @examples
#' get_references("elements")
#'
get_references <- function(reference_type = "elements") {
  check_string(reference_type, call = rlang::caller_call())

  rlang::arg_match(
    reference_type,
    values = c(
      "dcos",
      "durations",
      "elements",
      "forecastPeriods",
      "functions",
      "instruments",
      "networks",
      "physicalElements",
      "states",
      "units"
    ),
    error_call = rlang::caller_call()
  )

  endpoint <- file.path(
    "https://wcc.sc.egov.usda.gov",
    "awdbRestApi",
    "services/v1",
    "reference-data"
  )

  request <- httr2::req_url_query(
    httr2::request(endpoint),
    referenceLists = reference_type
  )

  response <- httr2::req_perform(
    request,
    error_call = rlang::caller_call()
  )

  json <- httr2::resp_body_string(response)

  check_string(json)

  parse_station_reference_json(json, reference_type)
}
