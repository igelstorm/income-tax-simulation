library(gt)

data <- list(
  "Baseline" = tar_read(decile_summary_baseline),
  "MIS_value" = tar_read(decile_summary_mis),
  "Flat_value" = tar_read(decile_summary_flat)
)

data |>
  rbindlist(idcol = "scenario") |>
  dcast(inc_decile ~ scenario, value.var = "share") |>
  dplyr::transmute(
    "Income decile" = inc_decile,
    Baseline,
    MIS_value,
    Flat_value
  ) |>
  dplyr::mutate(MIS_diff = MIS_value - Baseline, .after = "MIS_value") |>
  dplyr::mutate(Flat_diff = Flat_value - Baseline, .after = "Flat_value") |>
  gt() |>
  tab_spanner_delim("_") |>
  cols_label(
    MIS_value = "",
    Flat_value = "",
    MIS_diff = "(change)",
    Flat_diff = "(change)",
  ) |>
  fmt_percent(decimals = 1) |>
  fmt_percent(ends_with("_diff"), decimals = 1, pattern = "({x})", force_sign = TRUE)
