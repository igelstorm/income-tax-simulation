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

for (top_rate in seq(0.80, 0.82, 0.01)) {
  print(top_rate)
  output <- run_euromod(
    input_data,
    constants = list(
      MISTaxIncr = top_rate
    ),
    system = "UK_2024_MIS",
    dataset = "UK_2022_a1.txt",
    model_path = model_path
  )
  output <- as.data.table(output)
  revenue <- output[, sum(dwt * (ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer))]
  expenditure <- output[, sum(dwt * ils_ben)]
  balance <- revenue - expenditure
  results <- rbind(results, data.table(
    top_rate = top_rate,
    balance = balance
  ))
}

results[, relative_balance := balance - baseline_balance]
ggscatter(
  results,
  "top_rate",
  "relative_balance",
  xlab = "Top tax rate",
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
