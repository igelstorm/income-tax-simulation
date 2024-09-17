library(data.table)
library(targets)

source("R/euromod.R")
source("R/summary.R")

model_path <- here::here("UKMOD-PUBLIC-B2024.14")

mis_constants <- list(
  ITPerAll = "29500#y",
  ITRate2 = "0.81",
  ITRate3 = "0.81",
  ITRate4S = "0.81",
  ITRate5S = "0.81",
  ITRate6S = "0.81"
)
flat_constants <- list(
  ITPerAll = "0#y",
  ITRate1 = "0.187",
  ITRate2 = "0.187",
  ITRate3 = "0.187",
  ITRate1S = "0.187",
  ITRate2S = "0.187",
  ITRate3S = "0.187",
  ITRate4S = "0.187",
  ITRate5S = "0.187",
  ITRate6S = "0.187"
)

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
    system = "UK_2024",
    dataset = "UK_2022_a1.txt",
    constants = mis_constants,
    model_path = model_path
  )),
  tar_target(output_flat, run_euromod(
    input_data,
    system = "UK_2024",
    dataset = "UK_2022_a1.txt",
    constants = flat_constants,
    model_path = model_path
  )),

   tar_target(high_level_summary_baseline,  high_level_summary(output_baseline)),
   tar_target(high_level_summary_mis,       high_level_summary(output_mis)),
   tar_target(high_level_summary_flat,      high_level_summary(output_flat)),

   tar_target(decile_summary_baseline,      decile_summary(output_baseline)),
  # TODO: these should use the income deciles boundaries from the baseline scenario
   tar_target(decile_summary_mis,           decile_summary(output_mis)),
   tar_target(decile_summary_flat,          decile_summary(output_flat))
)
