
#' @include rules.R
setClass("RequiredRule", contains = "FieldRule")

newRequiredRule <- function(ref, field) {
  dt <- new("RequiredRule", name = paste0("Field ", field, "should ont be empty"), 
            ref = ref, 
            type = "Empty",
            field = field)
  return(dt)
}

# Validates data.table for the empty field rule
setMethod("validate", signature("RequiredRule", "data.table"), function(rule, dt) {
  errors <- subset(dt, is.na(get(rule@field)))
  return(errors)
})