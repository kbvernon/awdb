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
#' @param begin_publication_date character scalar, the beginning of the
#' publication period for which to retrieve data. Date must be in format
#' `YYYY-MM-DD`. If `NULL`, assumes start of the current water year.
#' @param end_publication_date character scalar, the end of the publication
#' period for which to retrieve data. Date must be in format `YYYY-MM-DD`. If
#' `NULL`, assumes current day.
#' @param exceedence_probabilities integer vector, TODO! write this...
#' @param forecast_periods character vector, TODO! figure this one out...
#' @param station_names character vector, station names. Default is `NULL`.
#' @param dco_codes character vector, DCO codes. Default is `NULL`.
#' @param county_names character vector, county names. Default is `NULL`.
#' @param hucs integer vector, hydrologic unit codes. Default is `NULL`.
#' @param return_forecast_metadata boolean scalar, whether to return forecast
#' metadata with station locations. Will be included as a list column. Default
#' is `FALSE`.
#' @param return_reservoir_metadata boolean scalar, whether to return reservoir
#' metadata with station locations. Will be included as a list column. Default
#' is `FALSE`.
#' @param return_element_metadata boolean scalar, whether to return element
#' metadata with station locations. Will be included as a list column. Default
#' is `FALSE`.
#' @param active_only boolean scalar, whether to include only active stations.
#' Default is `TRUE`.
#' @param request_size integer scalar, number of individual stations to include
#' in each query. This helps to meet rate limits imposed by the API. If you are
#' getting a request error, you might try lowering this number. Default is
#' `10L`.
#'
#' @return an `awdb_options` list
#'
#' @export
#'
#' @name awdb_options
#'
#' @examples
#' set_options()
#'
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
  begin_publication_date = NULL,
  end_publication_date = NULL,
  exceedence_probabilities = NULL,
  forecast_periods = NULL,
  station_names = NULL,
  dco_codes = NULL,
  county_names = NULL,
  hucs = NULL,
  return_forecast_metadata = FALSE,
  return_reservoir_metadata = FALSE,
  return_element_metadata = FALSE,
  active_only = TRUE,
  request_size = 10L
) {
  current_call <- rlang::caller_call()

  check_character(networks, call = current_call)
  check_string(duration, call = current_call)
  check_date_format(begin_date, call = current_call)
  check_date_format(end_date, call = current_call)
  check_string(end_date, allow_null = TRUE, call = current_call)
  check_string(period_reference, call = current_call)
  check_string(central_tendency, allow_null = TRUE, call = current_call)
  check_bool(return_flags, call = current_call)
  check_bool(return_original_values, call = current_call)
  check_bool(return_suspect_values, call = current_call)
  check_date_format(begin_publication_date, call = current_call)
  check_date_format(end_publication_date, call = current_call)

  if (
    !rlang::is_null(exceedence_probabilities) &&
      !rlang::is_integer(exceedence_probabilities)
  ) {
    cli::cli_abort(
      "{.arg exceedence_probabilities} must be an integer vector.",
      "i" = "e.g., `c(30L, 50L, 70L)`.",
      call = current_call
    )
  }

  check_character(station_names, allow_null = TRUE, call = current_call)
  check_character(dco_codes, allow_null = TRUE, call = current_call)
  check_character(county_names, allow_null = TRUE, call = current_call)
  check_character(hucs, allow_null = TRUE, call = current_call)
  check_bool(return_forecast_metadata, call = current_call)
  check_bool(return_reservoir_metadata, call = current_call)
  check_bool(return_element_metadata, call = current_call)
  check_bool(active_only, call = current_call)
  check_number_whole(request_size, call = current_call)

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
    error_call = current_call
  )

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
    "begin_publication_date" = begin_publication_date,
    "end_publication_date" = end_publication_date,
    "exceedence_probabilities" = collapse(exceedence_probabilities),
    "forecast_periods" = collapse(forecast_periods),
    "station_names" = collapse(station_names),
    "dco_codes" = collapse(dco_codes),
    "county_names" = collapse(county_names),
    "hucs" = collapse(hucs),
    "return_forecast_metadata" = return_forecast_metadata,
    "return_reservoir_metadata" = return_reservoir_metadata,
    "return_element_metadata" = return_element_metadata,
    "active_only" = active_only,
    "request_size" = request_size
  )

  class(parameters) <- c("awdb_options", "list")

  parameters
}

#' @rdname awdb_options
#' @export
#'
print.awdb_options <- function(x, ...) {
  parameter_set <- mapply(
    function(.x, .y) paste0(.x, ": ", .y),
    .x = names(x),
    .y = x
  )

  cli::cli_h1("AWDB Query Parameter Set")
  cli::cli_ul(parameter_set)
}
