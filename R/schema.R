library(data.table)
#' Class that allows to combine rules into a container
#'
#' @include rules.R
setClass("Schema", contains = "RulesContainer",
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
Schema <- function(source, schema, rules = list()) { #nolint
  assert_that(is.string(source), is.list(schema), is.list(rules))

  for (column in schema) {
    column.rules <- extractFieldRules(column)
    rules <- append(rules, column.rules)
  }
  new("Schema", source = source, schema = schema, rules = rules)
}

#' @rdname validate
#' @include rules.R
#' @return for `Schema` same as RulesContainer
setMethod(
  "validate",
  c(rule = "Schema", dt = "data.table"),
  function(rule, dt, conn = NULL, url.pattern = NA_character_) {

    for (column in rule@schema) {
      assert_that(
        column$name %in% names(dt),
        msg = paste0(
          "column not found in source",
          rule@source, ":", column$name
          )
      )
      actual.classes <- class(dt[, get(column$name)])
      assert_that(
        column$class %in% actual.classes,
        msg = paste0(
          "column [", column$name, "](", actual.classes, ")",
          " is not of required class: (", column$class, ")")
        )
    }

    callNextMethod()
  }
)


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
