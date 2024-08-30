cut_quantile <- function(x, q = 5, w = NULL) {
  cut(
    x,
    Hmisc::wtd.quantile(x, weights = w, probs = 0:q/q),
    include.lowest = TRUE,
    labels = 1:q
  )
}

summary <- function(data) {
  data = tar_read(output_baseline)
  setDT(data)
  top_level <- data[, .(
    govt_revenue2 = sum(dwt * (ils_tax + ils_sicdy + ils_sicer)),
    govt_expenditure = sum(dwt * ils_ben)
  )]

  by_hh <- data[,.(
    ils_dispy = sum(ils_dispy),
    dwt = sum(dwt),
    equiv = 0.67 + 0.33*(sum(dag >= 14) - 1) + 0.2*sum(dag <= 13)
  ), by = "idhh"]
  by_hh[, ils_dispy_eq := ils_dispy / equiv]
  by_hh[, inc_quintile := cut_quantile(ils_dispy_eq, q = 5, w = dwt)]
  by_hh[, inc_decile := cut_quantile(ils_dispy_eq, q = 10, w = dwt)]

  # S80/S20
  by_hh[inc_quintile == 5, sum(dwt * ils_dispy_eq)] / by_hh[inc_quintile == 1, sum(dwt * ils_dispy_eq)]

  # Gini
  by_hh[, dineq::gini.wtd(pmax(0, ils_dispy_eq), dwt)]

  # Mean income by decile
  weeks_in_month <- (365 / 12) / 7
  deciles <- by_hh[, .(
    mean_inc_eq = stats::weighted.mean(ils_dispy_eq / weeks_in_month, dwt),
    tot_inc = sum(ils_dispy * dwt)
  ), by = inc_decile]
  deciles[, share := 100 * tot_inc / sum(tot_inc)]
  deciles[order(inc_decile)]
}
