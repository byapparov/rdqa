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
#' @param ... data rules that should be executed against the data.
#' If first element is a list, it will be used as container of rules
#' @return container with rules
newRulesContainer <- function(source, ...) {
  rules = list(...)
  if(is.list(rules[[1]])){
    rules <- rules[[1]]
  }
  rules <- new("rulesContainer", source = source, rules = rules)
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
#' @return list of boolen values for each successful write to the database
setMethod("validateRules", signature("DBIConnection", "rulesContainer", "data.table"), function(conn, container, dt) {
  res <- lapply(container@rules, function(r) {
     errors <- validate(r, dt)
     n <- nrow(errors)

     # Skip logging if there are no errors
     if (n == 0L) return (FALSE)

     logWrongValues(conn = conn,
                    source = container@source,
                    type = r@type,
                    rule = r@name,
                    refs = subset(errors, subset = rep(T, n), select = get(key(errors))),
                    values = getValues(r, errors)
     )
  })
})