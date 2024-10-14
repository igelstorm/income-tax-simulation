library(data.table)
library(foreach)

data_dirs <- fread("intermediate/simpaths_directories.csv")
simpaths_path <- R.utils::getAbsolutePath("../SimPaths")

output <- foreach(
  scenario = data_dirs$scenario,
  data_dir = data_dirs$simpaths_output,
  .combine = rbind
) %do% {
  bu_data <- fread(
    file.path(simpaths_path, "output", data_dir, "csv", "BenefitUnit.csv"),
    select = c(
      "run",
      "time",
      "id_BenefitUnit",
      "atRiskOfPoverty",
      "equivalisedDisposableIncomeYearly"
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
  merged_data[dag >= 15 & dag <= 64, employed := FALSE]
  merged_data[les_c4 == "EmployedOrSelfEmployed", employed := TRUE]

  decile_stats <- merged_data[, .(
    scenario = scenario,
    level = "inc_decile",
    mean_inc = mean(equivalisedDisposableIncomeYearly),
    emp_rate = mean(employed, na.rm = TRUE),
    mean_mhcase = mean(dhm_ghq)
  ), by = c("run", "time", "inc_decile")] |>
    _[order(run, time, inc_decile)]

  pop_stats <- merged_data[, .(
    scenario = scenario,
    level = "population",
    poverty_rate = mean(atRiskOfPoverty),
    emp_rate = mean(employed, na.rm = TRUE),
    mean_inc = mean(equivalisedDisposableIncomeYearly)
  ), by = c("run", "time")] |>
    _[order(run, time)]

  rbind(decile_stats, pop_stats, fill = TRUE)
}

fwrite(output, "output/summary_data.csv")
