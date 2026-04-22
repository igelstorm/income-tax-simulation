library(data.table)
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
  labs(x = "Year", y = "Prevalence of GHQ >= 4 (%)") +
  theme_bw() +
  theme(strip.text.y.left = element_text(angle = 0))
ggsave("output/mhcase_pop.png", width = 6, height = 4, dpi = 900)

estimates_data |>
  filter(scenario == "baseline") |>
  filter(strata == "population") |>
  filter(variable == "mean_mcscase35") |>
  select(time, value, value_lower, value_upper) |>
  ggplot() +
  aes(x = time) +
  geom_line(aes(y = value)) +
  geom_ribbon(aes(y = value, ymin = value_lower, ymax = value_upper), alpha = 0.05, fill = "blue") +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(x = "Year", y = "Prevalence of SF-12 MCS < 35 (%)") +
  theme_bw() +
  theme(strip.text.y.left = element_text(angle = 0))
ggsave("output/mcscase35_pop.png", width = 6, height = 4, dpi = 900)

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

all_data <- readRDS(here::here("data", "simpaths_output", "baseline", "all_data.rds"))
all_data |>
  filter(seed == 100) |>
  mutate(ghq_rounded = round(healthPsyDstrss0to12)) |>
  group_by(time, ghq_rounded) |>
  summarise(count = n()) |>
  group_by(time) |>
  mutate(prop = count / sum(count)) |>
  ggplot() +
  aes(x = time, y = prop, fill = factor(ghq_rounded)) +
  geom_area() +
  scale_fill_discrete(palette = scales::pal_viridis()) +
  labs(x = "Year", y = "Proportion of population", fill = "GHQ-12 score") +
  theme_bw()
ggsave("output/ghq_distribution.png", width = 6, height = 4, dpi = 900)
