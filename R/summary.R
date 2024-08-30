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
    govt_revenue = sum(dwt * (ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer)),
    govt_expenditure = sum(dwt * ils_ben)
  )]

  by_hh <- data[,.(
    ils_dispy = sum(ils_dispy),
    ils_origy = sum(ils_origy),
    weight = sum(dwt),
    equiv = 0.67 + 0.33*(sum(dag >= 14) - 1) + 0.2*sum(dag <= 13)
    # equiv = 1 + 0.5*(sum(dag >= 14) - 1) + 0.3*sum(dag <= 13)
  ), by = "idhh"]

  by_hh[, ils_dispy_equ := ils_dispy / equiv]
  by_hh[, ils_dispy_equ_qnt := cut_quantile(ils_dispy_equ, q = 5, w = weight)]
  by_hh[, ils_dispy_equ_dec := cut_quantile(ils_dispy_equ, q = 10, w = weight)]

  # S80/S20
  by_hh[ils_dispy_equ_qnt == 5, sum(weight * ils_dispy_equ)] / by_hh[ils_dispy_equ_qnt == 1, sum(weight * ils_dispy_equ)]

  # Gini
  by_hh[, dineq::gini.wtd(pmax(0, ils_dispy_equ), weight)]

  by_hh[, stats::weighted.mean(ils_dispy_equ, weight), by = ils_dispy_equ_dec]
  by_hh[, mean(ils_dispy_equ)]

  by_hh[, mean(ils_dispy_equ)]

  data[idhh == 5] |> View()

}
