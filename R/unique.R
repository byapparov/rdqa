
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



#' @rdname validate
#' @return for `UniqueRule` records where values in target field(s) are duplicated.
setMethod("validate", signature("UniqueRule", "data.table"), function(rule, dt) {
  callNextMethod()
  unique.fields <- subset(dt, select = rule@fields)
  setkeyv(unique.fields, cols = rule@fields)
  errors <- subset(dt, subset = duplicated(unique.fields))
  return(errors)
})