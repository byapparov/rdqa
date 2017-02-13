
#' External rule allow to use logical permutation vector that defines records
#' that vialate the business rule.
#'
#' @include rules.R
setClass("ExternalRule", contains = "FieldRule", representation(errors = "logical"))


#' Creates new external rule, where calculation of the vector that defines erros
#' was done externally.
#'
#' @export
#' @param field name of the field that represents the error record
#' @param errors logical vector that defines records with errors
#' @return new external rule
newExternalRule <- function(field, errors) {
  rule <- new("ExternalRule", name = paste0("Field [", field, "] contains wrong data"),
              type = "External",
              field = field,
              errors = errors)
  return(rule)
}


#' Validates data.table for external rule
#'
#' @export
#' @param rule external rule
#' @param dt data for validation
#' @return records that did not pass the check
setMethod("validate", signature("ExternalRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <- subset(dt, rule@errors)
  return(errors)
})