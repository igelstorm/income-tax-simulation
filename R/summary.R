cut_quantile <- function(x, q = 5, w = NULL) {
  cut(
    x,
    # Using Hmisc::wtd.quantile here caused occasional edge cases to assign the
    # quantile NA to the highest and lowest observations, presumably because of
    # rounding/floating point errors in the 0th and 100th percentiles.
    # DescTools::Quantile doesn't seem to have this problem.
    DescTools::Quantile(x, weights = w, probs = 0:q/q),
    include.lowest = TRUE,
    labels = 1:q
  )
}

high_level_summary <- function(data) {
  setDT(data)
  hh_data <- data[,.(
    ils_dispy = sum(ils_dispy),
    dwt       = sum(dwt),
    equiv     = 0.67 + 0.33*(sum(dag >= 14) - 1) + 0.2*sum(dag <= 13)
  ), by = "idhh"]
  hh_data[, ils_dispy_eq := ils_dispy / equiv]
  hh_data[, inc_quintile := cut_quantile(ils_dispy_eq, q = 5, w = dwt)]

  cbind(
    data[, .(
      govt_revenue = sum(dwt * (ils_tax + ils_sicdy + ils_sicer)),
      govt_expenditure = sum(dwt * ils_ben)
    )],
    hh_data[, .(
      s80s20 = sum(ils_dispy_eq * dwt * (inc_quintile == 5)) / sum(ils_dispy_eq * dwt * (inc_quintile == 1)),
      gini = dineq::gini.wtd(pmax(0, ils_dispy_eq), dwt)
    )]
  )
}

decile_summary <- function(data) {
  setDT(data)
  hh_data <- data[,.(
    ils_dispy = sum(ils_dispy),
    dwt       = sum(dwt),
    equiv     = 0.67 + 0.33*(sum(dag >= 14) - 1) + 0.2*sum(dag <= 13)
  ), by = "idhh"]
  hh_data[, ils_dispy_eq := ils_dispy / equiv]
  hh_data[, inc_decile := cut_quantile(ils_dispy_eq, q = 10, w = dwt)]

  weeks_in_month <- (365 / 12) / 7

  deciles <- hh_data[, .(
    mean_inc_eq = stats::weighted.mean(ils_dispy_eq / weeks_in_month, dwt),
    tot_inc = sum(ils_dispy * dwt)
  ), by = inc_decile]
  deciles[, share := tot_inc / sum(tot_inc)]
  deciles[, tot_inc := NULL]
  deciles[order(inc_decile)]
}
