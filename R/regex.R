

#' @include rules.R
setClass("RegexRule", contains = "FieldRule", representation(pattern = "character"))


newRegexRule <- function(ref, field, pattern) {
  dt <- new("RegexRule", name = paste0("Field ", field, " should matrch pattern ", pattern), 
            ref = ref, 
            type = "Empty",
            field = field,
            pattern = pattern)
  return(dt)
}



# Validates data.table for regex field rule
setMethod("validate", signature("RegexRule", "data.table"), function(rule, dt) {
  errors <- subset(dt, grepl(rule@pattern, get(rule@field)))
  return(errors)
})
