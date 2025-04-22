from euromod import Model
from datetime import datetime
import os
import pandas as pd

script_path = os.path.dirname(os.path.realpath(__file__))

data_directory=f"{script_path}/../input"
data_filename="UK_2022_a1"

uk_model_path=f"{script_path}/../UKMOD-PUBLIC-B2024.14"
eu_model_path=f"{script_path}/../EUROMOD_RELEASES_J0.1+"
data_path=f"{data_directory}/{data_filename}.txt"

output_path=f"{script_path}/../intermediate/euromod/dk"
if not os.path.exists(output_path):
    os.makedirs(output_path)

data=pd.read_csv(data_path, sep="\t")
uk_model=Model(uk_model_path)
eu_model=Model(eu_model_path)

mis_constants={
    ("$ITPerAll",""): "29500#y",
    ("$ITRate2",""):  "0.81",
    ("$ITRate3",""):  "0.81",
    # ("$ITRate4S",""): "0.81",
    # ("$ITRate5S",""): "0.81",
    # ("$ITRate6S",""): "0.81"
}

for year in range(2024, 2026):
    print(f"{datetime.now()}: Running year {year}")
    uk_model.countries["UK"].systems[f"UK_{year}"].run(data, data_filename, constantsToOverwrite=mis_constants, outputpath=output_path)

# TODO: convert currency in input data
# gbp_per_dkk <- 0.113

for year in range(2024, 2026):
    print(f"{datetime.now()}: Running year {year}")
    eu_model.countries["DK"].systems[f"DK_{year}"].run(data, data_filename, constantsToOverwrite=mis_constants, outputpath=output_path)
