library(gt)
library(targets)

baseline <- tar_read(estimates_baseline) |>
  _[strata == "population" & variable == "rii", .(
    Year = time,
    Baseline_Value = value,
    Baseline_CIl = value_lower,
    Baseline_CIu = value_upper
  )]
denmark <- tar_read(effects_dk) |>
  _[strata == "population" & variable == "rii", .(
    Year = time,
    Denmark_Value = diff,
    Denmark_CIl = diff_lower,
    Denmark_CIu = diff_upper
  )]

baseline |>
  merge(denmark, by = "Year") |>
  gt() |>
  fmt_number(starts_with("Baseline"), decimals = 2) |>
  fmt_number(-c("Year", starts_with("Baseline")), decimals = 2, pattern = "({x})", force_sign = TRUE)
