from euromod import Model
from datetime import datetime
import os
import matplotlib.pyplot as plt
import pandas as pd

script_path = os.path.dirname(os.path.realpath(__file__))

data_directory="C:/Users/eii2t/OneDrive - University of Glasgow/Data/UKMOD/UKMOD A2.50+ Data"
data_filename="UK_2022_a1"

uk_model_path="C:/Users/eii2t/EUROMOD/UKMOD-PUBLIC-B2025.07-2022"
data_path=f"{data_directory}/{data_filename}.txt"

output_path=f"{script_path}/../../output/triangulation"
if not os.path.exists(output_path):
    os.makedirs(output_path)

data=pd.read_csv(data_path, sep="\t")
uk_model=Model(uk_model_path)

year = 2026
x_values = [0.193, 0.194]

# Calculate baseline (bl) revenue and expenditure
output = uk_model.countries["UK"].systems[f"UK_{year}"].run(data, data_filename)
df = output.outputs[0]
bl_revenue = (df["dwt"] * (df["ils_tax"] + df["ils_sicee"] + df["ils_sicse"] + df["ils_sicot"] + df["ils_sicer"])).sum()
bl_expenditure = (df["dwt"] * df["ils_ben"]).sum()
bl_balance = bl_revenue - bl_expenditure

results = []

for x in x_values:
    policy_constants = {
        ("$ITPerAll",""):    "0#y",
        ("$ITRate1",""):     f"{x}",
        ("$ITRate2",""):     f"{x}",
        ("$ITRate3",""):     f"{x}",
        ("$ITRate1S",""):    f"{x}",
        ("$ITRate2S",""):    f"{x}",
        ("$ITRate3S",""):    f"{x}",
        ("$ITRate4S",""):    f"{x}",
        ("$ITRate5S",""):    f"{x}",
        ("$ITRate6S",""):    f"{x}"
    }

    output = uk_model.countries["UK"].systems[f"UK_{year}"].run(
        data,
        data_filename,
        constantsToOverwrite=policy_constants
    )
    df = output.outputs[0]
    revenue = (df["dwt"] * (df["ils_tax"] + df["ils_sicee"] + df["ils_sicse"] + df["ils_sicot"] + df["ils_sicer"])).sum()
    expenditure = (df["dwt"] * df["ils_ben"]).sum()
    balance = revenue - expenditure
    results.append({
        "x_value": x,
        "revenue": revenue,
        "expenditure": expenditure,
        "balance": balance,
        "revenue_vs_bl": revenue - bl_revenue,
        "expenditure_vs_bl": expenditure - bl_expenditure,
        "balance_vs_bl": balance - bl_balance,
    })

df = pd.DataFrame(results)

plt.figure(figsize=(8, 5))
plt.plot(df['x_value'], df['balance_vs_bl'], marker='o', linestyle='-')
plt.axhline(y=0, color='black', linestyle='--')
plt.xlabel('x_value')
plt.ylabel('Balance compared to baseline')
plt.grid(True)
plt.tight_layout()
plt.savefig(f"{output_path}/flat.png")
