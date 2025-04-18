library(data.table)
library(foreach)
library(withr)
# Also required:
# - R.utils
# - here
# - sys

first_year  <- 2024
last_year   <- first_year + 9
population  <- 100000
runs        <- 20

simpaths_path <- R.utils::getAbsolutePath(here::here("../SimPaths"))

euromod_file_path <- file.path(simpaths_path, "input","EUROMODoutput")

scenarios <- c("baseline", "mis", "flat", "dk")

output <- foreach(scenario = scenarios) %do% {
  timestamp()
  print(scenario)
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    print()
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    file.remove()
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    print()

  euromod_files <- here::here("intermediate", "euromod", scenario) |>
    list.files(full.names = TRUE)
  print(euromod_files)
  file.copy(euromod_files, euromod_file_path)
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    print()

  with_dir(simpaths_path, sys::exec_wait("java", c(
    "-jar", "singlerun.jar",
    "-c", "UK",
    "-s", format(first_year),
    "-g", "false",
    "-Setup",
    "--rewrite-policy-schedule"
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

  timestamp()
  print(latest_output_dir)
  data.table(
    scenario = scenario,
    simpaths_output = latest_output_dir
  )
}

rbindlist(output) |>
  fwrite("intermediate/simpaths_directories.csv")
