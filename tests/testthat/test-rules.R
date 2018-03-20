library(data.table)

context("Regex rule")

describe("RegexRule finds non-NA records that don't match regular expresion", {
  it("Regex rule validation works", {
    dt <- data.table(id = c(1, 2, 3, 4, 5),
                     values = c("abc", "ab1", "cb2", "xac", NA_character_),
                     key = "id")
    
    rule <- newRegexRule("values", "b")
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 1L)
    
    rule <- newRegexRule("values", "[0-9]")
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 2L)
    
  })
})

context("Foreign key rule")

test_that("Execution of foreign key rule returns correct results", {
  dt <- data.table(id = c(1, 2, 2, 4),
                   values = c("abc", "ab1", "cb2", "xac"),
                   key = "id")
  rule <- newForeignKeyRule("values", primary.key = c("abc", "bcd", "xac"))

  errors <- validate(rule, dt)

  expect_identical(nrow(errors), 2L)

})

context("Condition rule")

describe("ConditionRule", {
  it("finds values that don't match a give condition", {
    dt <- data.table(id = c(1, 1, 2, 3, 4, NA_real_),
                     values = c("abc", "ab1", "cb2", "xac", "yac", ""),
                     key = "id")
    # Check it works agains a constant
    rule <- newConditionRule("id", condition = " >= 2")
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 2L)
  })
  it("finds records that don't match reference condition rule", {
    # Check condition rule works agains another field
    dt <- data.table(id = c(1, 2, 3, 4, 5),
                     small = c(1, 10, 2, 3, 4),
                     big = c(10, 1, 20, 30, 40),
                     key = "id")
    rule <- newConditionRule("small", condition = "< big")
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 1L)
  })
})

context("External rule")
describe("ExternalRule", {
  it("creates error records based on error vector or data.table permutation", {
    dt <- data.table(id = c(1, 2, 3, 4, 5),
                     values = c(1, 10, 2, 3, 4),
                     key = "id")
    rule <- newExternalRule("values", errors = c(T, F, T, F, T))
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 3L)
    
    rule <- newExternalRule("values", errors = data.table("bad.values" = c(T, F, T, F, T)))
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 3L)
  })
})
