

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

#'  Validates data.table for foreign key data rule
#'  
#' @export
#' @param rule foreign key rule
#' @param dt data for validation
#' @return records that did not pass the check
setMethod("validate", signature("ForeignKeyRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <- subset(dt, !get(rule@field) %in% rule@primary.key)
  errors$rule <- rule@name
  errors$type <- rule@type
  return(errors)
})
