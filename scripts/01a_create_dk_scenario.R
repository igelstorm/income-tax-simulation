library(data.table)

uc_multiplier <- 4.419
intervention_year <- 2026

output_path <- here::here("data", "euromod_output", "dk")

if (!dir.exists(output_path)) {
  dir.create(output_path)
}

filenames <- list.files(here::here("data", "euromod_output", "baseline"))

for (filename in filenames) {
  baseline <- fread(
    here::here("data", "euromod_output", "baseline", filename),
    select = c("idhh", "idperson", "bsauc_s")
  )
  dk_raw <- fread(here::here("data", "euromod_output", "dk_raw", filename))

  year <- as.numeric(stringr::str_extract(filename, "[0-9]+"))
  if (year < intervention_year) {
    print(paste(filename, ": Prior to intervention year - no changes made"))
    fwrite(dk_raw, here::here("data", "euromod_output", "dk", filename))
    next
  }
  print(paste(filename, ": Processing"))

  # Identify who is eligible for UC in the baseline scenario
  baseline[, uc_elig := bsauc_s > 0]

  dk <- dk_raw |>
    merge(baseline[, .(idhh, idperson, uc_elig)], by = c("idhh", "idperson"))

  # Increase UC for people who received UC in the baseline scenario, set it to zero for everyone else
  dk[, bsauc_s_new := bsauc_s * uc_multiplier * uc_elig]
  dk[, bsauc_s_diff := bsauc_s_new - bsauc_s]

  # Income lists that include bsauc_s and therefore need to be updated
  income_lists <- c(
    "il_bencap",
    "il_dispy_ahc",
    "ils_benmt",
    "ils_ben",
    "ils_dispy",
    "ils_bensim",
    "ils_b2_bsaho",
    "ils_b1_bsa",
    "ils_udb_bsa",
    "ils_udb_yds",
    "il_bchmt"
  )
  for (income_list in income_lists) {
    if (is.null(dk[[income_list]])) {
      print(paste(income_list, "is not defined in", filename, "(this is probably fine)"))
      next
    }
    dk[[income_list]] <- dk[[income_list]] + dk$bsauc_s_diff
  }
  dk[, bsauc_s := bsauc_s_new]
  dk[, c("bsauc_s_new", "bsauc_s_diff", "uc_elig") := NULL]

  fwrite(dk, here::here("data", "euromod_output", "dk", filename))
}
