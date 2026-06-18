#!/bin/bash

#SBATCH --account=none
#SBATCH --job-name=run_simpaths
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#SBATCH --partition=nodes
#SBATCH --time=2-00:00:00
#SBATCH --mem=8G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --mail-user=erik.igelstrom@glasgow.ac.uk
#SBATCH --mail-type=ALL

module load apps/R/4.4.1/gcc-8.5.0+openblas-0.3.28
module load apps/java/23.0.1/noarch

export JAVA_TOOL_OPTIONS="-Xmx6g -XX:+ExitOnOutOfMemoryError"

export SCENARIO=baseline
export FIRST_YEAR=2023
export LAST_YEAR=2035
export POPULATION=25000
export STARTING_SEED=100
export RUNS_PER_BATCH=10
export BATCHES=100
export SIMPATHS_PATH=../SimPaths

Rscript scripts/02_run_simpaths.R
