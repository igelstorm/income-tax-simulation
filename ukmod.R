euromod_exe <- "C:\\Program Files\\EUROMOD\\Executable\\EM_ExecutableCaller.exe"
project_dir <- here::here("UKMOD-PUBLIC-B2024.14")

timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
input_dir   <- here::here("_ukmod_tmp", timestamp, "input")
output_dir  <- here::here("_ukmod_tmp", timestamp, "output")
config_path <- here::here("_ukmod_tmp", timestamp, "config.xml")

input_filename <- "UK_2019_a2.txt"
input_path <- file.path(project_dir, "Input", input_filename)
country_file <- "UK.xml"

# dir.create(input_dir, recursive = TRUE)
dir.create(output_dir, recursive = TRUE)

tictoc::tic()
sys::exec_wait(
  euromod_exe,
  std_out = TRUE,
  std_err = TRUE,
  args = c(
    "-emPath", project_dir,
    "-sys", "UK_2024",
    "-data", "UK_2019_a2.txt",
    "-outPath", output_dir
  )
)
tictoc::toc()

out_files <- list.files(output_dir)
out_file <- out_files[!grepl("EUROMOD_Log\\.txt$", out_files)]

out_data <- data.table::fread(file.path(output_dir, out_file))

out_data

unlink(here::here("_ukmod_tmp", timestamp), recursive = TRUE)
