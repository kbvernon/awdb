# Get Data Dictionary

Get references from the USDA National Water and Climate Center Air and
Water Database REST API. References provide descriptions of all codes
used in the AWDB.

## Usage

``` r
get_references(reference_type = "elements")
```

## Arguments

- reference_type:

  character scalar, the name of the reference. Potential values include
  `dcos`, `durations`, `elements` (default), `forecastPeriods`,
  `functions`, `instruments`, `networks`, `physicalElements`, `states`,
  and `units`.

## Value

a data.frame with reference data

## Examples

``` r
get_references("elements")
#> # A tibble: 116 × 9
#>    code  name     physical_element_name function_code data_precision description
#>    <chr> <chr>    <chr>                 <chr>                  <int> <chr>      
#>  1 TAVG  AIR TEM… air temperature       V                          1 Average Ai…
#>  2 TMAX  AIR TEM… air temperature       X                          1 Maximum Ai…
#>  3 TMIN  AIR TEM… air temperature       N                          1 Minimum Ai…
#>  4 TOBS  AIR TEM… air temperature       C                          1 Instantane…
#>  5 PRES  BAROMET… barometric pressure   C                          2 Barometric…
#>  6 BATT  BATTERY  battery               C                          2 Battery Vo…
#>  7 BATV  BATTERY… battery               V                          2 NA         
#>  8 BATX  BATTERY… battery               X                          2 Maximum Ba…
#>  9 BATN  BATTERY… battery               N                          2 Minimum Ba…
#> 10 ETIB  BATTERY… battery-eti precip g… C                          2 NA         
#> # ℹ 106 more rows
#> # ℹ 3 more variables: stored_unit_code <chr>, english_unit_code <chr>,
#> #   metric_unit_code <chr>
```
