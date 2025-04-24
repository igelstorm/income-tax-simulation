calculate_difference <- function(baseline_data, intervention_data) {
  bln <- baseline_data
  int <- intervention_data

  idcols = c("time", "strata", "inc_decile", "dgn", "deh_c3", "age_cat")
  bln_mean <- bln[, lapply(.SD, mean), by = idcols] |>
    melt(id.vars = idcols, variable.name = "variable", value.name = "bln_mean")
  bln_sd <- bln[, lapply(.SD, sd), by = idcols] |>
    melt(id.vars = idcols, variable.name = "variable", value.name = "bln_sd")
  int_mean <- int[, lapply(.SD, mean), by = idcols] |>
    melt(id.vars = idcols, variable.name = "variable", value.name = "int_mean")
  int_sd <- int[, lapply(.SD, sd), by = idcols] |>
    melt(id.vars = idcols, variable.name = "variable", value.name = "int_sd")

  data <- bln_mean |>
    merge(bln_sd) |>
    merge(int_mean) |>
    merge(int_sd) |>
    na.omit(c("bln_mean", "int_mean"))

  data[, {
    bln_values <- rnorm(1000, bln_mean, bln_sd)
    int_values <- rnorm(1000, int_mean, int_sd)
    diffs <- int_values - bln_values
    t_test <- t.test(diffs)
    list(
      diff = median(diffs, na.rm = TRUE),
      diff_lower = quantile(diffs, 0.025, na.rm = TRUE),
      diff_upper = quantile(diffs, 0.975, na.rm = TRUE),
      diff_pval = t_test$p.value
    )
  }, by = c(idcols, "variable")]
}
