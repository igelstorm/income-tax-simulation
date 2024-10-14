library(data.table)
library(foreach)
library(withr)

simpaths_path <- R.utils::getAbsolutePath("../SimPaths")

euromod_file_path <- file.path(simpaths_path, "input","EUROMODoutput")

scenarios <- c("baseline", "mis", "flat")

output <- foreach(scenario = scenarios) %do% {
  euromod_file_path |>
    list.files(pattern = "\\.txt$", full.names = TRUE) |>
    file.remove()

  euromod_files <- file.path("intermediate", "euromod", scenario) |>
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
    "-r", "100",    # random seed
    "-p", "10000",  # population
    "-n", "10",     # runs
    "-s", "2023",   # first year
    "-e", "2027",   # last year
    "-g", "false",
    "-f"
  )))

  latest_output_dir <- list.files(file.path(simpaths_path, "output")) |>
    setdiff("logs") |>
    sort() |>
    tail(n = 1)

  data.table(
    scenario = scenario,
    simpaths_output = latest_output_dir
  )
}

rbindlist(output) |>
  fwrite("intermediate/simpaths_directories.csv")
