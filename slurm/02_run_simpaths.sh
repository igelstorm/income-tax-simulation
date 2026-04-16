#!/bin/bash

#SBATCH --account=none
#SBATCH --job-name=run_simpaths
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#SBATCH --partition=nodes
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --ntasks-per-node=1

module load apps/R/4.4.1/gcc-8.5.0+openblas-0.3.28
module load apps/java/23.0.1/noarch

Rscript scripts/02_run_simpaths.R
