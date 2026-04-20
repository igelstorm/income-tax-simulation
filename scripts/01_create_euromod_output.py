from euromod import Model
from datetime import datetime
from pathlib import Path
import os
import pandas as pd

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
dk_x = 3.274 # Factor to increase UC by

scenarios = [
    "baseline",
    "dk",
    "mis",
    "flat",
]
# Year 2015 is required, since 2015 is the "base price year" in SimPaths
years = [2015] + list(range(2024, 2030))
intervention_year = 2026

policy_constants={
    "baseline": {},
    "dk": {
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
        ("$ITRate6S", ""):           "0.565",                        # Top rate (Scotland),
        # Increase UC to compensate
        ("$UCNddHCCont", ""):        f"{dk_x*91.47:.2f}#m",      # Universal Credit: Non-dependents' housing cost contribution
        ("$UCIncdisKidsDis1", ""):   f"{dk_x*673:.2f}#m",        # Universal Credit: higher work allowance: responsible for one or more children or qualifying young person or one or both have limited capability for work (2016-)
        ("$UCIncdisKidsDis2", ""):   f"{dk_x*404:.2f}#m",        # Universal Credit: lower work allowance: responsible for one or more children or qualifying young person or one or both have limited capability for work (2016-)
        ("$UCSing1824", ""):         f"{dk_x*311.68:.2f}#m",     # Universal Credit: standard allowances: Single 18-24; in 2020 Covid-19 shocks: benefit amount is re-defined in policy covshocks_uk
        ("$UCSing25", ""):           f"{dk_x*393.45:.2f}#m",     # Universal Credit: standard allowances: Single 25 or over; in 2020 Covid-19 shocks: benefit amount is re-defined in policy covshocks_uk
        ("$UCCoup1617", ""):         f"{dk_x*489.23:.2f}#m",     # Universal Credit: standard allowances: Couple both under 25; in 2020 Covid-19 shocks: benefit amount is re-defined in policy covshocks_uk
        ("$UCCoup18", ""):           f"{dk_x*489.23:.2f}#m",     # Universal Credit: standard allowances: Couple both over 18 (18-24); in 2020 Covid-19 shocks: benefit amount is re-defined in policy covshocks_uk
        ("$UCCoup25", ""):           f"{dk_x*617.6:.2f}#m",      # Universal Credit: standard allowances: Couple one or both 25 or over; in 2020 Covid-19 shocks: benefit amount is re-defined in policy covshocks_uk
        ("$UCfam", ""):              f"{dk_x*333.33:.2f}#m",     # Universal Credit: Family element (to be paid with the first child - assumed born prior to 6 April 2017)
        ("$UCchild", ""):            f"{dk_x*287.92:.2f}#m",     # Universal Credit: Child Element (assumed to born after 6 April 2017)
        ("$UCDisChild", ""):         f"{dk_x*156.11:.2f}#m",     # Universal Credit: additional amount for a disabled child: lower rate
        ("$UCSevDisChild", ""):      f"{dk_x*487.58:.2f}#m",     # Universal Credit: additional amount for a disabled child: higher rate
        ("$UCLCW", ""):              f"{dk_x*156.11:.2f}#m",     # Universal Credit: limited capacity for work (ex WRAG)
        ("$UCLCWRAG", ""):           f"{dk_x*416.19:.2f}#m",     # Universal Credit: limited capability for work and work-related activity (ex SG)
        ("$UCcarer", ""):            f"{dk_x*198.31:.2f}#m",     # Universal Credit: carer element
        ("$UCCC1ChMax", ""):         f"{dk_x*1014.63:.2f}#m",    # Universal Credit: childcare costs element: maximum amount for one child
        ("$UCCC2ChMax", ""):         f"{dk_x*1739.37:.2f}#m",    # Universal Credit: childcare costs element: maximum amount for two or more children
        # Increase benefit cap
        ("$BcapHBSing", ""):         f"{dk_x*14755:.2f}#y",  # Benefit cap: for single
        ("$BcapHBCoup", ""):         f"{dk_x*22020:.2f}#y",  # Benefit cap: for couples
        ("$BcapHBLP", ""):           f"{dk_x*22020:.2f}#y",  # Benefit cap: for lone parents
        ("$BcapHBLon", ""):          f"{dk_x*25325:.2f}#y",  # Benefit cap: couples in London
        ("$BcapHBLonLP", ""):        f"{dk_x*25325:.2f}#y",  # Benefit cap: lone parents in London
        ("$BcapHBLonSing", ""):      f"{dk_x*16965:.2f}#y",  # Benefit cap: single in London
        ("$BcapMinEarn", ""):        f"{dk_x*722:.2f}#m",    # Benefit cap: Minimum earning per benefit unit to avoid benefit cap
        ("$BcapUCwkids", ""):        f"{dk_x*22020:.2f}#y",  # Benefit cap: Joint claimants and single claimants with children
        ("$BcapUCnokid", ""):        f"{dk_x*14755:.2f}#y",  # Benefit cap: single claimants without children
        ("$BcapUCLon", ""):          f"{dk_x*25325:.2f}#y",  # Benefit cap: in London: couple and lone parents
        ("$BcapUCLonsing", ""):      f"{dk_x*16965:.2f}#y"   # Benefit cap: in London: single
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
        uk_model.countries["UK"].systems[f"UK_{year}"].run(
            data,
            data_filename,
            constantsToOverwrite=constants,
            outputpath=output_path
       )
