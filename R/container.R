library(data.table)
#' Class that allows to combine rules into a container
#'
#' @include rules.R
setClass("RulesContainer", contains = "DataRule",
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
  if (is.list(rules[[1]])) {
    rules <- rules[[1]]
  }
  new("RulesContainer", source = source, rules = rules)
}


#' Validates data using rules within the rule container
#'
#' @param conn connection to the database
#' @param container container with rules
#' @param dt data to be validated
#' @param url.pattern if provided, it will be used to generated url
setGeneric("validateRules", function(conn, container, dt, url.pattern = NA_character_) standardGeneric("validateRules"))

#' @include rules.R
#' @rdname validate
#' @param conn connection to the database
#' @param url.pattern if provided, it will be used to generated url
#' @return for `RulesContainer` error records with value of key column, target column and rule type
setMethod("validate", signature("RulesContainer", "data.table"), 
  function(rule, dt, conn = NULL, url.pattern = NA_character_) {
    output <- lapply(rule@rules, function(r) {
       errors <- validate(r, dt)
       n <- nrow(errors)
  
       # Skip logging if there are no errors
       if (n == 0L) return(NULL)
        
       refs = subset(errors, subset = rep(T, n), select = get(key(errors)))
       values = getValues(r, errors)
       if (!is.null(conn)) {
         logWrongValues(conn = conn,
                        source = rule@source,
                        type = r@type,
                        rule = r@name,
                        refs = refs,
                        values = values,
                        url.pattern)
       }
       data.table(refs = refs,
                  values = values,
                  type = r@type)
       
    })
    res <- rbindlist(output)
    if (!nrow(res) > 0) return(data.table(ref = character(), value = character(), type = character()))
    names(res) <- c("ref", "value", "type")
    res
})
