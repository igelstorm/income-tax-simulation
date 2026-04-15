# Tax reforms vs benefit enhancement to address mental health inequalities: a microsimulation study

## Overview

The analysis has three distinct stages:

1. Create policy scenarios using EUROMOD **(requires Windows)**
2. Run SimPaths model for each scenario and process output data **(computationally intensive)**
3. Analyse and visualise outputs

Each step can be run in a different environment, as long as outputs from the previous step are copied into the right directory in the new environment (see detailed information below). Originally, stages 1 and 3 were run on a Windows laptop, while stage 2 was run on an HPC cluster.

## Stage 1: Create policy scenarios using EUROMOD

Requires:

- Python
- Input data:
  - `data/euromod_input/UK_2020_b1.txt`: Input microdata for the UKMOD model. Must be requested from the UKMOD team at: <https://www.microsimulation.ac.uk/ukmod/access/frs/>
  - `data/euromod_input/UKMOD-PUBLIC-B2025.08`: The UKMOD model, version B2025.08. Can be downloaded [here](https://www.microsimulation.ac.uk/ukmod/access/) ([direct link](https://www.microsimulation.ac.uk/wp-content/uploads/2025/11/UKMOD-PUBLIC-B2025.08.zip)). Extract the zip file in the `data/euromod_input` folder.

How to run:

1. Create and activate a Python virtual environment:

    python -m venv euromod_env
    euromod_env/Scripts/activate

2. Install Python dependencies:

    pip install -r requirements.txt

3. Run the script:

    python scripts/01_create_euromod_output.py

## Stage 2: Run SimPaths

## Stage 3: Analyse outputs

## MARS-specific instructions

Download and install Apache Maven:

    wget https://dlcdn.apache.org/maven/maven-3/3.9.14/binaries/apache-maven-3.9.14-bin.tar.gz
