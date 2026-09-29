library(data.table)
library(ggplot2)

baseline <- fread(here::here("data", "euromod_output", "baseline", "uk_2026_std.txt"))
dk_raw <- fread(here::here("data", "euromod_output", "dk_raw", "uk_2026_std.txt"))

x_values <- c(4.418, 4.419, 4.420)

# Calculate baseline (bl) revenue and expenditure
bl_revenue <- baseline[, sum(dwt * (ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer))]
bl_expenditure <- baseline[, sum(dwt * (ils_ben))]
bl_balance <- bl_revenue - bl_expenditure

results = data.table(x_value = x_values)

# Identify who is eligible for UC in the baseline scenario
baseline[, uc_elig := bsauc_s > 0]

for (x in x_values) {
  # Create a new dataset for the reform scenario
  dk_new <- dk_raw |>
    merge(baseline[, .(idperson, uc_elig)], by = "idperson")
  # Increase UC for people who received UC in the baseline scenario, set it to zero for everyone else
  dk_new[, bsauc_s_new := bsauc_s * x * uc_elig]
  dk_new[, bsauc_s_diff := bsauc_s_new - bsauc_s]

  revenue <- dk_new[, sum(dwt * (ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer))]
  expenditure <- dk_new[, sum(dwt * (ils_ben + bsauc_s_diff))]
  balance <- revenue - expenditure

  results[x_value == x, let(
    revenue = ..revenue,
    expenditure = ..expenditure,
    balance = ..balance,
    revenue_vs_bl = ..revenue - bl_revenue,
    expenditure_vs_bl = ..expenditure - bl_expenditure,
    balance_vs_bl = ..balance - bl_balance
  )]
}

ggplot(results) +
  aes(x = x_value, y = balance_vs_bl) +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = 0) +
  ylab("Balance compared to baseline") +
  theme_bw()
