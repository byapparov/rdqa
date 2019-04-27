
#' @include rules.R
setClass("RequiredRule", contains = "FieldRule")

#' Factory method for required rule
#'
#' @export
#' @param field name of the field to be validated
#' @return new required rule
newRequiredRule <- function(field) {
  dt <- new(
    "RequiredRule",
    name = paste0("Field [", field, "] should not be empty"),
    type = "Required",
    field = field
  )
  return(dt)
}

#' @rdname validate
#' @return for `RequiredRule` records where target field is NA or zero-length.
setMethod("validate", signature("RequiredRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <-  subset(dt, is.na(get(rule@field)) | nchar(get(rule@field)) == 0)
  return(errors)
})
