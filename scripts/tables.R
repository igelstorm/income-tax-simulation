library(gt)

data <- list(
  "Baseline" = tar_read(high_level_summary_baseline),
  "MIS_value" = tar_read(high_level_summary_mis),
  "Flat_value" = tar_read(high_level_summary_flat)
)

data |>
  rbindlist(idcol = "scenario") |>
  dplyr::transmute(
    scenario,
    "Revenue" = govt_revenue / 10^9,
    "Expenditure" = govt_expenditure / 10^9,
    "Balance" = Revenue - Expenditure,
    "S80/S20" = s80s20,
    "Gini" = gini,
  ) |>
  transpose(keep.names = "Scenario", make.names = "scenario") |>
  dplyr::mutate(MIS_diff = `MIS_value` - Baseline, .after = "MIS_value") |>
  dplyr::mutate(Flat_diff = `Flat_value` - Baseline, .after = "Flat_value") |>
  gt() |>
  fmt_number(decimals = 2) |>
  tab_spanner_delim("_")
