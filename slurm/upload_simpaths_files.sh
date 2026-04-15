#!/bin/bash

# Utility script

HPC_USER=eii2t
HPC_URL=mars-login.ice.gla.ac.uk
HPC_CODE_DIR=/users/eii2t/src

scp -r ../SimPaths/multirun.jar $HPC_USER@$HPC_URL:$HPC_CODE_DIR/SimPaths/multirun.jar
scp -r ../SimPaths/singlerun.jar $HPC_USER@$HPC_URL:$HPC_CODE_DIR/SimPaths/singlerun.jar
scp -r data/euromod_output/* $HPC_USER@$HPC_URL:$HPC_CODE_DIR/income-tax-simulation/data/euromod_output
scp -r ../SimPaths/input/population_initial_UK_*.csv $HPC_USER@$HPC_URL:$HPC_CODE_DIR/SimPaths/input
