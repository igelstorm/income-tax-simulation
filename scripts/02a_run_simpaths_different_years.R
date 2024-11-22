library(data.table)
library(foreach)
library(withr)

population  <- 25000
runs        <- 10
scenario    <- "baseline"

simpaths_path <- R.utils::getAbsolutePath("../SimPaths")

euromod_file_path <- file.path(simpaths_path, "input","EUROMODoutput")

start_years <- c(2022, 2024, 2026)

output <- foreach(first_year = start_years) %do% {
  timestamp()
  print(first_year)
  last_year   <- first_year + 9

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
    "-s", format(first_year),
    "-g", "false",
    "-Setup",
    "--rewrite-policy-schedule"
  )))

  with_dir(simpaths_path, sys::exec_wait("java", c(
    "-jar", "multirun.jar",
    "-r", "100",    # random seed
    "-p", format(population),
    "-n", format(runs),
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
    scenario = as.character(first_year),
    simpaths_output = latest_output_dir
  )
}

rbindlist(output) |>
  fwrite("intermediate/simpaths_directories.csv")
