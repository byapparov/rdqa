
#' @include rules.R
#'
#' @slot fields vector of columns that defines unique field set.
setClass("UniqueRule", contains = "RecordRule", representation(fields = "character"))

#' Creates new unique rule
#'
#' @export
#' @param fields vector of fields that define the unique constraint
#' @return records that did not pass the check
newUniqueRule <- function(fields) {
  dt <- new("UniqueRule", name = paste0("Field(s) [", paste(fields, collapse = ", "), "] should be uqniue"),
            type = "Unique",
            fields = fields)
  return(dt)
}

#' Validates that a field in a data.table is unique
#'
#' @export
#' @param rule data rule that will be used to find duplicate records
#' @param dt data to be validated
#' @return duplicate records
setMethod("validate", signature("UniqueRule", "data.table"), function(rule, dt) {
  callNextMethod()
  unique.fields <- subset(dt, select = rule@fields)
  setkeyv(unique.fields, cols = rule@fields)
  errors <- subset(dt, subset = duplicated(unique.fields))
  return(errors)
})