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
  it("validates data using expression", {
    dt <- data.table(id = c(1, 1, 2, 3, 4, NA_real_),
                     name = c("abc", "ab1", "very-long-string", "xac", "yac", ""),
                     key = "id")
    # Check it works agains a constant
    rule <- newConditionRule("id", condition = expression(nchar(name) <= 10))
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 1L) 
    expect_identical(errors$name, "very-long-string")
  })
  it("validates rules on several fields without taking into account NA values", {
    dt <- data.table(id = c(1, 1, 2, 3, 4, NA_real_),
                   values = c("abc", "ab1", "very-long-string", "xac", "yac", ""),
                   key = "id")
    # Check it works agains a constant
    rule <- newConditionRule("id", condition = expression(nchar(values) <= 10 & id > 1))
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 3L) 
  })
  it("validates rules on several fields and NA can be flagged explicitely", {
    dt <- data.table(id = c(1, 1, 2, 3, 4, NA_real_),
                   values = c("abc", "ab1", "very-long-string", "xac", "yac", ""),
                   key = "id")
    # Check it works agains a constant
    rule <- newConditionRule("id", condition = expression(nchar(values) <= 10 & id > 1 & !is.na(id)))
    errors <- validate(rule, dt)
    expect_identical(nrow(errors), 4L) 
  })
})
