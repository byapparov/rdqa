library(data.table)
library(assertthat)

#' Top level class to define data rule
setClass("DataRule", representation(name = "character",
                                      ref = "character",
                                      type = "character")
         )

#' Validates data in a data.table
#'
#' @param rule data rule that will be used to find records with errors
#' @param dt data to be validated
#' @return subset of the original data that contains errors
setGeneric("validate", function(rule, dt) standardGeneric("validate"))

#' Checks that rule and data.table are valid
#'
#' callNextMethod() should be called from all overloads of this method
#'
#' @param rule data rule that will be used to find records with errors
#' @param dt data to be validated
#' @return subset of the original data that contains errors
setMethod("validate", signature("DataRule", "data.table"), function(rule, dt) {
  # check that key is set
  assert_that(length(key(dt)) > 0)
})

setGeneric("logErros", function(rule, dt) standardGeneric("logErros"))

#' Higher level class for errors that are at the record level, e.g. missing or duplicate
setClass("RecordRule", contains = "DataRule")

#' Higher level class for errors that are at field level
setClass("FieldRule", contains = "DataRule", representation(field = "character"))

#' Class to describe foreign key rules
setClass("ForeignKeyRule", contains = "FieldRule")

#' Class to validate the primariy key constraint
#' Finds and logs missing records in the referenced table
setClass("PrimaryKeyRule", contains = "RecordRule")



