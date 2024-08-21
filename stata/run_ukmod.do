// Requires EUROMOD Stata Connector v0.1.0, available from:
// https://euromod-web.jrc.ec.europa.eu/download-euromod

global model_path "C:\Users\erik\Documents\GitHub\income-tax-simulation\UKMOD-PUBLIC-B2024.14"

program drop fiscal_balance
program fiscal_balance
	syntax varlist
// 	local x = `1'
// 	tempname balance
// 	scalar `balance' = `x'
// 	return scalar result = `x'
end

fiscal_balance 

local min_val = 0.1
local max_val = 0.5
local step = 0.1

local best_input = .
local best_output = .

forval i = `min_val'/`step' to `max_val' {
	local input = `i'
	fiscal_balance `input'
	local output = r(balance)
	if missing(`best_output') | `output' > `best_output' {
        local best_input = `input'
        local best_output = `output'
    }
}

cd "C:\Users\erik\Documents\GitHub\income-tax-simulation\stata"

import delimited ../UKMOD-PUBLIC-B2024.14/Input/UK_2019_a2.txt, clear


// euromod_run changes the working directory, so we need to save it and manually
// reset it afterwards
local workingdir = c(pwd)
euromod_run, model($model_path) system(UK_2024_MIS) dataset(UK_2019_a2.txt) country(UK) constants("MISTaxIncr = '0.05'")
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

display r(sum)
local lol = r(sum)
display %20.2fc `lol'
