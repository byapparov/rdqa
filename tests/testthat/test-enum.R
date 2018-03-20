context("Enum rule")

describe("Enum rule", {
  it("validates field based on a charecter vector of value", {
    dt <- data.table(
      id = 1:6,
      type = c("small", "BIG", "long", "big", NA_character_, "other"),
      key = "id"
    )
    rule <- newEnumRule("type", c("small", "big", "other"))
    
    errors <- validate(rule, dt)
    expected <- c(2L, 3L)
    expect_equal(errors$id, expected, label = "records not matching enum were identified")
  })
})
