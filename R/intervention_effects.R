calculate_difference <- function(baseline_data, intervention_data) {
  bln <- baseline_data
  int <- intervention_data

  id_cols = c("time", "strata", "inc_decile", "dgn", "deh_c3", "age_cat")
  val_cols <- setdiff(names(bln), id_cols)

  diffs <- bln[, .SD, .SDcols = id_cols]
  for (col in val_cols) {
    diffs[, (col) := int[[col]] - bln[[col]]]
  }

  runs <- length(unique(bln$run))

  diff_mean <- diffs[, lapply(.SD, mean), by = id_cols] |>
    melt(id.vars = id_cols, variable.name = "variable", value.name = "diff_mean")
  diff_sd <- diffs[, lapply(.SD, sd), by = id_cols] |>
    melt(id.vars = id_cols, variable.name = "variable", value.name = "diff_sd")

  data <- merge(diff_mean, diff_sd) |>
    na.omit("diff_mean")

  data[, {
    list(
      diff = diff_mean,
      diff_lower = diff_mean + qt(0.025, df = runs - 1) * diff_sd,
      diff_upper = diff_mean + qt(0.975, df = runs - 1) * diff_sd
    )
  }, by = c(id_cols, "variable")]
}

calculate_cis <- function(data) {
  id_cols = c("time", "strata", "inc_decile", "dgn", "deh_c3", "age_cat")
  val_cols <- setdiff(names(data), id_cols)

  runs <- length(unique(data$run))

  value_mean <- data[, lapply(.SD, mean), by = id_cols] |>
    melt(id.vars = id_cols, variable.name = "variable", value.name = "value_mean")
  value_sd <- data[, lapply(.SD, sd), by = id_cols] |>
    melt(id.vars = id_cols, variable.name = "variable", value.name = "value_sd")

  data <- merge(value_mean, value_sd) |>
    na.omit("value_mean")

  data[, {
    list(
      value = value_mean,
      value_lower = value_mean + qt(0.025, df = runs - 1) * value_sd,
      value_upper = value_mean + qt(0.975, df = runs - 1) * value_sd
    )
  }, by = c(id_cols, "variable")]
}
