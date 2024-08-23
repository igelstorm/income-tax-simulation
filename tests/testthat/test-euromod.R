test_that("euromod_command", {
  result <- euromod_command(
    system = "UK_1901",
    dataset = "UK_1901.txt",
    model_path = "modelpath",
    wd = "currentdir"
  )
  expected <- paste(
    "cd currentdir",
    "euromod_run, model(\"modelpath\") system(UK_1901) dataset(UK_1901.txt) country(UK)",
    "cd currentdir",
    sep = "\n"
  )
  expect_equal(result, expected)
})

test_that("euromod_command with one constant override", {
  result <- euromod_command(
    system = "UK_1901",
    dataset = "UK_1901.txt",
    model_path = "modelpath",
    constants = list(
      SomeConstant = "a_value"
    ),
    wd = "currentdir"
  )
  expected <- paste(
    "cd currentdir",
    "euromod_run, model(\"modelpath\") system(UK_1901) dataset(UK_1901.txt) country(UK) constants(\"SomeConstant = 'a_value'\")",
    "cd currentdir",
    sep = "\n"
  )
  expect_equal(result, expected)
})

test_that("euromod_command with multiple constant overrides", {
  result <- euromod_command(
    system = "UK_1901",
    dataset = "UK_1901.txt",
    model_path = "modelpath",
    constants = list(
      SomeConstant = "a_value",
      AnotherConstant = "another_value",
      OneMore = "some_value"
    ),
    wd = "currentdir"
  )
  expected <- paste(
    "cd currentdir",
    "euromod_run, model(\"modelpath\") system(UK_1901) dataset(UK_1901.txt) country(UK) constants(\"SomeConstant = 'a_value'\" \"AnotherConstant = 'another_value'\" \"OneMore = 'some_value'\")",
    "cd currentdir",
    sep = "\n"
  )
  expect_equal(result, expected)
})
