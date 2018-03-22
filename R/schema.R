library(data.table)
#' Class that allows to combine rules into a container
#'
#' @include rules.R
setClass("Schema", contains = "rulesContainer",
         representation(source = "character",
                        schema = "list",
                        rules = "list")
)


#' Creates new rules container from rules
#'
#' @export
#' @param source data source of the data
#' @param schema list of data fields with names, types and rules (unique, regex, required)
#' @param rules list of data rules
#' If first element is a list, it will be used as container of rules
#' @return container with rules
Schema <- function(source, schema, rules = list()) {
  
  for (column in schema) {
    column.rules <- extractFieldRules(column)
    rules <- append(rules, column.rules)
  }
  new("Schema", source = source, schema = schema, rules = rules)
}


#' Validates data.table against the container of rules
#'
#' @export
#' @include rules.R
#' @param rule schema for the datas source
#' @param dt data.table that should be validated
#' @param conn connection to the database
#' @param url.pattern if provided, it will be used to generated url
#' @return list of boolen values for each successful write to the database
setMethod("validate", c(rule = "Schema", dt = "data.table"), 
  function(rule, dt, conn = NULL, url.pattern = NA_character_) {

    for (column in rule@schema) {
    
      assert_that(column$name %in% names(dt), 
                  msg = paste0("column not found in source", rule@source, ":", column$name))
      actual.classes <- class(dt[, get(column$name)])
      assert_that(column$class %in% actual.classes, 
                  msg = paste0("column [", column$name, "](", actual.classes,")", 
                               " is not of required class: (", column$class, ")"))
      
    }
    
    callNextMethod()
  
  })


#' Extracts field levels rumes
#' @noRd
#' @param column column specification from the schema
extractFieldRules <- function(column) {
  rules <- list()
  
  if (!is.null(column$regex)) {
    rules <- append(rules, newRegexRule(column$name, column$regex))
  }
  if (!is.null(column$unique) && column$unique) {
    rules <- append(rules, newUniqueRule(column$name))
  }
  if (!is.null(column$required) && column$required) {
    rules <- append(rules, newRequiredRule(column$name))
  }
  if (!is.null(column$enum)) {
    assert_that(is.character(column$enum), 
                length(column$enum) > 0)
    rules <- append(rules, newEnumRule(column$name, column$enum))
  }
  rules
}

