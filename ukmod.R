library(data.table)
library(glue)
library(RStata)

options("RStata.StataPath" = "\"C:\\Program Files\\Stata18\\StataMP-64.exe\"")
options("RStata.StataVersion" = 18)

model_path <- here::here("UKMOD-PUBLIC-B2024.14")
current_dir <- here::here()

input_data <- fread("UKMOD-PUBLIC-B2024.14/Input/UK_2019_a2.txt")

baseline_output <- stata(
  paste(
    glue("euromod_run, model(\"{model_path}\") system(UK_2024_MIS) dataset(UK_2019_a2.txt) country(UK)"),
    glue("cd {current_dir}"),
    sep = "\n"
  ),
  data.in = input_data,
  data.out = TRUE,
  stata.echo = TRUE
)

baseline_output <- as.data.table(baseline_output)
revenue <- baseline_output[, sum(dwt * (ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer))]
expenditure <- baseline_output[, sum(dwt * ils_ben)]
baseline_balance <- revenue - expenditure
baseline_balance


tax_incr <- 0.05

output <- stata(
  paste(
    glue("euromod_run, model(\"{model_path}\") system(UK_2024_MIS) dataset(UK_2019_a2.txt) country(UK) constants(\"MISTaxIncr = '{tax_incr}'\")"),
    glue("cd {current_dir}"),
    sep = "\n"
  ),
  data.in = input_data,
  data.out = TRUE,
  stata.echo = TRUE
)
