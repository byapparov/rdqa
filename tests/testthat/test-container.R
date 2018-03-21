library(DBI)
library(RSQLite)
library(data.table)

#' Set up the test db environment
setupDqaDb <- function() {

  if (file.exists("test.db")) file.remove("test.db")
  conn <- dbConnect(dbDriver("SQLite"), "test.db") # makes a new file
  error.record <- data.frame(list(date = Sys.time(),
                                  source = "sample.system",
                                  type = "Wrong Value",
                                  rule = "Positive Value",
                                  ref = "0",
                                  value = "-10",
                                  url = "http://test.com/test"))
  dbWriteTable(conn, "errors", error.record)
  dbDisconnect(conn)
}

context("rules container")

setupDqaDb()

describe("rulesContainer", {
  it("can log records to the errors table if connection is provided", {
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
  it("validates several rules at once", {
    # Define data
    dt <- data.table(id = c(1, 2, 2, 4),
                     values = c("abc", "ab1", "cb2", "xac"),
                     key = "id")
    
    # Define rules and container
    rule.unique <- newUniqueRule("id") # we have one duplicate record
    rule.regex <- newRegexRule("values", "[0-9]") # two records don't match
    rules <- newRulesContainer(source = "test.data", rule.unique, rule.regex)
    
    res <- validate(rules, dt)
    
    
    expect_identical(nrow(subset(res, type == "Regex")), 2L)
    expect_identical(nrow(subset(res, type == "Unique")), 1L)
    expect_identical(res$value[res$type == "Regex"], c("abc", "xac"))
  })
  it("generats and logs url to the problem if pattern is provided", {
    # Define data
    dt <- data.table(id = c(1, 2, 2, 4),
                     values = c("abc", "ab1", "cb2", "xac"),
                     key = "id")
    rule.regex <- newRegexRule("values", "[0-9]") # two records don't match
    
    rules <- newRulesContainer(source = "test.data", rule.regex)
    # Connect to the database and execute the validation
    conn <- dbConnect(dbDriver("SQLite"), "test.db") # makes a new file
    res <- validate(rules, dt, conn, url.pattern = "http://myapp.com/object/%s")
    
    res <- dbGetQuery(conn, "SELECT COUNT(*) cnt FROM errors WHERE url LIKE '%myapp%'")
    expect_identical(res[[1]], 2L)
    dbDisconnect(conn)
  })
  it("returns empty data.table if data matches the rules", {
    # Define data
    dt <- data.table(id = c(1, 2, 2, 4),
                     values = c("abc", "ab1", "cb2", "xac"),
                     key = "id")
    rule.unique <- newUniqueRule("values") # we have no duplicate records
    
    rules <- newRulesContainer(source = "test.data", rule.unique)
    res <- validate(rules, dt, conn)
    expect_equal(nrow(res), 0)
  })
})

# Post logging test cleanup
if (file.exists("test.db")) file.remove("test.db")
