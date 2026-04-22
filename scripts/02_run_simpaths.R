library(data.table)
library(foreach)
library(withr)
# Also required:
# - R.utils
# - here
# - sys

first_year      <- 2023
last_year       <- 2035
population      <- 25000
starting_seed   <- 100
runs_per_batch  <- 10
batches         <- 100

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

# Store existing output directories before running the simulation, so we can keep track of which ones are new
output_dirs_before <- list.files(file.path(simpaths_path, "output"), full.names = TRUE)

print("Running SimPaths setup")
# Delete old database to ensure we're starting with a clean slate (this will be recreated during the setup process)
file.remove(file.path(simpaths_input_path, "input.mv.db"))
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

for (batch in 1:batches) {
  print(paste("Running SimPaths simulation, batch", batch, "of", batches))
  batch_seed <- starting_seed + (batch - 1) * runs_per_batch
  with_dir(simpaths_path, sys::exec_wait("java", c(
    "-jar", "multirun.jar",
    "-r", format(batch_seed),
    "-p", format(population, scientific = FALSE),
    "-n", format(runs_per_batch, scientific = FALSE),
    "-s", format(first_year),
    "-e", format(last_year),
    "-g", "false"
  )))
}

# Identify the new output directories and store their paths for later use
output_dirs_after <- list.files(file.path(simpaths_path, "output"), full.names = TRUE)
new_output_dirs <- setdiff(output_dirs_after, output_dirs_before)
# Don't include "logs" directory (if there is one)
new_output_dirs <- grep(pattern = "logs$", x = new_output_dirs, invert = TRUE, value = TRUE)

results_path <- file.path(results_root_path, scenario)
if (!dir.exists(results_path)) dir.create(results_path, recursive = TRUE)
writeLines(new_output_dirs, file.path(results_path, "output_dir.txt"))

timestamp(suffix = paste(" - Finished scenario", scenario))
