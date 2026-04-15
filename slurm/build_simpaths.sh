#!/bin/bash

#SBATCH --account=none
#SBATCH --job-name=build_simpaths
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#SBATCH --partition=nodes
#SBATCH --time=0-01:00:00
#SBATCH --mem=1G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1

SIMPATHS_DIR=~/src/SimPaths

module load apps/java/23.0.1/noarch

mvn clean package
