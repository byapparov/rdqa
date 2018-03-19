library(data.table)

context("Unique rule")

describe("UniqueRule", {
  it("finds a duplicate records", {
    dt <- data.table(id = c(1, 2, 2, 4),
                     values = c("abc", "ab1", "cb2", "xac"),
                     key = "id")
    
    rule <- newUniqueRule("id")
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 1L)
    expect_identical(errors$values, "cb2")
    
  })
  it("it finds several duplicated values", {
    rule <- newUniqueRule("big")
    dt <- data.table(id = c(1, 2, 3, 4, 5),
                     small = c(1, 10, 2, 3, 4),
                     big = c(10, 1, 20, 20, 20),
                     name = c("a", "", "c", "d", NA_character_),
                     key = "id")
    errors <- validate(rule, dt)
    expect_identical(errors$id, c(4, 5))
  })
  it("finds duplicates in several columns", {
    dt <- data.table(id =    c(1,  2, 3,  2,  2),
                     small = c(1, 10, 2, 10, 30),
                     big = c(10, 1, 20, 20, 20),
                     key = "id")
    rule <- newUniqueRule(c("id", "small"))
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 1L)
    expect_identical(errors$id, 2)
  })
  it("fails if key on the target data.table is not set", {
    dt <- data.table(id = c(1, 2, 2, 4),
                     values = c("abc", "ab1", "cb2", "xac"))
    rule <- newUniqueRule("id")
    expect_error(errors <- validate(rule, dt))
  })
  it("fails if key on the data.table is multiple columns", {
    dt <- data.table(id1 = c(1, 2, 2, 4),
                     id2 = c(1, 2, 2, 4),
                     values = c("abc", "ab1", "cb2", "xac"),
                     key = c("id1", "id2"))
    rule <- newUniqueRule("values")
    expect_error(errors <- validate(rule, dt))
  })
})

context("Required rule")

describe("RequiredRule", {
  it("RequiredRule finds missing values", {
    dt <- data.table(id = c(1, 2, 3, 4),
                     values = c("a", NA_character_, NA_character_, "d"), key = "id")
    
    rule <- newRequiredRule("values")
    errors <- validate(rule, dt)
    
    expect_identical(nrow(errors), 2L)
    expect_identical(errors$id, c(2, 3))
    
    dt <- data.table(id = c(1, 2, 3, 4, 5),
                     values = c("a", NA_character_, NA_character_, "", "e"), key = "id")
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 3L)
    expect_identical(errors$id, c(2, 3, 4))
  })
})


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
    dt <- data.table(id = c(1, 1, 2, 3, 4),
                     values = c("abc", "ab1", "cb2", "xac", "yac"),
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




test_that("Execution of external rule works", {

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