
#' @include rules.R
#'
#' @slot fields vector of columns that defines unique field set.
setClass("UniqueRule", contains = "RecordRule", representation(fields = "character"))

newUniqueRule <- function(fields) {
  dt <- new("UniqueRule", name = paste0("Field(s) ", fields, " should be uqniue"),
            type = "Unique",
            fields = fields)
  return(dt)
}

#' Validates field in a data.table is unique
setMethod("validate", signature("UniqueRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <- subset(dt, duplicated(get(rule@fields)))
  errors$rule <- rule@name
  errors$type <- rule@type
  return(errors)
})