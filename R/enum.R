

#' @include rules.R
setClass("EnumRule", contains = "FieldRule", representation(enum = "character"))

#' Creates new enum rule
#'
#' @export
#' @param field name of the field to be validated
#' @param enum vector of allowed character values
#' @return new enum rule
newEnumRule <- function(field, enum) {
  rule <- new("EnumRule", 
              name = paste0("Field [", field, "] should should be one of enum values"),
              type = "Enum",
              field = field,
              enum = enum)
  return(rule)
}

#' Validates data.table for enum field rule
#'
#' @export
#' @param rule enum rule
#' @param dt data for validation
#' @return records that did not pass the check
setMethod("validate", signature("EnumRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <- subset(dt, !is.na(get(rule@field)) & !(get(rule@field) %in% rule@enum))
  return(errors)
})
