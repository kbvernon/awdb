#' Bear Lake Area
#'
#' An arbitrary bounding box drawn around Bear Lake along the border between
#' Utah and Idaho. See
#' [location on Google Maps](https://maps.app.goo.gl/bDBFyFhNgYbfvwuw8).
#'
#' @format ## `bear_lake`
#' A simple feature column or `sfc` consisting of a single POLYGON geometry.
#' @source Coordinates digitized manually.
"bear_lake"

#' Element Codes
#'
#' A list of elements, their codes and units.
#'
#' @format ## `element_codes`
#' A `tibble` with columns `code`, `name`, and `unit`.
#' @source [AWDB Web Service User Guide](https://www.nrcs.usda.gov/sites/default/files/2023-03/AWDB%20Web%20Service%20User%20Guide.pdf)
"element_codes"

#' Network Codes
#'
#' A list of station networks and their codes.
#'
#' @format ## `network_codes`
#' A `tibble` with columns `code` and `description`.
#' @source [AWDB Web Service User Guide](https://www.nrcs.usda.gov/sites/default/files/2023-03/AWDB%20Web%20Service%20User%20Guide.pdf)
"network_codes"
