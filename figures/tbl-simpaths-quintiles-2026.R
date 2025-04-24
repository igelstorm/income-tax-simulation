library(data.table)
library(gt)
library(targets)

outcome <- "mean_mhcase"
# outcome <- "emp_rate"


data <- list(
  "Baseline" = tar_read(simpaths_summary_baseline, store = here::here("_targets")) |>
    _[strata == "inc_decile" & time == 2026] |>
    _[, quintile := ceiling(inc_decile / 2)] |>
    _[, lapply(.SD, median), .SDcols = outcome, by = "quintile"],
  "MIS_value" = tar_read(simpaths_summary_mis, store = here::here("_targets")) |>
    _[strata == "inc_decile" & time == 2026] |>
    _[, quintile := ceiling(inc_decile / 2)] |>
    _[, lapply(.SD, median), .SDcols = outcome, by = "quintile"],
  "Flat_value" = tar_read(simpaths_summary_flat, store = here::here("_targets")) |>
    _[strata == "inc_decile" & time == 2026] |>
    _[, quintile := ceiling(inc_decile / 2)] |>
    _[, lapply(.SD, median), .SDcols = outcome, by = "quintile"],
  "Denmark_value" = tar_read(simpaths_summary_dk, store = here::here("_targets")) |>
    _[strata == "inc_decile" & time == 2026] |>
    _[, quintile := ceiling(inc_decile / 2)] |>
    _[, lapply(.SD, median), .SDcols = outcome, by = "quintile"]
)

data |>
  rbindlist(idcol = "scenario") |>
  dcast(quintile ~ scenario, value.var = outcome) |>
  dplyr::transmute(
    "Income quintile" = as.character(quintile),
    Baseline,
    MIS_value,
    Flat_value,
    Denmark_value
  ) |>
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
  tab_caption("Mean equivalised disposable household income by income decile (GBP per week).") |>
  tab_source_note("Deciles calculated based on equivalised household disposable income.")
