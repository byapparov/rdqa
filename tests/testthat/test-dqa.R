library(DBI)
library(RSQLite)
library(data.table)

context("Logging")


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

})

# Post logging test cleanup
if(file.exists("test.db")) file.remove("test.db")


context("Validation")
test_that("Validation empty field validate works", {
  dt <- data.table(id = c(1, 2, 3, 4), 
                   values = c("a", NA_character_, NA_character_, "d"))
  
  rule <- newRequiredRule("id", "values")
  errors <- validate(rule, dt)

  expect_identical(nrow(errors), 2L)
  expect_identical(errors$id, c(2, 3))
  
})

test_that("Regex rule validation works", {
  dt <- data.table(id = c(1, 2, 3, 4), 
                   values = c("abc", "ab1", "cb2", "xac"))
  
  rule <- newRegexRule("id", "values", "b")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 3L)
  
  rule <- newRegexRule("id", "values", "[0-9]")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 2L)
  
})

test_that("Unique rule validation works", {
  dt <- data.table(id = c(1, 2, 2, 4), 
                   values = c("abc", "ab1", "cb2", "xac"))
  
  rule <- newUniqueRule("id", "id")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 1L)
  
})
