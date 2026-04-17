# Build List of Additional Query Parameters

This is a helper function to make it easier to handle additional query
parameters. Provides defaults for each and does type checking.

## Usage

``` r
set_options(
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
)

# S3 method for class 'awdb_options'
print(x, ...)
```

## Arguments

- networks:

  character vector, abbreviations or codes for station networks of
  interest (e.g., "USGS" refers to all USGS soil monitoring stations).
  Default is `*`, for "all networks". See Details for available networks
  and codes.

- duration:

  character scalar, the temporal resolution of the element measurements.
  Available values include `daily` (default), `hourly`, `semimonthly`,
  `monthly`, `calendar_year`, and `water_year`.

- begin_date:

  character scalar, start date for time period of interest. Date must be
  in format `"YYYY-MM-DD"`.

- end_date:

  character scalar, end date for time period of interest. Date must be
  in format `"YYYY-MM-DD"`.

- period_reference:

  character scalar, reporting convention to use when returning
  instantaneous data. Default is `"end"`.

- central_tendency:

  character scalar, the central tendency to return for each element
  value. Available options include `NULL` (default, no central tendency
  returned), `median` and `average`.

- return_flags:

  boolean scalar, whether to return flags with each element value.
  Default is `FALSE`.

- return_original_values:

  boolean scalar, whether to return original element values. Default is
  `FALSE`.

- return_suspect_values:

  boolean scalar, whether to return suspect element values. Default is
  `FALSE`.

- begin_publication_date:

  character scalar, the beginning of the publication period for which to
  retrieve data. Date must be in format `YYYY-MM-DD`. If `NULL`, assumes
  start of the current water year.

- end_publication_date:

  character scalar, the end of the publication period for which to
  retrieve data. Date must be in format `YYYY-MM-DD`. If `NULL`, assumes
  current day.

- exceedence_probabilities:

  integer vector, the probability that streamflow will exceed a
  specified level.

- forecast_periods:

  character vector, the time period over which to make streamflow
  forecasts.

- station_names:

  character vector, used to subset stations by their names. Default is
  `NULL`.

- dco_codes:

  character vector, used to subset stations to those that fall in
  specified DCOs. Default is `NULL`.

- county_names:

  character vector, used to subset stations to those that fall in
  specified counties. Default is `NULL`.

- hucs:

  integer vector, used to subset stations to those that fall in
  specified hydrologic units. Default is `NULL`.

- return_forecast_metadata:

  boolean scalar, whether to return forecast metadata with station
  locations. Will be included as a list column. Default is `FALSE`.

- return_reservoir_metadata:

  boolean scalar, whether to return reservoir metadata with station
  locations. Will be included as a list column. Default is `FALSE`.

- return_element_metadata:

  boolean scalar, whether to return element metadata with station
  locations. Will be included as a list column. Default is `FALSE`.

- active_only:

  boolean scalar, whether to include only active stations. Default is
  `TRUE`.

- request_size:

  integer scalar, number of individual stations to include in each
  query. This helps to meet rate limits imposed by the API. If you are
  getting a request error, you might try lowering this number. Default
  is `10L`.

- x:

  an `awdb_options` list

- ...:

  ignored

## Value

an `awdb_options` list

## Examples

``` r
set_options()
#> 
#> ── AWDB Query Parameter Set ────────────────────────────────────────────────────
#> Options passed to each endpoint.
#> 
#>                           VALUE STATION ELEMENT FORECAST
#> networks                      *     [X]     [X]      [X]
#> duration                  DAILY     [X]     [X]      [ ]
#> begin_date                 NULL     [ ]     [X]      [ ]
#> end_date                   NULL     [ ]     [X]      [ ]
#> period_reference            END     [ ]     [X]      [ ]
#> central_tendency           NULL     [ ]     [X]      [ ]
#> return_flags              FALSE     [ ]     [X]      [ ]
#> return_original_values    FALSE     [ ]     [X]      [ ]
#> return_suspect_values     FALSE     [ ]     [X]      [ ]
#> begin_publication_date     NULL     [ ]     [ ]      [X]
#> end_publication_date       NULL     [ ]     [ ]      [X]
#> exceedence_probabilities   NULL     [ ]     [ ]      [X]
#> forecast_periods           NULL     [ ]     [ ]      [X]
#> station_names              NULL     [X]     [X]      [X]
#> dco_codes                  NULL     [X]     [X]      [X]
#> county_names               NULL     [X]     [X]      [X]
#> hucs                       NULL     [X]     [X]      [X]
#> return_forecast_metadata  FALSE     [X]     [ ]      [ ]
#> return_reservoir_metadata FALSE     [X]     [ ]      [ ]
#> return_element_metadata   FALSE     [X]     [ ]      [ ]
#> active_only                TRUE     [X]     [X]      [X]
#> request_size                 10     [ ]     [X]      [X]
```
