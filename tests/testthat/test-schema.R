context("Schema")

describe("SchemaRule", {
  it("checks column names and rules defined through columns and rules list", {
    dt <- data.table(id = c(1L, 2L, 3L, 3L, NA_integer_, 20L), 
                     name = c("a", "b", NA_character_, "d", "x", "!"), 
                     type = c("", "b", "z", "c", NA_character_, "a"), 
                     key = "id")
    dt.schema <- Schema(
      "sample.data",
      schema = list(
        list(
          name = "id",
          class = "integer", 
          required = TRUE, # there is one missing record
          unique = TRUE # there is one duplicate record
        ),
        list(
          name = "name",
          class = "character",
          regex = "\\w"
        ),
        list(
          name = "type",
          class = "character",
          enum = c("a", "b", "c")
        )
      ),
      rules = list(
        newConditionRule("id", "< 10")
      )
    )
  
    
    res <- validate(dt.schema, dt)
    
    expect_equal(nrow(res), 6L)
    expect_equal(res[type == "Condition", value], "20")
    expect_equal(res[type == "Regex", ref], 20)
    expect_equal(res[type == "Unique", value], "3")
    expect_equal(res[type == "Required", value], NA_character_)
    expect_equal(res[type == "Enum", ref], c(1, 3))

    setnames(dt, "id", "id_new") 
    expect_error(validate(dt.schema, dt), regexp = "id", 
                 label = "missing column name is mentioned in the error")
    
    dt[, id := as.numeric(id_new)] 
    expect_error(validate(dt.schema, dt), regexp = "\\[id\\].*integer", 
                 label = "column with the wrong type is mentioned in the error")
    
  })
})