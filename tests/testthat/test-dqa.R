library(DBI)
library(RSQLite)

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

# Post test cleanup
if(file.exists("test.db")) file.remove("test.db")
