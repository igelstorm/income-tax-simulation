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
#SBATCH --array=0-3%1

module load apps/R/4.4.1/gcc-8.5.0+openblas-0.3.28
module load apps/java/23.0.1/noarch

export JAVA_TOOL_OPTIONS="-Xmx6g -XX:+ExitOnOutOfMemoryError"
ARGS=(baseline dk mis flat)

Rscript scripts/02_run_simpaths.R ${ARGS[$SLURM_ARRAY_TASK_ID]}
