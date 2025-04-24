library(targets)

int_scenario <- "dk"
varname <- "rii"

bln <- tar_read(simpaths_summary_baseline, store = here::here("_targets"))
int <- tar_read_raw(paste0("simpaths_summary_", int_scenario), store = here::here("_targets"))

bln_values <- bln[strata == "population" & time == 2026, get(varname)]
int_values <- int[strata == "population" & time == 2026, get(varname)]
diffs <- int_values - bln_values

bln_mean <- mean(bln_values)
int_mean <- mean(int_values)
bln_sd <- sd(bln_values)
int_sd <- sd(int_values)
diff_mean <- mean(diffs)
diff_sd <- sd(diffs)

n <- length(diffs)

paste(
  sprintf("Intervention scenario: %s", int_scenario),
  sprintf(
    "Baseline value:      %.3f (%.3f, %.3f)",
    bln_mean,
    bln_mean + qt(0.025, df = n - 1) * bln_sd,
    bln_mean + qt(0.975, df = n - 1) * bln_sd
  ),
  sprintf(
    "Intervention value:  %.3f (%.3f, %.3f)",
    int_mean,
    int_mean + qt(0.025, df = n - 1) * int_sd,
    int_mean + qt(0.975, df = n - 1) * int_sd
  ),
  sprintf(
    "Difference:          %.3f (%.3f, %.3f)",
    diff_mean,
    diff_mean + qt(0.025, df = n - 1) * diff_sd,
    diff_mean + qt(0.975, df = n - 1) * diff_sd
  ),
  sep = "\n"
) |>
  c("\n") |>
  cat()
