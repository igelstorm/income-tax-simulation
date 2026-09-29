import csv
import os
import pandas as pd

from datetime import datetime
from euromod import Model
from pathlib import Path

SCRIPT_PATH = Path(__file__).resolve().parent
ROOT_PATH = SCRIPT_PATH.parent

data_directory = ROOT_PATH / "data" / "euromod_input"
data_filename = "UK_2020_b1"

uk_model_path = ROOT_PATH / "data" / "euromod_input" / "UKMOD-PUBLIC-B2025.08"
data_path = data_directory / f"{data_filename}.txt"

output_root_path = ROOT_PATH / "data" / "euromod_output"

data = pd.read_csv(data_path, sep="\t")
uk_model = Model(str(uk_model_path))

gbp_per_dkk = 0.113

scenarios = [
    "baseline",
    "dk_raw",
    "mis",
    "flat",
]
# Year 2015 is required, since 2015 is the "base price year" in SimPaths
years = [2015] + list(range(2023, 2030))
intervention_year = 2026

policy_constants={
    "baseline": {},
    "dk_raw": {
        # https://boundlesshq.com/guides/denmark/taxes/
        # DKK 0 - 46,700        8%
        # DKK 46,701 - 544,800  40%
        # Over DKK 544,800      56.5%
        ("$ITPerAll", ""):           "0#y",                          # Personal Allowance
        ("$ITThresh1", ""):          f"{46700*gbp_per_dkk:.2f}#y",   # Higher Rate Threshold (HRT)
        ("$ITThresh2", ""):          f"{544800*gbp_per_dkk:.2f}#y",  # Additional Rate Threshold (ART)
        ("$ITRate1", ""):            "0.08",                         # First tax rate
        ("$ITRate2", ""):            "0.4",                          # Second tax rate
        ("$ITRate3", ""):            "0.565",                        # Third tax rate
        ("$ITThresh1S", ""):         "0#y",                          # 2018/19 to current: Starter rate limit; 2016/17 to 2017/18: Intermediate rate
        ("$ITThresh2S", ""):         "0#y",                          # 2018/19 to current: Basic rate limit; 2016/17 to 2017/18: Higher rate limit
        ("$ITThresh3S", ""):         f"{46700*gbp_per_dkk:.2f}#y",   # Intermediate rate limit
        ("$ITThresh4S", ""):         f"{544800*gbp_per_dkk:.2f}#y",  # Higher rate limit
        ("$ITThresh5S", ""):         f"{544801*gbp_per_dkk:.2f}#y",  # Advanced
        ("$ITRate1S", ""):           "0.08",                         # 2018/19 to current: Starter rate: 2017/18: Basic rate (Scotland)
        ("$ITRate2S", ""):           "0.08",                         # 2018/19 to current: Basic rate; 2017/18: Higher rate (Scotland)
        ("$ITRate3S", ""):           "0.08",                         # 2018/19 to current: Intermediate rate; 2017/18: Additional rate (Scotland)
        ("$ITRate4S", ""):           "0.40",                         # Higher rate (Scotland)
        ("$ITRate5S", ""):           "0.565",                        # Advanced rate (Scotland)
        ("$ITRate6S", ""):           "0.565"                         # Top rate (Scotland)
    },
    "mis": {
        ("$ITPerAll",""):   "29500#y",
        ("$ITRate2",""):    "0.783",
        ("$ITRate3",""):    "0.783",
        ("$ITRate4S",""):   "0.783",
        ("$ITRate5S",""):   "0.783",
        ("$ITRate6S",""):   "0.783"
    },
    "flat": {
        ("$ITPerAll",""):    "0#y",
        ("$ITRate1",""):     "0.194",
        ("$ITRate2",""):     "0.194",
        ("$ITRate3",""):     "0.194",
        ("$ITRate1S",""):    "0.194",
        ("$ITRate2S",""):    "0.194",
        ("$ITRate3S",""):    "0.194",
        ("$ITRate4S",""):    "0.194",
        ("$ITRate5S",""):    "0.194",
        ("$ITRate6S",""):    "0.194"
    },
}

# Write parameters for all scenarios to a CSV file for reference
variables = sorted({key[0] for sub_dict in policy_constants.values() for key in sub_dict.keys()})
default_policies = uk_model.countries["UK"].systems["UK_2026"].policies
with open(output_root_path / 'scenarios.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['variable'] + list(policy_constants.keys()) + ['default_value', 'comment'])
    for var in variables:
        default_value = default_policies.find("functions.parameters.name", f"^\\{var}$", True)[0].value
        comment = default_policies.find("functions.parameters.name", f"^\\{var}$", True)[0].comment
        row = [var] + [policy_constants[scenario].get((var, ''), '') for scenario in policy_constants] + [default_value, comment]
        writer.writerow(row)

for scenario in scenarios:
    output_path = output_root_path / scenario
    if not os.path.exists(output_path):
        os.makedirs(output_path)

    for year in years:
        output_file_path = output_path / f"uk_{year}_std.txt"
        if os.path.exists(output_file_path):
            print(f"{datetime.now()}: Skipping scenario '{scenario}', year {year}, output path: {output_file_path} (already exists)")
            continue

        print(f"{datetime.now()}: Running scenario '{scenario}', year {year}, output path: {output_path}")
        if year >= intervention_year:
            constants = policy_constants[scenario]
        else:
            constants = policy_constants["baseline"]
        country_name = "UK" if year >= 2016 else "UK15"
        uk_model.countries[country_name].systems[f"UK_{year}"].run(
            data,
            data_filename,
            constantsToOverwrite=constants,
            outputpath=output_path
       )
