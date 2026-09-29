export JAVA_TOOL_OPTIONS="-Xmx6g -XX:+ExitOnOutOfMemoryError"
export FIRST_YEAR=2023
export LAST_YEAR=2035
export POPULATION=25000
export STARTING_SEED=100
export RUNS_PER_BATCH=1
export BATCHES=1
export SIMPATHS_PATH=../SimPaths

export SCENARIO=baseline
Rscript scripts/02_run_simpaths.R
Rscript scripts/03_summarise_outputs.R

export SCENARIO=mis
Rscript scripts/02_run_simpaths.R
Rscript scripts/03_summarise_outputs.R

export SCENARIO=dk
Rscript scripts/02_run_simpaths.R
Rscript scripts/03_summarise_outputs.R

export SCENARIO=flat
Rscript scripts/02_run_simpaths.R
Rscript scripts/03_summarise_outputs.R
