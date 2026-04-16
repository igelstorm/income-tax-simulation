#!/bin/bash

#SBATCH --account=none
#SBATCH --job-name=summarise_outputs
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#SBATCH --partition=nodes
#SBATCH --mem=4G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --mail-user=erik.igelstrom@glasgow.ac.uk
#SBATCH --mail-type=ALL

module load apps/R/4.4.1/gcc-8.5.0+openblas-0.3.28

Rscript scripts/03_summarise_outputs.R
