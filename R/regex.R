

#' @include rules.R
setClass("RegexRule", contains = "FieldRule", representation(pattern = "character"))


newRegexRule <- function(field, pattern) {
  rule <- new("RegexRule", name = paste0("Field [", field, "] should matrch pattern ", pattern),
            type = "Regex",
            field = field,
            pattern = pattern)
  return(rule)
}

# Validates data.table for regex field rule
setMethod("validate", signature("RegexRule", "data.table"), function(rule, dt) {
  errors <- subset(dt, !grepl(rule@pattern, get(rule@field)))
  errors$rule <- rule@name
  errors$type <- rule@type
  return(errors)
})
