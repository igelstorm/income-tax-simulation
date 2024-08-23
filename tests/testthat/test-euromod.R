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
