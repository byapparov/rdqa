library(DBI)
library(RSQLite)
library(data.table)

setupDqaDb <- function() {
  # Set up the test db environment
  if(file.exists("test.db")) file.remove("test.db")
  conn <- dbConnect(dbDriver("SQLite"), "test.db") # makes a new file
  error.record <- data.frame(list(date = Sys.time(),
                                  source = "sample.system",
                                  type = "Wrong Value",
                                  rule = "Positive Value",
                                  ref = 0,
                                  value  = - 10,
                                  url = "http://test.com/test"))
  dbWriteTable(conn, "errors", error.record)
  dbDisconnect(conn)
}

context("Logging")

setupDqaDb()

test_that("Records are logged correctly to the errors table", {
  conn <-  dbConnect(dbDriver("SQLite"), "test.db")
  source <- "test.system"
  type <- "Wrong"
  rule <- "Value should greate than zero"
  refs <- c(1, 2, 3) # Primary keys
  values <- c(0, 0, 0) # Wrong values
  logWrongValues(conn, source, type, rule, refs, values)

  res <- dbGetQuery(conn, "SELECT COUNT(*) as cnt FROM errors WHERE source = 'test.system'")
  expect_identical(res[1, 1], 3L)
  dbDisconnect(conn)
})

# Post logging test cleanup
if(file.exists("test.db")) file.remove("test.db")


context("Rules container logs errors")

setupDqaDb()

#' @include test-dqa.R
test_that("Rules container validates all rules", {
  # Define data
  dt <- data.table(id = c(1, 2, 2, 4),
                   values = c("abc", "ab1", "cb2", "xac"),
                   key = "id")

  # Define rules and container
  rule.unique <- newUniqueRule("id") # we have one duplicate record
  rule.regex <- newRegexRule("values", "[0-9]") # two records don't match
  rules <- newRulesContainer(source = "test.data", rule.unique, rule.regex)

  # Connect to the database and execute the validation
  conn <- dbConnect(dbDriver("SQLite"), "test.db") # makes a new file
  res <- validateRules(conn, rules, dt)

  # Check that database contains expected results
  res <- dbGetQuery(conn, "SELECT * FROM errors")

  expect_identical(nrow(subset(res, type == "Regex")), 2L)
  expect_identical(nrow(subset(res, type == "Unique")), 1L)

  dbDisconnect(conn)
})

# Post logging test cleanup
if(file.exists("test.db")) file.remove("test.db")
