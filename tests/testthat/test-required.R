context("Required rule")

describe("RequiredRule", {
  it("RequiredRule finds missing values", {
    dt <- data.table(
      id = c(1, 2, 3, 4),
      values = c("a", NA_character_, NA_character_, "d"),
      key = "id"
    )

    rule <- newRequiredRule("values")
    errors <- validate(rule, dt)

    expect_identical(nrow(errors), 2L)
    expect_identical(errors$id, c(2, 3))

    dt <- data.table(
      id = c(1, 2, 3, 4, 5),
      values = c("a", NA_character_, NA_character_, "", "e"),
      key = "id"
    )
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 3L)
    expect_identical(errors$id, c(2, 3, 4))
  })
})
