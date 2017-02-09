

#' @include rules.R
setClass("ConditionRule", contains = "FieldRule", representation(condition = "expression"))

#' Creates new condition rule
#' 
#' @param field name of the field to validate
#' @param condition sting containing parsable condition for validation
newConditionRule <- function(field, condition) {
  rule <- new("ConditionRule", 
            name = paste0("Field [", field, "] should matrch condition: ", condition),
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
  errors <- subset(dt, !eval(rule@condition))
  errors$rule <- rule@name
  errors$type <- rule@type
  return(errors)
})
