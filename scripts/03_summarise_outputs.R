library(data.table)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  stop("Usage: Rscript 03_summarise_outputs.R <scenario>")
}
scenario <- args[[1]]

results_path <- here::here("data", "simpaths_output", scenario)
output_file <- file.path(results_path, "summarised_output.csv")
simpaths_output_dirs <- readLines(file.path(results_path, "output_dirs.txt"))

all_data <- list()

for (dir in simpaths_output_dirs) {
  person_path <- file.path(dir, "csv", "Person.csv")
  bu_path <- file.path(dir, "csv", "BenefitUnit.csv")
  if (!file.exists(person_path))  stop(paste("Person.csv not found at", person_path))
  if (!file.exists(bu_path))      stop(paste("BenefitUnit.csv not found at", bu_path))

  seed <- strsplit(basename(dir), "_")[[1]][2]
  print(paste("Reading output directory:", dir, "assuming seed is", seed))

  person_data <- fread(
    person_path,
    select = c(
      "run",
      "time",
      "id_Person",
      "idBu",
      "demAge",
      "demMaleFlag",
      "eduHighestC4",
      "labC4",
      "healthMentalMcs",
      "healthPhysicalPcs",
      "healthPsyDstrss0to12",
      "healthSelfRated"
    )
  )
  bu_data <- fread(
    bu_path,
    select = c(
      "run",
      "time",
      "id_BenefitUnit",
      "yPvrtyFlag",
      "yDispEquivYear"
      # paste0("n_children_", 0:17)
    )
  )
  merged_data <- merge(
    person_data,
    bu_data,
    by.x = c("run", "time", "idBu"),
    by.y = c("run", "time", "id_BenefitUnit")
  )
  all_data[[seed]] <- merged_data
}

all_data <- rbindlist(all_data, idcol = "seed")

all_data[, inc_decile := cut(
  yDispEquivYear,
  quantile(yDispEquivYear, probs = 0:10/10),
  labels = FALSE,
  include.lowest = TRUE
), by = c("seed", "time") ]
all_data[, inc_quintile := cut(
  yDispEquivYear,
  quantile(yDispEquivYear, probs = 0:5/5),
  labels = FALSE,
  include.lowest = TRUE
), by = c("seed", "time") ]

# Calculate employment variable for purposes of employment rate
all_data[, employed := NA]
all_data[demAge >= 16 & demAge <= 64, employed := FALSE]
all_data[labC4 == "EmployedOrSelfEmployed", employed := TRUE]

# Calculate non-negative equivalised disposable income (with subzero values set to zero)
all_data[, nonneg_equiv_disp_inc := pmax(yDispEquivYear, 0)]

# Limit to working-age population
final_data <- all_data[demAge >= 25 & demAge <= 64]

# Create subgroups
final_data[demAge >= 25 & demAge <= 44, age_cat := "25_44"]
final_data[demAge >= 45 & demAge <= 64, age_cat := "45_64"]

# final_data[, n_children := rowSums(.SD), .SDcols = c(paste0("n_children_", 0:17))]
# final_data[n_children == 0, hh_structure := "No kids"]
# final_data[household_status == "Couple" & n_children > 0, hh_structure := "Couple with kids"]
# final_data[household_status == "Single" & n_children > 0, hh_structure := "Lone parent"]

pop_stats <- final_data[, .(
  scenario = scenario,
  strata = "population",
  mean_inc = mean(yDispEquivYear),
  emp_rate = mean(employed, na.rm = TRUE),
  mean_mhcase = mean(healthPsyDstrss0to12 >= 4),
  poverty_rate = mean(yPvrtyFlag),
  gini = DescTools::Gini(nonneg_equiv_disp_inc),
  median_share = sum(inc_decile %in% 1:5 * nonneg_equiv_disp_inc) / sum(nonneg_equiv_disp_inc),
  s80s20 = sum((inc_decile >= 9) * nonneg_equiv_disp_inc) / sum((inc_decile <= 2) * nonneg_equiv_disp_inc)
), by = c("seed", "time")] |>
  _[order(seed, time)]

subgroup_stats <- function(data, subgroup_var) {
  stats <- data[, .(
    scenario = scenario,
    strata = subgroup_var,
    mean_inc = mean(yDispEquivYear),
    emp_rate = mean(employed, na.rm = TRUE),
    mean_mhcase = mean(healthPsyDstrss0to12 >= 4),
    poverty_rate = mean(yPvrtyFlag)
  ), by = c("seed", "time", subgroup_var)]
  setorderv(stats, c("seed", "time", subgroup_var))
  stats
}

output <- rbind(
  pop_stats,
  subgroup_stats(final_data, "inc_decile"),
  subgroup_stats(final_data, "inc_quintile"),
  subgroup_stats(final_data, "demMaleFlag"),
  subgroup_stats(final_data, "eduHighestC4"),
  subgroup_stats(final_data, "age_cat"),
  # subgroup_stats(final_data, "hh_structure"),
  fill = TRUE
)
output

print(paste("Saving summarised output for scenario", scenario))
fwrite(output, output_file)
