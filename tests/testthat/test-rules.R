context("Validation with rules")

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

test_that("Unique rule validation works", {
  dt <- data.table(id = c(1, 2, 2, 4),
                   values = c("abc", "ab1", "cb2", "xac"),
                   key = "id")

  rule <- newUniqueRule("id")
  errors <- validate(rule, dt)
  expect_identical(nrow(errors), 1L)

})

test_that("Execution fails if key on the data.table is not set", {
  dt <- data.table(id = c(1, 2, 2, 4),
                   values = c("abc", "ab1", "cb2", "xac"))
  rule <- newUniqueRule("id")
  expect_error( errors <- validate(rule, dt))
})

