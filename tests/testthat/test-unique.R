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
