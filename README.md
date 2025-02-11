

<!-- README.md is generated from README.qmd. Please edit that file -->

# awdb

<!-- badges: start -->

<!-- badges: end -->

The `{awdb}` package provides tools for querying the USDA National Water
and Climate Center [Air and Water Database REST
API](https://wcc.sc.egov.usda.gov/awdbRestApi/swagger-ui/index.html).
Rust via extendr is used to serialize and flatten deeply nested JSON
responses. The packaged is also designed to support pretty printing of
`tibbles` if you import the `{tibble}` package.

## Installation

You can install the development version of `{awdb}` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("kbvernon/awdb")
```

## Find Stations

Find all AWDB stations around Bear Lake in northern Utah that measure
soil moisture percent at various depths.

``` r
library(awdb)
library(sf)
library(tibble)

stations <- get_stations(bear_lake, elements = "SMS:*")

stations
#> Simple feature collection with 9 features and 14 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -111.6296 ymin: 41.68541 xmax: -111.1663 ymax: 42.4132
#> Geodetic CRS:  WGS 84
#> # A tibble: 9 × 15
#>   station_triplet station_id state_code network_code name   dco_code county_name
#> * <chr>           <chr>      <chr>      <chr>        <chr>  <chr>    <chr>      
#> 1 374:UT:SNTL     374        UT         SNTL         Bug L… UT       Rich       
#> 2 484:ID:SNTL     484        ID         SNTL         Frank… UT       Franklin   
#> 3 1114:UT:SNTL    1114       UT         SNTL         Garde… UT       Cache      
#> 4 493:ID:SNTL     493        ID         SNTL         Giveo… ID       Bear Lake  
#> 5 1115:UT:SNTL    1115       UT         SNTL         Klond… UT       Cache      
#> 6 1013:UT:SNTL    1013       UT         SNTL         Templ… UT       Cache      
#> 7 823:UT:SNTL     823        UT         SNTL         Tony … UT       Cache      
#> 8 1113:UT:SNTL    1113       UT         SNTL         Tony … UT       Cache      
#> 9 1098:UT:SNTL    1098       UT         SNTL         Usu D… UT       Rich       
#> # ℹ 8 more variables: huc <chr>, elevation <dbl>, data_time_zone <dbl>,
#> #   pedon_code <chr>, shef_id <chr>, begin_date <chr>, end_date <chr>,
#> #   geometry <POINT [°]>
```

<div style="width: 50%; margin: 0 auto;">

<img src="man/figures/README-stations-1.svg" data-fig-align="center" />

</div>

## Get Station Data

USDA refers to variables measured at AWDB stations as “elements.” The
package provides a table with all possible elements that can be lazy
loaded when you import `{awdb}`. Keep in mind that not all of them are
measured at every station.

``` r
element_codes
#> # A tibble: 102 × 3
#>    code  name                                  unit                 
#>    <chr> <chr>                                 <chr>                
#>  1 COND  Conductivity                          umho                 
#>  2 DIAG  Diagnostics                           <NA>                 
#>  3 DISO  Dissolved Oxygen                      milligrams per liter 
#>  4 DISP  Dissolved Oxygen - Percent Saturation percent              
#>  5 DIV   Diversion Flow Volume Observed        acre-feet            
#>  6 DIVD  Diversion Discharge Observed Mean     cubic feet per second
#>  7 DPTP  Dew Point Temperature                 fahrenheit           
#>  8 ETIB  Battery - ETI Precipitation Gauge     volt                 
#>  9 ETIL  Pulse Line Monitor - ETI Gauge        volt                 
#> 10 EVAP  Evaporation                           inches               
#> # ℹ 92 more rows
```

Here we get snow water equivalent and soil moisture measurements around
Bear Lake in early May of 2015.

``` r
elements <- get_elements(
  bear_lake,
  elements = c("WTEQ", "SMS:8"),
  awdb_options = set_options(
    begin_date = "2015-05-01",
    end_date = "2015-05-07"
  )
)

elements[, c("station_triplet", "element_code", "element_values")]
#> # A tibble: 10 × 3
#>    station_triplet element_code element_values
#>    <chr>           <chr>        <list>        
#>  1 374:UT:SNTL     WTEQ         <df [7 × 2]>  
#>  2 471:ID:SNTL     WTEQ         <df [7 × 2]>  
#>  3 484:ID:SNTL     WTEQ         <df [7 × 2]>  
#>  4 1114:UT:SNTL    WTEQ         <df [7 × 2]>  
#>  5 493:ID:SNTL     WTEQ         <df [7 × 2]>  
#>  6 1115:UT:SNTL    WTEQ         <df [7 × 2]>  
#>  7 1013:UT:SNTL    WTEQ         <df [7 × 2]>  
#>  8 823:UT:SNTL     WTEQ         <df [7 × 2]>  
#>  9 1113:UT:SNTL    WTEQ         <df [7 × 2]>  
#> 10 1098:UT:SNTL    WTEQ         <df [7 × 2]>

elements[["element_values"]][[1]]
#>         date value
#> 1 2015-05-01   2.1
#> 2 2015-05-02   1.1
#> 3 2015-05-03   0.0
#> 4 2015-05-04   0.0
#> 5 2015-05-05   0.0
#> 6 2015-05-06   0.0
#> 7 2015-05-07   0.0
```

These are time series, so the element values come in a list column
containing data.frames with at least `date` and `value` columns. Using
`tidyr::unnest()` is helpful for unpacking all of them.

## Additional Query Parameters

In the above example, we use `set_options()` to pass additional query
parameters. This is a helper that uses defaults assumed by the AWDB REST
API. Some additional package specific options are also included. It has
a decent print method if you want to inspect it.

``` r
set_options()
#> 
#> ── AWDB Query Parameter Set ────────────────────────────────────────────────────
#> • networks: *
#> • duration: DAILY
#> • begin_date: NULL
#> • end_date: NULL
#> • period_reference: END
#> • central_tendency: NULL
#> • return_flags: FALSE
#> • return_original_values: FALSE
#> • return_suspect_values: FALSE
#> • begin_publication_date: NULL
#> • end_publication_date: NULL
#> • exceedence_probabilities: NULL
#> • forecast_periods: NULL
#> • station_names: NULL
#> • dco_codes: NULL
#> • county_names: NULL
#> • hucs: NULL
#> • return_forecast_metadata: FALSE
#> • return_reservoir_metadata: FALSE
#> • return_element_metadata: FALSE
#> • active_only: TRUE
#> • request_size: 10
```
