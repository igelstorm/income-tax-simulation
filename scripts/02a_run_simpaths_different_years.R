library(data.table)
library(foreach)
library(withr)

simpaths_path <- R.utils::getAbsolutePath("../SimPaths")

euromod_file_path <- file.path(simpaths_path, "input","EUROMODoutput")

scenarios <- c("baseline", "mis", "flat")
start_years <- 2020:2024

output <- foreach(start_year = start_years) %do% {
  timestamp()
  print(start_year)
  scenario <- "baseline"
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    print()
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    file.remove()
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    print()

  euromod_files <- file.path("intermediate", "euromod", scenario) |>
    list.files(full.names = TRUE)
  print(euromod_files)
  file.copy(euromod_files, euromod_file_path)
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    print()

  with_dir(simpaths_path, sys::exec_wait("java", c(
    "-jar", "singlerun.jar",
    "-c", "UK",
    "-s", as.character(start_year),
    "-g", "false",
    "-Setup",
    "--rewrite-policy-schedule"
  )))

  with_dir(simpaths_path, sys::exec_wait("java", c(
    "-jar", "multirun.jar",
    "-r", "100",    # random seed
    "-p", "25000",  # population
    "-n", "50",     # runs
    "-s", as.character(start_year),   # first year
    "-e", as.character(start_year + 4),   # last year
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
    scenario = as.character(start_year),
    simpaths_output = latest_output_dir
  )
}

rbindlist(output) |>
  fwrite("intermediate/simpaths_directories.csv")
