library(data.table)
library(foreach)

data_root_path <- here::here("intermediate", "simpaths")
scenarios <- c("baseline", "mis", "flat", "dk")

output <- foreach(
  scenario = scenarios,
  .combine = rbind
) %do% {
  data_path <- file.path(data_root_path, scenario)
  person_data <- fread(
    file.path(data_path, "Person.csv"),
    select = c(
      "run",
      "time",
      "id_Person",
      "idBenefitUnit",
      "dag",
      "dgn",
      "deh_c3",
      "les_c4",
      "dhm",
      "dhm_ghq"
    )
  )
  bu_data <- fread(
    file.path(data_path, "BenefitUnit.csv"),
    select = c(
      "run",
      "time",
      "id_BenefitUnit",
      "atRiskOfPoverty",
      "equivalisedDisposableIncomeYearly"
      # paste0("n_children_", 0:17)
    )
  )
  merged_data <- merge(
    person_data,
    bu_data,
    by.x = c("run", "time", "idBenefitUnit"),
    by.y = c("run", "time", "id_BenefitUnit")
  )

  merged_data[, inc_decile := cut(
    equivalisedDisposableIncomeYearly,
    quantile(equivalisedDisposableIncomeYearly, probs = 0:10/10),
    labels = FALSE,
    include.lowest = TRUE
  ), by = c("run", "time") ]

  # Calculate employment variable for purposes of employment rate
  merged_data[, employed := NA]
  merged_data[dag >= 16 & dag <= 64, employed := FALSE]
  merged_data[les_c4 == "EmployedOrSelfEmployed", employed := TRUE]

  # Calculate non-negative equivalised disposable income (with subzero values set to zero)
  merged_data[, nonneg_equiv_disp_inc := pmax(equivalisedDisposableIncomeYearly, 0)]

  # Limit to working-age population
  final_data <- merged_data[dag >= 25 & dag <= 64]

  # Create subgroups
  final_data[dag >= 25 & dag <= 44, age_cat := "25_44"]
  final_data[dag >= 45 & dag <= 64, age_cat := "45_64"]

  # final_data[, n_children := rowSums(.SD), .SDcols = c(paste0("n_children_", 0:17))]
  # final_data[n_children == 0, hh_structure := "No kids"]
  # final_data[household_status == "Couple" & n_children > 0, hh_structure := "Couple with kids"]
  # final_data[household_status == "Single" & n_children > 0, hh_structure := "Lone parent"]

  pop_stats <- final_data[, .(
    scenario = scenario,
    strata = "population",
    mean_inc = mean(equivalisedDisposableIncomeYearly),
    emp_rate = mean(employed, na.rm = TRUE),
    mean_mhcase = mean(dhm_ghq),
    poverty_rate = mean(atRiskOfPoverty),
    gini = DescTools::Gini(nonneg_equiv_disp_inc),
    median_share = sum(inc_decile %in% 1:5 * nonneg_equiv_disp_inc) / sum(nonneg_equiv_disp_inc),
    s80s20 = sum((inc_decile >= 9) * nonneg_equiv_disp_inc) / sum((inc_decile <= 2) * nonneg_equiv_disp_inc)
  ), by = c("run", "time")] |>
    _[order(run, time)]

  subgroup_stats <- function(data, subgroup_var) {
    stats <- data[, .(
      scenario = scenario,
      strata = subgroup_var,
      mean_inc = mean(equivalisedDisposableIncomeYearly),
      emp_rate = mean(employed, na.rm = TRUE),
      mean_mhcase = mean(dhm_ghq),
      poverty_rate = mean(atRiskOfPoverty)
    ), by = c("run", "time", subgroup_var)]
    setorderv(stats, c("run", "time", subgroup_var))
    stats
  }

  rbind(
    pop_stats,
    subgroup_stats(final_data, "inc_decile"),
    subgroup_stats(final_data, "dgn"),
    subgroup_stats(final_data, "deh_c3"),
    subgroup_stats(final_data, "age_cat"),
    # subgroup_stats(final_data, "hh_structure"),
    fill = TRUE
  )
}

fwrite(output, "output/summary_data.csv")
