
#' External rule allow to use logical permutation vector that defines records
#' that vialate the business rule.
#'
#' @include rules.R
setClass(
  "ExternalRule",
  contains = "FieldRule",
  representation(errors = "logical")
)

#' Creates new external rule, where calculation of the vector that defines erros
#' was done externally.
#'
#' @export
#' @param field name of the field that represents the error record
#' @param errors logical vector that defines records with errors
#' @return new external rule
newExternalRule <- function(field, errors) {
  if (is.data.table(errors)) {
    name <- paste("Wrong data [", paste(names(errors), sep = ", "), "].")
    errors <- unlist(errors)
  } else {
    name <- paste0("Field [", field, "] contains wrong data")
  }

  new(
    "ExternalRule",
    name = name,
    type = "External",
    field = field,
    errors = errors
  )
}


#' @rdname validate
#' @return for `ExternalRule` records defined by TRUE/FALSE vector of permutations.
setMethod(
  "validate",
  signature("ExternalRule", "data.table"),
  function(rule, dt) {
    callNextMethod()
    subset(dt, rule@errors)
  }
)
