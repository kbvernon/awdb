# Get Station Forecasts

Get station forecasts from the USDA National Water and Climate Center
Air and Water Database REST API. These will almost always be streamflow
forecasts, set with `elements = "SRVO"`, but some others are also
available, albeit with extremely limited spatial representation (see
Details).

## Usage

``` r
get_forecasts(
  aoi = NULL,
  elements,
  awdb_options = set_options(),
  as_sf = FALSE
)
```

## Arguments

- aoi:

  `sfc` POLYGON scalar, the area of interest used for performing a
  spatial filter on available stations in `network`. If `NULL` (the
  default), no spatial filter is performed.

- elements:

  character vector, abbreviations or codes for variables of interest
  (e.g., "SMS" for "Soil Moisture Percent"). See Details for available
  elements and codes.

- awdb_options:

  an `awdb_options` list with additional query parameters.

- as_sf:

  boolean scalar, whether to return the data as an `sf` table. Default
  is `FALSE`. Repeating the spatial data across each station element and
  its time series can be costly.

## Value

if `as_sf`, an `sf` table, otherwise a simple data.frame. The number of
rows depends on the number of stations and element parameters. Time
series data are included as a list column named `"forecast_values"`.

## Details

This endpoint will accept the following query parameters via
[`set_options()`](https://kbvernon.github.io/awdb/reference/awdb_options.md):

- `begin_publication_date`

- `end_publication_date`

- `exceedence_probabilities`

- `forecast_periods`

The following can also be passed to filter stations:

- `station_names`

- `dco_codes`

- `county_names`

- `hucs`

- `active_only`

You may also specify `networks` and `request_size`. The `networks`
parameter is used internally to build unique station triplet identifiers
of the form `station:state:network` which are then passed to the
endpoint, so it serves to filter stations to just those networks. The
`request_size` parameter is for handling rate limits, which are based on
the number of elements - a hard value to measure directly, so this
parameter is more a rule of thumb than a strict standard. If processing
is slow for you, you may find experimenting with this parameter useful.

Note that the `duration` parameter is ignored - or, more precisely, it
is set to `NULL`.

See
[`set_options()`](https://kbvernon.github.io/awdb/reference/awdb_options.md)
for more details.

### Element Format

Elements are specified as triplets of the form
`elementCode:heightDepth:ordinal`. Any part of the element triplet can
contain the `*` wildcard character. Both `heightDepth` and `ordinal` are
optional. The unit of `heightDepth` is inches. If `ordinal` is not
specified, it is assumed to be 1. Here are some examples:

- `"WTEQ"` - return all snow water equivalent values.

- `"SMS:-8"` - return soil moisture values observed 8 inches below the
  surface.

- `"SMS:*"` - return soil moisture values for all measured depths.

### Forecast Elements

Almost all forecasts are reported in `SRVO`, the adjusted streamflow set
which accounts for upstream operations such as reservoir operations and
diversions. `JDAY`, `RESC`, and `REST` are mostly there to maintain
historical forecasts made at Lake Tahoe (the birthplace of the snow
survey). In general, it's recommended to use `SRVO`.

## Examples

``` r
# get streamflow forecasts
get_forecasts(cascades, elements = "SRVO")
#> # A tibble: 118 × 10
#>    station_triplet  forecast_point_name    element_code forecast_period
#>    <chr>            <chr>                  <chr>        <chr>          
#>  1 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         02-01:07-31    
#>  2 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         02-01:07-31    
#>  3 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         02-01:09-30    
#>  4 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         02-01:09-30    
#>  5 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         03-01:07-31    
#>  6 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         03-01:09-30    
#>  7 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:07-31    
#>  8 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:07-31    
#>  9 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:07-31    
#> 10 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:07-31    
#> # ℹ 108 more rows
#> # ℹ 6 more variables: forecast_status <chr>, issue_date <chr>,
#> #   period_normal <dbl>, publication_date <chr>, unit_code <chr>,
#> #   forecast_values <list>

# return as sf table
get_forecasts(cascades, elements = "SRVO", as_sf = TRUE)
#> Simple feature collection with 118 features and 10 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -122.8373 ymin: 43.5029 xmax: -121.5028 ymax: 44.2679
#> Geodetic CRS:  WGS 84
#> # A tibble: 118 × 11
#>    station_triplet  forecast_point_name    element_code forecast_period
#>    <chr>            <chr>                  <chr>        <chr>          
#>  1 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:07-31    
#>  2 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:09-30    
#>  3 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:07-31    
#>  4 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:07-31    
#>  5 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:09-30    
#>  6 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         02-01:09-30    
#>  7 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         02-01:09-30    
#>  8 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         03-01:07-31    
#>  9 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         03-01:09-30    
#> 10 14050000:OR:USGS Deschutes R bl Snow Ck SRVO         04-01:07-31    
#> # ℹ 108 more rows
#> # ℹ 7 more variables: forecast_status <chr>, issue_date <chr>,
#> #   period_normal <dbl>, publication_date <chr>, unit_code <chr>,
#> #   forecast_values <list>, geometry <POINT [°]>
```
