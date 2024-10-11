library(data.table)
library(withr)

simpaths_path <- R.utils::getAbsolutePath("../SimPaths")

file.remove(file.path(simpaths_path))

euromod_file_path <- file.path(simpaths_path, "input","EUROMODoutput")

euromod_file_path |>
  list.files(pattern = "\\.txt$", full.names = TRUE) |>
  file.remove()

euromod_files <- file.path("intermediate", "euromod", "baseline") |>
  list.files(full.names = TRUE)
file.copy(euromod_files, euromod_file_path)

with_dir(simpaths_path, sys::exec_wait("java", c(
  "-jar", "singlerun.jar",
  "-c", "UK",
  "-s", "2023",
  "-g", "false",
  "-Setup",
  "--rewrite-policy-schedule"
)))

with_dir(simpaths_path, sys::exec_wait("java", c(
  "-jar", "multirun.jar",
  "-r", "100",
  "-p", "1000",
  "-n", "2",
  "-s", "2023",
  "-e", "2024",
  "-g", "false",
  "-f"
)))

latest_output_dir <- list.files(file.path(simpaths_path, "output")) |>
  setdiff("logs") |>
  sort() |>
  tail(n = 1)

person_data <- fread(file.path(simpaths_path, "output", latest_output_dir, "csv", "Person.csv"))
person_data
