options("RStata.StataPath" = "\"C:\\Program Files\\Stata18\\StataMP-64.exe\"")
options("RStata.StataVersion" = 18)

run_euromod <- function(
  data,
  system,
  dataset,
  model_path,
  wd = here::here()
) {
  command <- euromod_command(
    system = system,
    dataset = dataset,
    model_path = model_path
  )
  stata(
    command,
    data.in = data,
    data.out = TRUE,
    stata.echo = TRUE
  )
}

euromod_command <- function(
  system,
  dataset,
  model_path,
  wd = here::here()
) {
  paste(
    # The euromod_run command changes the working directory, and RStata relies
    # on the working directory remaining the same, so it's necessary to reset
    # it to the correct one both at the start and the end to avoid intermittent
    # errors.
    glue("cd {wd}"),
    glue("euromod_run, model(\"{model_path}\") system({system}) dataset({dataset}) country(UK)"),
    glue("cd {wd}"),
    sep = "\n"
  )
}
