library(data.table)
#' Class that allows to combine rules into a container
#'
#' @include rules.R
setClass("rulesContainer", contains = "DataRule",
          representation(source = "character",
                         rules = "list")
)

#' Creates new rules container from rules
#' 
#' @export
#' @param source data source of the data
#' @param ... data rules that should be executed against the data
#' @return container with rules
newRulesContainer <- function(source, ...) {
  rules <- new("rulesContainer", source = source, rules = list(...))
}

#' Validates data using rules within the rule container
#'
#' @param conn connection to the database
#' @param container container with rules
#' @param dt data to be validated
setGeneric("validateRules", function(conn, container, dt) standardGeneric("validateRules"))

#' Validates data.table against the container of rules
#' 
#' @export
#' @include rules.R
#' @param conn connection to the database
#' @param container container with data rules
#' @param dt data.table that should be validated
setMethod("validateRules", signature("DBIConnection", "rulesContainer", "data.table"), function(conn, container, dt) {
  res <- lapply(container@rules, function(r) {
     errors <- validate(r, dt)
     n <- nrow(errors)
     logWrongValues(conn = conn,
                    source = container@source,
                    type = r@type,
                    rule = r@name,
                    refs = subset.data.frame(errors, subset = rep(T, n), select = get(key(errors))),
                    values = subset.data.frame(errors, subset = rep(T, n), select =get(key(errors)))
     )
  })
})