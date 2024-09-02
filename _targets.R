library(data.table)
library(targets)

source("R/euromod.R")
source("R/summary.R")

model_path <- here::here("UKMOD-PUBLIC-B2024.14")

list(
  tar_target(input_data, fread("UKMOD-PUBLIC-B2024.14/Input/UK_2022_a1.txt")),

  tar_target(output_baseline, run_euromod(
    input_data,
    system = "UK_2024",
    dataset = "UK_2022_a1.txt",
    model_path = model_path
  )),
  tar_target(output_mis, run_euromod(
    input_data,
    system = "UK_2024_MIS",
    dataset = "UK_2022_a1.txt",
    model_path = model_path
  )),
  tar_target(output_flat, run_euromod(
    input_data,
    system = "UK_2024_flat",
    dataset = "UK_2022_a1.txt",
    model_path = model_path
  )),

   tar_target(high_level_summary_baseline,  high_level_summary(output_baseline)),
   tar_target(high_level_summary_mis,       high_level_summary(output_mis)),
   tar_target(high_level_summary_flat,      high_level_summary(output_flat)),

   tar_target(decile_summary_baseline,      decile_summary(output_baseline)),
   tar_target(decile_summary_mis,           decile_summary(output_mis)),
   tar_target(decile_summary_flat,          decile_summary(output_flat))
)
