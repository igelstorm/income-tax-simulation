options("RStata.StataPath" = "\"C:\\Program Files\\Stata18\\StataMP-64.exe\"")
options("RStata.StataVersion" = 18)

run_euromod <- function(
  data,
  system,
  dataset,
  constants = list(),
  model_path,
  echo = FALSE,
  wd = here::here()
) {
  command <- euromod_command(
    system = system,
    dataset = dataset,
    constants = constants,
    model_path = model_path
  )
  RStata::stata(
    command,
    data.in = data,
    data.out = TRUE,
    stata.echo = echo
  )
}

euromod_command <- function(
  system,
  dataset,
  constants = list(),
  model_path,
  wd = here::here()
) {
  constant_string <- ifelse(
    length(constants) > 0,
    paste0(
      " constants(",
      paste0(
        "\"",
        names(constants),
        " = '",
        unlist(constants),
        "'\"",
        collapse = " "
      ),
      ")"
    ),
    ""
  )
  paste(
    # The euromod_run command changes the working directory, and RStata relies
    # on the working directory remaining the same, so it's necessary to reset
    # it to the correct one both at the start and the end to avoid intermittent
    # errors.
    glue::glue("cd {wd}"),
    glue::glue("euromod_run, model(\"{model_path}\") system({system}) dataset({dataset}) country(UK){constant_string}"),
    glue::glue("cd {wd}"),
    sep = "\n"
  )
}
