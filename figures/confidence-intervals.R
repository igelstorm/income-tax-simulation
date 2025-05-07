library(targets)

tar_read(effects_dk) |>
  _[strata == "population" & time == 2026 & variable == "log_rii"] |>
  _[, .(rii = exp(diff), ci_l = exp(diff_lower), ci_u = exp(diff_upper))]
tar_read(effects_mis) |>
  _[strata == "population" & time == 2026 & variable == "log_rii"] |>
  _[, .(rii = exp(diff), ci_l = exp(diff_lower), ci_u = exp(diff_upper))]
tar_read(effects_flat) |>
  _[strata == "population" & time == 2026 & variable == "log_rii"] |>
  _[, .(rii = exp(diff), ci_l = exp(diff_lower), ci_u = exp(diff_upper))]

tar_read(estimates_baseline) |>
  _[strata == "population" & time == 2026 & variable == "log_rii"] |>
  _[, .(rii = exp(value), ci_l = exp(value_lower), ci_u = exp(value_upper))]
tar_read(estimates_dk) |>
  _[strata == "population" & time == 2026 & variable == "log_rii"] |>
  _[, .(rii = exp(value), ci_l = exp(value_lower), ci_u = exp(value_upper))]
tar_read(estimates_mis) |>
  _[strata == "population" & time == 2026 & variable == "log_rii"] |>
  _[, .(rii = exp(value), ci_l = exp(value_lower), ci_u = exp(value_upper))]
tar_read(estimates_flat) |>
  _[strata == "population" & time == 2026 & variable == "log_rii"] |>
  _[, .(rii = exp(value), ci_l = exp(value_lower), ci_u = exp(value_upper))]

tar_read(effects_dk) |>
  _[strata == "inc_decile" & time == 2026 & variable == "mean_mhcase"]
