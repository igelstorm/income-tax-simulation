library(data.table)
library(gt)
library(targets)

data <- list(
  "Baseline" = tar_read(decile_summary_baseline, store = here::here("_targets")),
  "MIS_value" = tar_read(decile_summary_mis, store = here::here("_targets")),
  "Flat_value" = tar_read(decile_summary_flat, store = here::here("_targets")),
  "Denmark_value" = tar_read(decile_summary_dk, store = here::here("_targets"))
)

data |>
  rbindlist(idcol = "scenario") |>
  dcast(inc_decile ~ scenario, value.var = "mean_inc_eq") |>
  dplyr::transmute(
    "Income decile" = inc_decile,
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
