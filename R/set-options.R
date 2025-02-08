#' Build List of Additional Query Parameters
#'
#' This is a helper function to make it easier to handle additional query
#' parameters. Provides defaults for each and does type checking.
#'
#' @param networks character vector, abbreviations or codes for station networks
#' of interest (e.g., "USGS" refers to all USGS soil monitoring stations).
#' Default is `*`, for "all networks". See Details for available networks and
#' codes.
#' @param duration character scalar, the temporal resolution of the element
#' measurements. Available values include `daily` (default), `hourly`,
#' `semimonthly`, `monthly`, `calendar_year`, and `water_year`.
#' @param begin_date character scalar, start date for time period of interest.
#' Date must be in format `"YYYY-MM-DD"`.
#' @param end_date character scalar, end date for time period of interest. Date
#' must be in format `"YYYY-MM-DD"`.
#' @param period_reference character scalar, reporting convention to use when
#' returning instantaneous data. Default is `"end"`.
#' @param central_tendency character scalar, the central tendency to return for
#' each element value. Available options include `NULL` (default, no central
#' tendency returned), `median` and `average`.
#' @param return_flags boolean scalar, whether to return flags with each element
#' value. Default is `FALSE`.
#' @param return_original_values boolean scalar, whether to return original
#' element values. Default is `FALSE`.
#' @param return_suspect_data boolean scalar, whether to return suspect element
#' values. Default is `FALSE`.
#' @param dco_codes character vector, DCO codes. Default is `NULL`.
#' @param county_names character vector, county names. Default is `NULL`.
#' @param hucs integer vector, hydrologic unit codes. Default is `NULL`.
#' @param request_size integer scalar, number of individual stations to include
#' in each query. This helps to meet rate limits imposed by the API. If you are
#' getting a request error, you might try lowering this number. Default is
#' `10L`.
#'
#' @return an `awdb_options` list
#'
#' @export
#'
#' @examples
set_options <- function(
  networks = "*",
  duration = "daily",
  begin_date = NULL,
  end_date = NULL,
  period_reference = "end",
  central_tendency = NULL,
  return_flags = FALSE,
  return_original_values = FALSE,
  return_suspect_values = FALSE,
  dco_codes = NULL,
  county_names = NULL,
  hucs = NULL,
  request_size = 10L
) {
  check_character(networks, call = rlang::caller_call())
  check_string(duration, call = rlang::caller_call())
  check_string(begin_date, allow_null = TRUE, call = rlang::caller_call())
  check_string(end_date, allow_null = TRUE, call = rlang::caller_call())
  check_string(period_reference, call = rlang::caller_call())
  check_string(central_tendency, allow_null = TRUE, call = rlang::caller_call())
  check_bool(return_flags, call = rlang::caller_call())
  check_bool(return_original_values, call = rlang::caller_call())
  check_bool(return_suspect_values, call = rlang::caller_call())
  check_character(dco_codes, allow_null = TRUE, call = rlang::caller_call())
  check_character(county_names, allow_null = TRUE, call = rlang::caller_call())
  check_character(hucs, allow_null = TRUE, call = rlang::caller_call())
  check_number_whole(request_size, call = rlang::caller_call())

  # awdb has both a scalar and vector duration parameter, but for the sake of
  # keeping this api as simple as possible, we use only the scalar version
  rlang::arg_match(
    duration,
    values = c(
      "daily",
      "hourly",
      "semimonthly",
      "monthly",
      "calendar_year",
      "water_year"
    ),
    error_call = rlang::caller_call()
  )

  if (!is.null(begin_date) && !proper_format(begin_date)) {
    cli::cli_abort(
      "`begin_date` must be of the form `\"YYYY-MM-DD\"`.",
      call = call
    )
  }

  if (!is.null(end_date) && !proper_format(end_date)) {
    cli::cli_abort(
      "`end_date` must be of the form `\"YYYY-MM-DD\"`.",
      call = call
    )
  }

  parameters <- list(
    "networks" = networks,
    "duration" = toupper(duration),
    "begin_date" = begin_date,
    "end_date" = end_date,
    "period_reference" = toupper(period_reference),
    "central_tendency" = toupper(central_tendency),
    "return_flags" = return_flags,
    "return_original_values" = return_original_values,
    "return_suspect_values" = return_suspect_values,
    "dco_codes" = dco_codes,
    "county_names" = county_names,
    "hucs" = hucs,
    "request_size" = request_size
  )

  class(parameters) <- c("awdb_options", "list")

  parameters
}

proper_format <- function(x) {
  grepl("^\\d{4}-\\d{2}-\\d{2}$", x)
}

print.awdb_options <- function(x, ...) {
  parameter_set <- mapply(
    function(.x, .y) paste0(.x, ": ", .y),
    .x = names(x),
    .y = x
  )

  cli::cli_h1("AWDB Query Parameter Set")
  cli::cli_ul(parameter_set)
}
