#!/bin/bash

# Utility script

HPC_USER=eii2t
HPC_URL=mars-login.ice.gla.ac.uk
HPC_CODE_DIR=/users/eii2t/src

scp -r $HPC_USER@$HPC_URL:$HPC_CODE_DIR/income-tax-simulation/data/simpaths_output/* ./data/simpaths_output/
