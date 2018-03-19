context("table schema")

describe("SchemaRule", {
  it("checks column names and rules defined through columns and rules list", {
    dt <- data.table(id = c(1L, 2L, 3L, 3L, NA_integer_, 20L), name = c("a", "b", NA_character_, "d", "!", "x"), key = "id")
    dt.schema <- newSchema(
      "sample.data",
      schema = list(
        list(
          name = "id",
          class = "integer", 
          required = TRUE,
          unique = TRUE
        ),
        list(
          name = "name",
          class = "character",
          regex = "\\w"
        )
      ),
      rules = list(
        newConditionRule("id", "< 10")
      )
    ) # we have one duplicate record

    conn <- dbConnect(dbDriver("SQLite"), "test.db") # makes a new file
    res <- validateRules(conn, dt.schema, dt)

    errors <- validate(dt.schema, dt)
    
    setnames(dt, "id", "id_new") 
    expect_error(validateRules(conn, dt.schema, dt), regexp = "id", 
                 label = "missing column name is mentioned in the error")
    
    dt[, id := as.numeric(id_new)] 
    expect_error(validateRules(conn, dt.schema, dt), regexp = "\\[id\\].*integer", 
                 label = "column with the wrong type is mentioned in the error")
    res <- dbGetQuery(conn, "SELECT * FROM errors")
    
    dbDisconnect(conn)
    
    res <- data.table(res)
    expect_equal(nrow(res), 4)
    expect_equal(res[type == "Condition", value], "20")
    expect_equal(res[type == "Regex", value], "!")
    expect_equal(res[type == "Unique", value], "3")
    expect_equal(res[type == "Required", value], NA_character_)
  })
})