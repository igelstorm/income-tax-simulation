library(dplyr)
library(ggplot2)
library(targets)

estimates_data <- list(
  baseline = tar_read(estimates_baseline),
  dk = tar_read(estimates_dk),
  flat = tar_read(estimates_flat),
  mis = tar_read(estimates_mis)
) |>
  bind_rows(.id = "scenario")

effects_data <-  list(
  dk = tar_read(effects_dk),
  mis = tar_read(effects_mis),
  flat = tar_read(effects_flat)
) |>
  bind_rows(.id = "scenario")

# Trajectory by quintile
facet_labels <- c(
  dk = "Enhanced\nprogressivity\n+ benefits",
  mis = "Enhanced\nprogressivity",
  flat = "Reduced\nprogressivity",
  `1` = "Q1 (bottom)",
  `2` = "Q2",
  `3` = "Q3",
  `4` = "Q4",
  `5` = "Q5 (top)"
)
baseline_estimates <- estimates_data |>
  filter(scenario == "baseline") |>
  filter(strata == "inc_quintile") |>
  filter(variable == "mean_mhcase") |>
  select(time, inc_quintile, value, value_lower, value_upper)
estimates_data |>
  filter(scenario != "baseline") |>
  filter(strata == "inc_quintile") |>
  filter(variable == "mean_mhcase") |>
  select(scenario, inc_quintile, time, value, value_lower, value_upper) |>
  left_join(baseline_estimates, by = c("time", "inc_quintile"), suffix = c(".int", ".bl")) |>
  ggplot() +
  aes(x = time) +
  geom_line(aes(y = value.int)) +
  geom_line(aes(y = value.bl), linetype = "dashed") +
  geom_ribbon(aes(y = value.int, ymin = value_lower.int, ymax = value_upper.int), alpha = 0.05, fill = "blue") +
  geom_ribbon(aes(y = value.bl, ymin = value_lower.bl, ymax = value_upper.bl), alpha = 0.05, fill = "green") +
  facet_grid(
    rows = vars(scenario),
    cols = vars(inc_quintile),
    labeller = as_labeller(facet_labels)
  ) +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(x = "Year", y = "Prevalence of common mental disorders (%)") +
  theme_bw() +
  theme(strip.text.y.left = element_text(angle = 0))

ggsave("output/trajectory_quintiles.png", width = 6, height = 4, dpi = 900)




# Inequality measures
facet_labels <- c(
  dk = "Enhanced\nprogressivity\n+ benefits",
  mis = "Enhanced\nprogressivity",
  flat = "Reduced\nprogressivity",
  s80s20 = "S80/S20",
  gini = "Gini index",
  log_rii = "Relative index of inequality"
)
baseline_estimates <- estimates_data |>
  filter(scenario == "baseline") |>
  filter(strata == "population") |>
  filter(variable %in% c("s80s20", "gini", "log_rii")) |>
  select(time, variable, value, value_lower, value_upper)
estimates_data |>
  filter(scenario != "baseline") |>
  filter(strata == "population") |>
  filter(variable %in% c("s80s20", "gini", "log_rii")) |>
  select(scenario, variable, time, value, value_lower, value_upper) |>
  left_join(baseline_estimates, by = c("time", "variable"), suffix = c(".int", ".bl")) |>
  ggplot() +
  aes(x = time) +
  geom_line(aes(y = value.int)) +
  geom_line(aes(y = value.bl), linetype = "dashed") +
  geom_ribbon(aes(y = value.int, ymin = value_lower.int, ymax = value_upper.int), alpha = 0.05, fill = "blue") +
  geom_ribbon(aes(y = value.bl, ymin = value_lower.bl, ymax = value_upper.bl), alpha = 0.05, fill = "green") +
  ggh4x::facet_grid2(
    rows = vars(scenario),
    cols = vars(variable),
    independent = "y",
    scales = "free_y",
    labeller = as_labeller(facet_labels)
  ) +
  # scale_y_continuous(labels = scales::label_percent()) +
  labs(x = "Year", y = NULL) +
  theme_bw() +
  theme(strip.text.y.left = element_text(angle = 0))
ggsave("output/econ_comparison.png", width = 7, height = 4, dpi = 900)
