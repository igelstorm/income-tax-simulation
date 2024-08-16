// Requires EUROMOD Stata Connector v0.1.0, available from:
// https://euromod-web.jrc.ec.europa.eu/download-euromod

global model_path "C:\Users\erik\Documents\GitHub\income-tax-simulation\UKMOD-PUBLIC-B2024.14"

import delimited UKMOD-PUBLIC-B2024.14/Input/UK_2019_a2.txt

euromod_run, model($model_path) system(UK_2024_MIS) dataset(UK_2019_a2.txt) country(UK)

return list
browse
