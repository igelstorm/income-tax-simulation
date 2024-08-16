// Requires EUROMOD Stata Connector v0.1.0, available from:
// https://euromod-web.jrc.ec.europa.eu/download-euromod

global model_path "C:\Users\erik\Documents\GitHub\income-tax-simulation\UKMOD-PUBLIC-B2024.14"

import delimited ../UKMOD-PUBLIC-B2024.14/Input/UK_2019_a2.txt

// euromod_run changes the working directory, so we need to save it and manually
// reset it afterwards
local workingdir = c(pwd)
euromod_run, model($model_path) system(UK_2024) dataset(UK_2019_a2.txt) country(UK) constants("ITPerAll = '20000'")
cd "`workingdir'"

// The figures below should match the corresponding rows in the Statistics
// Presenter. There seem to be small discrepancies, but these could be due to
// rounding errors or similar.

// Government revenue through direct taxes and national insurance contributions
gen gov_revenue = ils_tax + ils_sicee + ils_sicse + ils_sicot + ils_sicer
gen gov_revenue_wt = dwt * gov_revenue
summ(gov_revenue_wt)
display %20.2fc r(sum)*12

// Government expenditure on benefits and tax credits
gen gov_expend = ils_ben
gen gov_expend_wt = dwt * gov_expend
summ(gov_expend_wt)
display %20.2fc r(sum)*12
