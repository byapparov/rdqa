

#' @include rules.R
setClass("RegexRule", contains = "FieldRule", representation(pattern = "character"))

#' Creates new regex rule
#'
#' @export
#' @param field name of the field to be validated
#' @param pattern regex pattern that field should comply with
#' @return new regex rule
newRegexRule <- function(field, pattern) {
  rule <- new("RegexRule", name = paste0("Field [", field, "] should matrch pattern ", pattern),
            type = "Regex",
            field = field,
            pattern = pattern)
  return(rule)
}

#' Validates data.table for regex field rule
#'
#' @export
#' @param rule regex rule
#' @param dt data for validation
#' @return records that did not pass the check
setMethod("validate", signature("RegexRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <- subset(dt, !grepl(rule@pattern, get(rule@field)))
  return(errors)
})
