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
Schema <- function(source, schema, rules) {
  
  schema.rules <- list()
  rules.index <- 1L
  
  for (column in schema) {
    if (!is.null(column$regex)) {
      r <- newRegexRule(column$name, column$regex)
      schema.rules[[rules.index]] <- r
      rules.index <- rules.index + 1L
    }
    if (!is.null(column$unique) && column$unique) {
      r <- newUniqueRule(column$name)
      schema.rules[[rules.index]] <- r
      rules.index <- rules.index + 1L
    }
    if (!is.null(column$required) && column$required) {
      r <- newRequiredRule(column$name)
      schema.rules[[rules.index]] <- r
      rules.index <- rules.index + 1L
    }
    if (!is.null(column$enum)) {
      assert_that(is.character(column$enum), 
                  length(column$enum) > 0)
      r <- newEnumRule(column$name, column$enum)
      schema.rules[[rules.index]] <- r
      rules.index <- rules.index + 1L
    }
  }
  rules <- append(rules, schema.rules)
  
  new("Schema", source = source, schema = schema, rules = rules)
}


#' Validates data.table against the container of rules
#'
#' @export
#' @include rules.R
#' @param conn connection to the database
#' @param container container with data rules
#' @param dt data.table that should be validated
#' @param url.pattern if provided, it will be used to generated url
#' @return list of boolen values for each successful write to the database
setMethod("validateRules", signature("DBIConnection", "Schema", "data.table"), function(conn, container, dt, 
                                                                                        url.pattern = NA_character_) {
  for (column in container@schema) {
    
    assert_that(column$name %in% names(dt), 
                msg = paste0("column not found in source", container@source, ":", column$name))
    
    actual.classes <- class(dt[, get(column$name)])
    assert_that(column$class %in% actual.classes, 
                msg = paste0("column [", column$name, "](", actual.classes,")", 
                             " is not of required class: (", column$class, ")"))
    
  }
  callNextMethod()
})
