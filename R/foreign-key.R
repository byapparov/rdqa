

#' Class to describe foreign key rules
#' @include rules.R
setClass("ForeignKeyRule", contains = "FieldRule", representation(primary.key = "character"))

#' Factory for the ForeignKey rule
#'
#' @export
#' @param field name of the foreign key field
#' @param primary.key vector of values from the referenced field
#' @return rule for given parameters
newForeignKeyRule <- function(field, primary.key) {
  rule <- new("ForeignKeyRule",
              name = "Orphan record",
              type = "ForeignKey",
              field = field,
              primary.key = primary.key)
  return(rule)
}

#' @rdname validate
#' @return for `ForeignKeyRule` orphan records based on the foreign key constraint.
setMethod("validate", signature("ForeignKeyRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <- subset(dt, !get(rule@field) %in% rule@primary.key)
  return(errors)
})
