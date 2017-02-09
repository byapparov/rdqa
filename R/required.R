
#' @include rules.R
setClass("RequiredRule", contains = "FieldRule")

newRequiredRule <- function(field) {
  dt <- new("RequiredRule", name = paste0("Field ", field, "should ont be empty"),
            type = "Required",
            field = field)
  return(dt)
}

# Validates data.table for the empty field rule
setMethod("validate", signature("RequiredRule", "data.table"), function(rule, dt) {
  callNextMethod()
  errors <-  subset(dt, is.na(get(rule@field)))
  return(errors)
})
