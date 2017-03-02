

#' @include rules.R
setClass("ConditionRule", contains = "FieldRule", representation(condition = "expression"))

#' Creates new condition rule
#'
#' @export
#' @param field name of the field to validate
#' @param condition sting containing parsable condition for validation
newConditionRule <- function(field, condition) {
  rule <- new("ConditionRule",
            name = paste0("Field [", field, "] should match condition: ", condition),
            type = "Condition",
            field = field,
            condition = parse(text = paste0(field, " ", condition)))
  return(rule)
}

#' Validates data.table for regex field rule
#'
#' @param rule Condition rule to validate data
#' @param dt Data for validation
#' @return Records that did not pass the condition
setMethod("validate", signature("ConditionRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <- subset(dt, !eval(rule@condition))
  return(errors)
})
