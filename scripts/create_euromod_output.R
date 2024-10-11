library(data.table)
library(glue)

source("R/euromod.R")
source("R/policy_scenarios.R")

model_path <- here::here("UKMOD-PUBLIC-B2024.14")

input_data <- fread("input/UK_2022_a1.txt")
input_data_name <- "UK_2022_a1.txt"

years <- 2023:2027
skip_existing <- TRUE

scenarios <- c(
  "baseline",
  "mis",
  "flat"
)

for (scenario in scenarios) {
  output_folder <- file.path("intermediate", "euromod", scenario)
  dir.create(output_folder, recursive = TRUE)
  for (year in years) {
    out_path <- file.path(output_folder, glue("uk_{year}_std.txt"))
    if (file.exists(out_path) & skip_existing) { next }
    output <- run_euromod(
      input_data,
      system = glue("UK_{year}"),
      dataset = input_data_name,
      constants = scenario_parameters[[scenario]],
      model_path = model_path
    )
    fwrite(output, out_path, sep = "\t")
  }
}
