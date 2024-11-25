calculate_balance <- function(data) {
  data <- as.data.table(data)
  revenue <- data[, sum(dwt * (ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer))]
  expenditure <- data[, sum(dwt * ils_ben)]
  revenue - expenditure
}

triangulate_reform <- function(
  data,
  system,
  dataset,
  model_path,
  baseline_data,
  reform_constants,
  x_values
) {
  results <- data.table()
  for (x in x_values) {
    print(x)
    output <- run_euromod(
      data,
      constants = lapply(reform_constants, \(str) glue::glue_data(.x = list(x = x), str)),
      system = system,
      dataset = dataset,
      model_path = model_path
    )
    balance <- calculate_balance(output)
    results <- rbind(results, data.table(
      x = x,
      balance = balance
    ))
  }
  baseline_balance <- calculate_balance(baseline_data)
  results[, relative_balance := balance - baseline_balance]
  results
}

plot_triangulation <- function(results, xlab) {
  ggscatter(
    results,
    "x",
    "relative_balance",
    xlab = xlab,
    ylab = "Government surplus relative to baseline",
    add = "reg.line"
  ) +
    scale_y_continuous(labels = scales::label_currency(
      prefix = "£",
      scale_cut = scales::cut_short_scale()
    )) +
    expand_limits(y = 0) +
    geom_hline(yintercept = 0, linetype = "dashed")
}
