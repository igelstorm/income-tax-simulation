library(data.table)
library(foreach)
library(withr)
# Also required:
# - R.utils
# - here
# - sys

first_year  <- 2023
last_year   <- 2035
population  <- 25000
runs        <- 1000
random_seed <- 100

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  stop("Usage: Rscript 02_run_simpaths.R <scenario>")
}
scenario <- args[[1]]

simpaths_path <- R.utils::getAbsolutePath(here::here("../SimPaths"))
results_root_path <- here::here("data", "simpaths_output")
euromod_output_directory <- here::here("data", "euromod_output")

simpaths_input_path <- file.path(simpaths_path, "input")
simpaths_euromod_path <- file.path(simpaths_input_path, "EUROMODoutput")

timestamp(suffix = paste(" - Started scenario", scenario))

print(paste("Deleting existing EUROMOD files in SimPaths input directory", scenario))
simpaths_euromod_path |>
  list.files(pattern = "\\.txt$", full.names = TRUE) |>
  file.remove()

print(paste("Copying EUROMOD files for scenario", scenario, "to SimPaths input directory"))
euromod_files <- here::here(euromod_output_directory, scenario) |>
  list.files(full.names = TRUE)
file.copy(euromod_files, simpaths_euromod_path)

print("Running SimPaths setup")
# Delete old database and policy schedule mappings to ensure we're starting with a clean slate
# (these will be recreated during the setup process)
file.remove(file.path(simpaths_input_path, "input.mv.db"))
file.remove(file.path(simpaths_input_path, "EUROMODpolicySchedule.xlsx"))
with_dir(simpaths_path, sys::exec_wait("java", c(
  "-jar", "multirun.jar",
  "-s", format(first_year),
  "-p", format(population, scientific = FALSE),
  "-n", format(runs, scientific = FALSE),
  "-s", format(first_year),
  "-e", format(last_year),
  "-g", "false",
  "-DBSetup"
)))

print("Running SimPaths simulation")
with_dir(simpaths_path, sys::exec_wait("java", c(
  "-jar", "multirun.jar",
  "-r", format(random_seed),
  "-p", format(population, scientific = FALSE),
  "-n", format(runs, scientific = FALSE),
  "-s", format(first_year),
  "-e", format(last_year),
  "-g", "false"
)))

latest_output_dir <- file.path(simpaths_path, "output") |>
  list.files(full.names = TRUE) |>
  grep(pattern = "logs$", x = _, invert = TRUE, value = TRUE) |>
  tail(n = 1)

print(paste("SimPaths output directory:", latest_output_dir))
results_path <- file.path(results_root_path, scenario)

if (!dir.exists(results_path)) dir.create(results_path, recursive = TRUE)
writeLines(latest_output_dir, file.path(results_path, "output_dir.txt"))

timestamp(suffix = paste(" - Finished scenario", scenario))
