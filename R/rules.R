#' @import methods
#' @import assertthat

library(data.table)
library(assertthat)

#' Top level class to define data rule
setClass(
  "DataRule",
  representation(
    name = "character",
    ref = "character",
    type = "character"
  )
)

#' Validates data in a data.table
#' @import data.table
#' @export
#' @param rule data rule that will be used to find records with errors
#' @param dt data to be validated
#' @param ... allows to extend validate function for new data rules
#' @return subset of the original data that contains errors
setGeneric("validate", function(rule, dt, ...) standardGeneric("validate"))


#' @rdname validate
setMethod("validate", signature("DataRule", "data.table"), function(rule, dt) {
  # check that key is set and it is only one field
  assert_that(length(key(dt)) == 1)
})


#' Gets value(s) that contribute to rule vialation in a data.table
#'
#' @param rule data rule that will be used to determine how to make the vector of values
#' @param errors data.table that only contains records with errors
#' @return vector of values that represent invalid records
setGeneric("getValues", function(rule, errors) standardGeneric("getValues"))


setMethod(
  "getValues",
  signature("DataRule", "data.table"),
  function(rule, errors) {
    subset.data.frame(
      errors,
      subset = rep(T, nrow(errors)),
      select = get(key(errors))
    )
  }
)


#' Higher level class for errors that are at the record level, e.g. missing or duplicate
setClass("RecordRule", contains = "DataRule")

#' Higher level class for errors that are at field level
setClass(
  "FieldRule",
  contains = "DataRule",
  representation(field = "character")
)

setMethod("getValues", signature("FieldRule", "data.table"), function(rule, errors) {
  field <- rule@field
  values <- subset(errors, select = get(field))
  return(values[[1]])
})


#' Class to validate the primariy key constraint
#' Finds and logs missing records in the referenced table
setClass("PrimaryKeyRule", contains = "RecordRule")
