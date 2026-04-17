# Get Station Metadata

Get station metadata from the USDA National Water and Climate Center Air
and Water Database REST API. This includes their spatial coordinates.

## Usage

``` r
get_stations(aoi = NULL, elements, awdb_options = set_options())
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

## Value

an `sf` table with station metadata.

## Details

This endpoint will accept the following query parameters via
[`set_options()`](https://kbvernon.github.io/awdb/reference/awdb_options.md):

- `station_names`

- `dco_codes`

- `county_names`

- `hucs`

- `return_forecast_metadata`

- `return_reservoir_metadata`

- `return_element_metadata`

- `active_only`

You may also specify `networks`. The `networks` parameter is used
internally to build unique station triplet identifiers of the form
`station:state:network`, so it serves to filter stations to just those
networks.

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

## Examples

``` r
# get all stations in aoi
get_stations(
  bear_lake,
  elements = "*"
)
#> Simple feature collection with 17 features and 14 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -111.7621 ymin: 41.62401 xmax: -110.8724 ymax: 42.4132
#> Geodetic CRS:  WGS 84
#> # A tibble: 17 × 15
#>    station_triplet station_id state_code network_code name  dco_code county_name
#>    <chr>           <chr>      <chr>      <chr>        <chr> <chr>    <chr>      
#>  1 10055500:ID:BOR 10055500   ID         BOR          Bear… UT       Bear Lake  
#>  2 10046500:ID:US… 10046500   ID         USGS         Bear… ID       Bear Lake  
#>  3 10113500:UT:US… 10113500   UT         USGS         Blac… UT       Cache      
#>  4 374:UT:SNTL     374        UT         SNTL         Bug … UT       Rich       
#>  5 471:ID:SNTL     471        ID         SNTL         Emig… ID       Bear Lake  
#>  6 484:ID:SNTL     484        ID         SNTL         Fran… UT       Franklin   
#>  7 1114:UT:SNTL    1114       UT         SNTL         Gard… UT       Cache      
#>  8 493:ID:SNTL     493        ID         SNTL         Give… ID       Bear Lake  
#>  9 1115:UT:SNTL    1115       UT         SNTL         Klon… UT       Cache      
#> 10 10108400:UT:US… 10108400   UT         USGS         Loga… UT       Cache      
#> 11 10069500:ID:BOR 10069500   ID         BOR          Mont… ID       Bear Lake  
#> 12 10046000:ID:US… 10046000   ID         USGS         Rain… ID       Bear Lake  
#> 13 10032000:WY:US… 10032000   WY         USGS         Smit… UT       Lincoln    
#> 14 1013:UT:SNTL    1013       UT         SNTL         Temp… UT       Cache      
#> 15 823:UT:SNTL     823        UT         SNTL         Tony… UT       Cache      
#> 16 1113:UT:SNTL    1113       UT         SNTL         Tony… UT       Cache      
#> 17 1098:UT:SNTL    1098       UT         SNTL         Usu … UT       Rich       
#> # ℹ 8 more variables: huc <chr>, elevation <dbl>, data_time_zone <dbl>,
#> #   pedon_code <chr>, shef_id <chr>, begin_date <chr>, end_date <chr>,
#> #   geometry <POINT [°]>

# get all stations in aoi that measure WTEQ
get_stations(
  bear_lake,
  elements = "WTEQ"
)
#> Simple feature collection with 10 features and 14 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -111.6296 ymin: 41.68541 xmax: -111.1663 ymax: 42.4132
#> Geodetic CRS:  WGS 84
#> # A tibble: 10 × 15
#>    station_triplet station_id state_code network_code name  dco_code county_name
#>    <chr>           <chr>      <chr>      <chr>        <chr> <chr>    <chr>      
#>  1 374:UT:SNTL     374        UT         SNTL         Bug … UT       Rich       
#>  2 471:ID:SNTL     471        ID         SNTL         Emig… ID       Bear Lake  
#>  3 484:ID:SNTL     484        ID         SNTL         Fran… UT       Franklin   
#>  4 1114:UT:SNTL    1114       UT         SNTL         Gard… UT       Cache      
#>  5 493:ID:SNTL     493        ID         SNTL         Give… ID       Bear Lake  
#>  6 1115:UT:SNTL    1115       UT         SNTL         Klon… UT       Cache      
#>  7 1013:UT:SNTL    1013       UT         SNTL         Temp… UT       Cache      
#>  8 823:UT:SNTL     823        UT         SNTL         Tony… UT       Cache      
#>  9 1113:UT:SNTL    1113       UT         SNTL         Tony… UT       Cache      
#> 10 1098:UT:SNTL    1098       UT         SNTL         Usu … UT       Rich       
#> # ℹ 8 more variables: huc <chr>, elevation <dbl>, data_time_zone <dbl>,
#> #   pedon_code <chr>, shef_id <chr>, begin_date <chr>, end_date <chr>,
#> #   geometry <POINT [°]>

# get all stations in aoi that are part of SNTL network
get_stations(
  bear_lake,
  elements = "*",
  awdb_options = set_options(networks = "SNTL")
)
#> Simple feature collection with 10 features and 14 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -111.6296 ymin: 41.68541 xmax: -111.1663 ymax: 42.4132
#> Geodetic CRS:  WGS 84
#> # A tibble: 10 × 15
#>    station_triplet station_id state_code network_code name  dco_code county_name
#>    <chr>           <chr>      <chr>      <chr>        <chr> <chr>    <chr>      
#>  1 374:UT:SNTL     374        UT         SNTL         Bug … UT       Rich       
#>  2 471:ID:SNTL     471        ID         SNTL         Emig… ID       Bear Lake  
#>  3 484:ID:SNTL     484        ID         SNTL         Fran… UT       Franklin   
#>  4 1114:UT:SNTL    1114       UT         SNTL         Gard… UT       Cache      
#>  5 493:ID:SNTL     493        ID         SNTL         Give… ID       Bear Lake  
#>  6 1115:UT:SNTL    1115       UT         SNTL         Klon… UT       Cache      
#>  7 1013:UT:SNTL    1013       UT         SNTL         Temp… UT       Cache      
#>  8 823:UT:SNTL     823        UT         SNTL         Tony… UT       Cache      
#>  9 1113:UT:SNTL    1113       UT         SNTL         Tony… UT       Cache      
#> 10 1098:UT:SNTL    1098       UT         SNTL         Usu … UT       Rich       
#> # ℹ 8 more variables: huc <chr>, elevation <dbl>, data_time_zone <dbl>,
#> #   pedon_code <chr>, shef_id <chr>, begin_date <chr>, end_date <chr>,
#> #   geometry <POINT [°]>
```
