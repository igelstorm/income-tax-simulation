library(data.table)
library(ggpubr)
library(glue)
library(RStata)
library(scales)

source("R/euromod.R")

model_path <- here::here("UKMOD-PUBLIC-B2024.14")
input_data <- fread("UKMOD-PUBLIC-B2024.14/Input/UK_2022_a1.txt")

baseline_output <- run_euromod(
  input_data,
  system = "UK_2024",
  dataset = "UK_2022_a1.txt",
  model_path = model_path
)

baseline_output <- as.data.table(baseline_output)
revenue <- baseline_output[, sum(dwt * (ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer))]
expenditure <- baseline_output[, sum(dwt * ils_ben)]
baseline_balance <- revenue - expenditure
baseline_balance


results <- data.table()

for (tax_rate in c(0.185, 0.187)) {
  print(tax_rate)
  output <- run_euromod(
    input_data,
    constants = list(
      ITPerAll = "0#y",
      ITRate1 = tax_rate,
      ITRate2 = tax_rate,
      ITRate3 = tax_rate,
      ITRate1S = tax_rate,
      ITRate2S = tax_rate,
      ITRate3S = tax_rate,
      ITRate4S = tax_rate,
      ITRate5S = tax_rate,
      ITRate6S = tax_rate
    ),
    system = "UK_2024",
    dataset = "UK_2022_a1.txt",
    model_path = model_path
  )
  output <- as.data.table(output)
  revenue <- output[, sum(dwt * (ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer))]
  expenditure <- output[, sum(dwt * ils_ben)]
  balance <- revenue - expenditure
  results <- rbind(results, data.table(
    tax_rate = tax_rate,
    balance = balance
  ))
}

results[, relative_balance := balance - baseline_balance]
ggscatter(
  results,
  "tax_rate",
  "relative_balance",
  xlab = "Tax rate",
  ylab = "Government surplus relative to baseline",
  add = "reg.line"
) +
  scale_x_continuous(labels = label_percent()) +
  scale_y_continuous(labels = label_currency(
    prefix = "£",
    scale_cut = cut_short_scale()
  )) +
  expand_limits(y = 0) +
  geom_hline(yintercept = 0, linetype = "dashed")
results

# Gini almost matches that shown in Statistics Presenter (a few 0.001 off)
baseline_output |>
  _[,.(
    income = sum(ils_dispy),
    weight = sum(dwt),
    equiv = 0.67 + 0.33*(sum(dag >= 14) - 1) + 0.2*sum(dag <= 13)
  ), by = "idhh"] |>
  _[income >= 0] |>
  _[, DescTools::Gini(income/equiv, weight)]
