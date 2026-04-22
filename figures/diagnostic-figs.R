library(dplyr)
library(ggplot2)

estimates_data <- list(
  baseline = fread(here::here("data", "simpaths_output", "baseline", "summarised_output.csv"))
) |>
  bind_rows(.id = "scenario")

id_cols = c(
  "time", "scenario", "strata",
  "inc_decile", "inc_quintile", "demMaleFlag", "eduHighestC4", "age_cat"
)
val_cols <- setdiff(names(estimates_data), id_cols)

runs <- length(unique(estimates_data$seed))

value_mean <- estimates_data[, lapply(.SD, mean), by = id_cols] |>
  melt(id.vars = id_cols, variable.name = "variable", value.name = "value_mean")
value_sd <- estimates_data[, lapply(.SD, sd), by = id_cols] |>
  melt(id.vars = id_cols, variable.name = "variable", value.name = "value_sd")

estimates_data <- merge(value_mean, value_sd) |>
  na.omit("value_mean")

estimates_data <- estimates_data[, {
  list(
    value = value_mean,
    value_lower = value_mean + qt(0.025, df = runs - 1) * value_sd,
    value_upper = value_mean + qt(0.975, df = runs - 1) * value_sd
  )
}, by = c(id_cols, "variable")]

# Trajectory by decile
facet_labels <- c(
  dk = "Enhanced\nprogressivity\n+ benefits",
  mis = "Enhanced\nprogressivity",
  flat = "Reduced\nprogressivity",
  `1` = "D1 (bottom)",
  `2` = "D2",
  `3` = "D3",
  `4` = "D4",
  `5` = "D5",
  `6` = "D6",
  `7` = "D7",
  `8` = "D8",
  `9` = "D9",
  `10` = "D10 (top)"
)

estimates_data |>
  filter(scenario == "baseline") |>
  filter(strata == "inc_decile") |>
  filter(variable == "mean_mhcase") |>
  select(time, inc_decile, value, value_lower, value_upper) |>
  ggplot() +
  aes(x = time) +
  geom_line(aes(y = value)) +
  geom_ribbon(aes(y = value, ymin = value_lower, ymax = value_upper), alpha = 0.05, fill = "blue") +
  facet_grid(
    cols = vars(inc_decile),
    labeller = as_labeller(facet_labels)
  ) +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(x = "Year", y = "Prevalence of common mental disorders (%)") +
  theme_bw() +
  theme(strip.text.y.left = element_text(angle = 0))
ggsave("output/mhcase_deciles.png", width = 6, height = 4, dpi = 900)

estimates_data$variable |> unique()
estimates_data |>
  filter(scenario == "baseline") |>
  filter(strata == "population") |>
  filter(variable == "mean_mhcase") |>
  select(time, value, value_lower, value_upper) |>
  ggplot() +
  aes(x = time) +
  geom_line(aes(y = value)) +
  geom_ribbon(aes(y = value, ymin = value_lower, ymax = value_upper), alpha = 0.05, fill = "blue") +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(x = "Year", y = "Prevalence of common mental disorders (%)") +
  theme_bw() +
  theme(strip.text.y.left = element_text(angle = 0))
ggsave("output/mhcase_pop.png", width = 6, height = 4, dpi = 900)

estimates_data |>
  filter(scenario == "baseline") |>
  filter(strata == "population") |>
  filter(variable == "emp_rate") |>
  select(time, value, value_lower, value_upper) |>
  ggplot() +
  aes(x = time) +
  geom_line(aes(y = value)) +
  geom_ribbon(aes(y = value, ymin = value_lower, ymax = value_upper), alpha = 0.05, fill = "blue") +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(x = "Year", y = "Employment rate (%)") +
  theme_bw() +
  theme(strip.text.y.left = element_text(angle = 0))
ggsave("output/emp_rate_pop.png", width = 6, height = 4, dpi = 900)
