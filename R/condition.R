

#' @include rules.R
setClass(
  "ConditionRule",
  contains = "FieldRule",
  representation(condition = "expression")
)

#' Creates new condition rule
#'
#' @export
#' @param field name of the field to validate
#' @param condition sting containing parsable condition for validation
newConditionRule <- function(field, condition) {
  if (is.character(condition)) {
    exp.condition <- parse(text = paste0(field, " ", condition))
  }
  if (is.expression(condition)) {
    exp.condition <- condition
  }
  exp.condition <-
  rule <- new(
    "ConditionRule",
    name = paste0("Field [", field, "] should match condition: ", condition),
    type = "Condition",
    field = field,
    condition = exp.condition
  )
  return(rule)
}

#' @rdname validate
#' @return for `ConditionRule` records where values in target field
#'     don't match specified condition.
setMethod(
  "validate",
  signature("ConditionRule", "data.table"),
  function(rule, dt) {
    callNextMethod()
    subset(dt, !eval(rule@condition))
  }
)
