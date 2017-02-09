context("Data reference")
test_that("Execution fails if key on the data.table is not set", {
  dt <- data.table(id = c(1, 2, 2, 4),
                   values = c("abc", "ab1", "cb2", "xac"))
  rule <- newUniqueRule("id")
  expect_error( errors <- validate(rule, dt))
})  

test_that("Execution fails if key on the data.table is multiple columns", {
  dt <- data.table(id1 = c(1, 2, 2, 4),
                   id2 = c(1, 2, 2, 4),
                   values = c("abc", "ab1", "cb2", "xac"),
                   key = c("id1", "id2"))
  rule <- newUniqueRule("values")
  expect_error(errors <- validate(rule, dt))
  
})

context("Required rule")
test_that("Validation for reqauired field works", {
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

context("Regex rule")
test_that("Regex rule validation works", {
  dt <- data.table(id = c(1, 2, 3, 4),
                   values = c("abc", "ab1", "cb2", "xac"),
                   key = "id")

  rule <- newRegexRule("values", "b")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 1L)

  rule <- newRegexRule("values", "[0-9]")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 2L)

})

context("Unique rule")
test_that("Unique rule validation works", {
  dt <- data.table(id = c(1, 2, 2, 4),
                   values = c("abc", "ab1", "cb2", "xac"),
                   key = "id")

  rule <- newUniqueRule("id")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 1L)

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

test_that("Execution of static condition rule works", {
  dt <- data.table(id = c(1, 1, 2, 3, 4),
                   values = c("abc", "ab1", "cb2", "xac", "yac"),
                   key = "id")
  # Check it works agains a constant
  rule <- newConditionRule("id", condition = " >= 2")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 2L)
})

test_that("Execution of reference condition rule works", {
  # Check condition rule works agains another field
  dt <- data.table(id = c(1, 2, 3, 4, 5),
                   small = c(1, 10, 2, 3, 4),
                   big = c(10, 1, 20, 30, 40),
                   key = "id")
  rule <- newConditionRule("small", condition = "< big")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 1L)
})