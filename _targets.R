library(data.table)
library(targets)

source("R/euromod.R")
source("R/policy_scenarios.R")
source("R/summary.R")
source("R/triangulation.R")

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
    system = "UK_2024",
    dataset = "UK_2022_a1.txt",
    constants = mis_constants,
    model_path = model_path
  )),
  tar_target(output_mis2, run_euromod(
    input_data,
    system = "UK_2024",
    dataset = "UK_2022_a1.txt",
    constants = mis2_constants,
    model_path = model_path
  )),
  tar_target(output_flat, run_euromod(
    input_data,
    system = "UK_2024",
    dataset = "UK_2022_a1.txt",
    constants = flat_constants,
    model_path = model_path
  )),
  tar_target(output_dk, run_euromod(
    input_data,
    system = "UK_2024",
    dataset = "UK_2022_a1.txt",
    constants = dk_constants,
    model_path = model_path
  )),

  tar_target(high_level_summary_baseline,  high_level_summary(output_baseline)),
  tar_target(high_level_summary_mis,       high_level_summary(output_mis2)),
  tar_target(high_level_summary_flat,      high_level_summary(output_flat)),
  tar_target(high_level_summary_dk,        high_level_summary(output_dk)),

  tar_target(decile_summary_baseline,      decile_summary(output_baseline, hh_deciles = create_hh_deciles(output_baseline))),
  # TODO: these should use the income deciles from the baseline scenario
  tar_target(decile_summary_mis,           decile_summary(output_mis2, hh_deciles = create_hh_deciles(output_mis2))),
  tar_target(decile_summary_flat,          decile_summary(output_flat, hh_deciles = create_hh_deciles(output_flat))),
  tar_target(decile_summary_dk,            decile_summary(output_dk, hh_deciles = create_hh_deciles(output_dk))),

  tar_target(triangulation_flat, triangulate_reform(
    data = input_data, system = "UK_2024", dataset = "UK_2022_a1.txt",
    model_path = model_path, baseline_data = output_baseline,
    reform_constants = list(
      ITPerAll = "0#y",
      ITRate1 = "{x}", ITRate2 = "{x}", ITRate3 = "{x}",
      ITRate1S = "{x}", ITRate2S = "{x}", ITRate3S = "{x}",
      ITRate4S = "{x}", ITRate5S = "{x}", ITRate6S = "{x}"
    ),
    x_values = c(0.185, 0.187)
  )),
  tar_target(triangulation_mis, triangulate_reform(
    data = input_data, system = "UK_2024", dataset = "UK_2022_a1.txt",
    model_path = model_path, baseline_data = output_baseline,
    reform_constants = list(
      ITPerAll = "29500#y",
      ITRate1         = "{x}",      # First tax rate
      ITRate2         = "0.5",      # Second tax rate
      ITRate3         = "0.5",     # Third tax rate
      ITRate1S        = "{x}-0.01",     # 2018/19 to current: Starter rate: 2017/18: Basic rate (Scotland)
      ITRate2S        = "{x}",      # 2018/19 to current: Basic rate; 2017/18: Higher rate (Scotland)
      ITRate3S        = "{x}+0.01",     # 2018/19 to current: Intermediate rate; 2017/18: Additional rate (Scotland)
      ITRate4S        = "0.5",     # Higher rate (Scotland)
      ITRate5S        = "0.5",     # Advanced rate (Scotland)
      ITRate6S        = "0.5"     # Top rate (Scotland)
    ),
    x_values = c(0.40, 0.50)
  )),
  tar_target(tri_plot_flat, plot_triangulation(triangulation_flat, xlab = "Tax rate"), packages = "ggpubr"),
  tar_target(tri_plot_mis, plot_triangulation(triangulation_mis, xlab = "Basic tax rate"), packages = "ggpubr")
)
