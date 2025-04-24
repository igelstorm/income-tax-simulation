library(data.table)
library(gt)
library(targets)

sdcols <- c(
  "mean_inc",
  "emp_rate",
  "mean_mhcase",
  "poverty_rate",
  "gini",
  "median_share",
  "s80s20",
  "sii",
  "rii"
)

data <- list(
  "Baseline" = tar_read(simpaths_summary_baseline, store = here::here("_targets")) |>
    _[strata == "population" & time == 2026] |>
    _[, lapply(.SD, median), .SDcols = sdcols],
  "MIS_value" = tar_read(simpaths_summary_mis, store = here::here("_targets")) |>
    _[strata == "population" & time == 2026] |>
    _[, lapply(.SD, median), .SDcols = sdcols],
  "Flat_value" = tar_read(simpaths_summary_flat, store = here::here("_targets")) |>
    _[strata == "population" & time == 2026] |>
    _[, lapply(.SD, median), .SDcols = sdcols],
  "Denmark_value" = tar_read(simpaths_summary_dk, store = here::here("_targets")) |>
    _[strata == "population" & time == 2026] |>
    _[, lapply(.SD, median), .SDcols = sdcols]
)

data |>
  rbindlist(idcol = "scenario") |>
  dplyr::rename(
    "Mean income" = mean_inc,
    "Employment rate" = emp_rate,
    "Poor mental health prevalence" = mean_mhcase,
    "Poverty rate" = poverty_rate,
    "Gini index" = gini,
    "Median share of income" = median_share,
    "S80/S20" = s80s20,
    "SII for poor mental health by income" = sii,
    "RII for poor mental health by income" = rii
  ) |>
  transpose(keep.names = "Scenario", make.names = "scenario") |>
  dplyr::mutate(MIS_diff = MIS_value - Baseline, .after = "MIS_value") |>
  dplyr::mutate(Flat_diff = Flat_value - Baseline, .after = "Flat_value") |>
  dplyr::mutate(Denmark_diff = Denmark_value - Baseline, .after = "Denmark_value") |>
  gt() |>
  tab_spanner_delim("_") |>
  cols_label(
    MIS_value = "",
    Flat_value = "",
    Denmark_value = "",
    MIS_diff = "(change)",
    Flat_diff = "(change)",
    Denmark_diff = "(change)",
  ) |>
  fmt_number(decimals = 2) |>
  fmt_number(ends_with("_diff"), decimals = 2, pattern = "({x})", force_sign = TRUE) |>
  tab_caption("Simulated outcomes in the first intervention year (2026).") |>
  tab_footnote(
    "Personal allowance raised to the 2023 Minimum Income Standard (£29,500 per annum). Income tax bands currently taxed at 40% or higher increased to 81% to achieve fiscal neutrality.",
    cells_column_spanners("spanner-MIS_value")
  ) |>
  tab_footnote(
    "Personal allowance set to zero. Income tax for all bands set to a flat rate of 18.7% to achieve fiscal neutrality.",
    cells_column_spanners("spanner-Flat_value")
  ) |>
  tab_footnote(
    "Income tax bands set to replicate the Danish tax system. Universal Credit and Benefit Cap increased to achieve fiscal neutrality (by a factor of 3.4).",
    cells_column_spanners("spanner-Denmark_value")
  ) |>
  tab_source_note("Income defined as equivalised household disposable income.")
