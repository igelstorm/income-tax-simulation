library(data.table)
library(targets)

source("R/euromod_summary.R")
source("R/intervention_effects.R")
source("R/simpaths_summary.R")
# source("R/triangulation.R")

model_path <- here::here("UKMOD-PUBLIC-B2024.14")
input_data_path <- "input/UK_2022_a1.txt"
input_data_filename <- "UK_2022_a1.txt"

list(
  tar_target(euromod_baseline_file,  "intermediate/euromod/baseline/uk_2026_std.txt", format = "file"),
  tar_target(euromod_dk_file,        "intermediate/euromod/dk/uk_2026_std.txt", format = "file"),
  tar_target(euromod_flat_file,      "intermediate/euromod/flat/uk_2026_std.txt", format = "file"),
  tar_target(euromod_mis_file,       "intermediate/euromod/mis/uk_2026_std.txt", format = "file"),

  tar_target(euromod_baseline,   fread(euromod_baseline_file)),
  tar_target(euromod_dk,         fread(euromod_dk_file)),
  tar_target(euromod_flat,       fread(euromod_flat_file)),
  tar_target(euromod_mis,        fread(euromod_mis_file)),

  tar_target(high_level_summary_baseline,  high_level_summary(euromod_baseline)),
  tar_target(high_level_summary_mis,       high_level_summary(euromod_mis)),
  tar_target(high_level_summary_flat,      high_level_summary(euromod_flat)),
  tar_target(high_level_summary_dk,        high_level_summary(euromod_dk)),

  tar_target(hh_deciles_baseline, create_hh_deciles(euromod_baseline)),

  tar_target(decile_summary_baseline,      decile_summary(euromod_baseline, hh_deciles = hh_deciles_baseline)),
  tar_target(decile_summary_mis,           decile_summary(euromod_mis, hh_deciles = hh_deciles_baseline)),
  tar_target(decile_summary_flat,          decile_summary(euromod_flat, hh_deciles = hh_deciles_baseline)),
  tar_target(decile_summary_dk,            decile_summary(euromod_dk, hh_deciles = hh_deciles_baseline)),

  tar_target(simpaths_person_file_baseline, "intermediate/simpaths/baseline/Person.csv", format = "file"),
  tar_target(simpaths_person_file_dk,       "intermediate/simpaths/dk/Person.csv", format = "file"),
  tar_target(simpaths_person_file_flat,     "intermediate/simpaths/flat/Person.csv", format = "file"),
  tar_target(simpaths_person_file_mis,      "intermediate/simpaths/mis/Person.csv", format = "file"),

  tar_target(simpaths_bu_file_baseline,     "intermediate/simpaths/baseline/BenefitUnit.csv", format = "file"),
  tar_target(simpaths_bu_file_dk,           "intermediate/simpaths/dk/BenefitUnit.csv", format = "file"),
  tar_target(simpaths_bu_file_flat,         "intermediate/simpaths/flat/BenefitUnit.csv", format = "file"),
  tar_target(simpaths_bu_file_mis,          "intermediate/simpaths/mis/BenefitUnit.csv", format = "file"),

  tar_target(simpaths_person_baseline,  read_person_data(simpaths_person_file_baseline)),
  tar_target(simpaths_person_dk,        read_person_data(simpaths_person_file_dk)),
  tar_target(simpaths_person_flat,      read_person_data(simpaths_person_file_flat)),
  tar_target(simpaths_person_mis,       read_person_data(simpaths_person_file_mis)),

  tar_target(simpaths_bu_baseline,      read_bu_data(simpaths_bu_file_baseline)),
  tar_target(simpaths_bu_dk,            read_bu_data(simpaths_bu_file_dk)),
  tar_target(simpaths_bu_flat,          read_bu_data(simpaths_bu_file_flat)),
  tar_target(simpaths_bu_mis,           read_bu_data(simpaths_bu_file_mis)),

  tar_target(simpaths_summary_baseline,   create_simpaths_summary(simpaths_person_baseline, simpaths_bu_baseline)),
  tar_target(simpaths_summary_dk,         create_simpaths_summary(simpaths_person_dk, simpaths_bu_dk)),
  tar_target(simpaths_summary_flat,       create_simpaths_summary(simpaths_person_flat, simpaths_bu_flat)),
  tar_target(simpaths_summary_mis,        create_simpaths_summary(simpaths_person_mis, simpaths_bu_mis)),

  tar_target(effects_dk, calculate_difference(simpaths_summary_baseline, simpaths_summary_dk)),
  tar_target(effects_flat, calculate_difference(simpaths_summary_baseline, simpaths_summary_flat)),
  tar_target(effects_mis, calculate_difference(simpaths_summary_baseline, simpaths_summary_mis)),

  # tar_target(triangulation_flat, triangulate_reform(
  #   data = input_data, system = "UK_2024", dataset = input_data_filename,
  #   model_path = model_path, baseline_data = euromod_baseline,
  #   reform_constants = list(
  #     ITPerAll = "0#y",
  #     ITRate1 = "{x}", ITRate2 = "{x}", ITRate3 = "{x}",
  #     ITRate1S = "{x}", ITRate2S = "{x}", ITRate3S = "{x}",
  #     ITRate4S = "{x}", ITRate5S = "{x}", ITRate6S = "{x}"
  #   ),
  #   x_values = c(0.185, 0.187)
  # )),
  # tar_target(triangulation_mis, triangulate_reform(
  #   data = input_data, system = "UK_2024", dataset = input_data_filename,
  #   model_path = model_path, baseline_data = euromod_baseline,
  #   reform_constants = list(
  #     ITPerAll = "29500#y",
  #     ITRate1         = "{x}",      # First tax rate
  #     ITRate2         = "0.5",      # Second tax rate
  #     ITRate3         = "0.5",     # Third tax rate
  #     ITRate1S        = "{x}-0.01",     # 2018/19 to current: Starter rate: 2017/18: Basic rate (Scotland)
  #     ITRate2S        = "{x}",      # 2018/19 to current: Basic rate; 2017/18: Higher rate (Scotland)
  #     ITRate3S        = "{x}+0.01",     # 2018/19 to current: Intermediate rate; 2017/18: Additional rate (Scotland)
  #     ITRate4S        = "0.5",     # Higher rate (Scotland)
  #     ITRate5S        = "0.5",     # Advanced rate (Scotland)
  #     ITRate6S        = "0.5"     # Top rate (Scotland)
  #   ),
  #   x_values = c(0.40, 0.50)
  # )),
  # tar_target(triangulation_dk, triangulate_reform(
  #   data = input_data, system = "UK_2024", dataset = input_data_filename,
  #   model_path = model_path, baseline_data = euromod_baseline,
  #   reform_constants = dk_raw_params,
  #   x_values = c(3.39, 3.395)
  # )),
  # tar_target(tri_plot_flat, plot_triangulation(triangulation_flat, xlab = "Tax rate"), packages = "ggpubr"),
  # tar_target(tri_plot_mis, plot_triangulation(triangulation_mis, xlab = "Basic tax rate"), packages = "ggpubr"),
  # tar_target(tri_plot_dk, plot_triangulation(triangulation_dk, xlab = "UC increase factor"), packages = "ggpubr")
  tar_target(end, "end")
)
