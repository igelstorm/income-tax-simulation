library(targets)

int_scenario <- "dk"
variable <- "mh_case"

# Baseline and intervention data
bln <- tar_read(simpaths_summary_baseline, store = here::here("_targets"))
int <- tar_read_raw(paste0("simpaths_summary_", int_scenario), store = here::here("_targets"))

bln_values <- bln[strata == "population" & time == 2026, get(variable)]
int_values <- int[strata == "population" & time == 2026, get(variable)]
diffs <- sample(int_values, 1000, replace = TRUE) - sample(bln_values, 1000, replace = TRUE)

paste(
  sprintf("Intervention scenario: %s", int_scenario),
  sprintf(
    "Baseline value:      %.3f (%.3f, %.3f)",
    median(bln_values, na.rm = TRUE),
    quantile(bln_values, 0.025, na.rm = TRUE),
    quantile(bln_values, 0.975, na.rm = TRUE)
  ),
  sprintf(
    "Intervention value:  %.3f (%.3f, %.3f)",
    median(int_values, na.rm = TRUE),
    quantile(int_values, 0.025, na.rm = TRUE),
    quantile(int_values, 0.975, na.rm = TRUE)
  ),
  sprintf(
    "Difference:          %.3f (%.3f, %.3f)",
    median(diffs, na.rm = TRUE),
    quantile(diffs, 0.025, na.rm = TRUE),
    quantile(diffs, 0.975, na.rm = TRUE)
  ),
  sep = "\n"
) |>
  c("\n") |>
  cat()
