library(data.table)
library(foreach)
library(withr)
# Also required:
# - R.utils
# - here
# - sys

first_year  <- 2024
last_year   <- 2035
population  <- 20000
runs        <- 10

simpaths_path <- R.utils::getAbsolutePath(here::here("../SimPaths"))
results_root_path <- here::here("intermediate", "simpaths")

euromod_file_path <- file.path(simpaths_path, "input", "EUROMODoutput")

scenarios <- c("baseline", "mis", "flat", "dk")

for (scenario in scenarios) {
  timestamp()
  print(scenario)
  if (dir.exists(results_path <- file.path(results_root_path, scenario))) {
    print("Already run")
    next
  }
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    file.remove()

  euromod_files <- here::here("intermediate", "euromod", scenario) |>
    list.files(full.names = TRUE)
  file.copy(euromod_files, euromod_file_path)
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    print()

  with_dir(simpaths_path, sys::exec_wait("java", c(
    "-jar", "singlerun.jar",
    "-c", "UK",
    "-s", format(first_year),
    "-g", "false",
    "-Setup"
  )))

  with_dir(simpaths_path, sys::exec_wait("java", c(
    "-jar", "multirun.jar",
    "-r", "100",    # random seed
    "-p", format(population, scientific = FALSE),
    "-n", format(runs, scientific = FALSE),
    "-s", format(first_year),
    "-e", format(last_year),
    "-g", "false",
    "-f"
  )))

  latest_output_dir <- list.files(file.path(simpaths_path, "output")) |>
    setdiff("logs") |>
    sort() |>
    tail(n = 1)

  print(latest_output_dir)
  output_path <- file.path(simpaths_path, "output", latest_output_dir, "csv")
  output_files <- list.files(output_path, full.names = TRUE, recursive = TRUE)
  dir.create(results_path, recursive = TRUE)
  file.copy(
    output_files,
    results_path
  )
  writeLines(latest_output_dir, file.path(results_path, "output_dir.txt"))

  timestamp()
}
