#!/bin/bash
#SBATCH --job-name=simincometax
#SBATCH --nodes=1
#SBATCH --ntasks=1

module load R/4.4.1
module load openjdk/21.0.0_35-gcc-14.2.0-linux-rocky9-zen-k6vbf5i

Rscript ./scripts/02_run_simpaths.R
