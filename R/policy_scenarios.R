gbp_per_dkk <- 0.113
mis_constants <- list(
  ITPerAll = "29500#y",
  ITRate2 = "0.81",
  ITRate3 = "0.81",
  ITRate4S = "0.81",
  ITRate5S = "0.81",
  ITRate6S = "0.81"
)
mis2_constants <- list(
  ITPerAll = "29500#y",
  ITRate1         = "0.45",      # First tax rate
  ITRate2         = "0.5",      # Second tax rate
  ITRate3         = "0.5",     # Third tax rate
  ITRate1S        = "0.45-0.01",     # 2018/19 to current: Starter rate: 2017/18: Basic rate (Scotland)
  ITRate2S        = "0.45",      # 2018/19 to current: Basic rate; 2017/18: Higher rate (Scotland)
  ITRate3S        = "0.45+0.01",     # 2018/19 to current: Intermediate rate; 2017/18: Additional rate (Scotland)
  ITRate4S        = "0.5",     # Higher rate (Scotland)
  ITRate5S        = "0.5",     # Advanced rate (Scotland)
  ITRate6S        = "0.5"     # Top rate (Scotland)
)
flat_constants <- list(
  ITPerAll = "0#y",
  ITRate1 = "0.187",
  ITRate2 = "0.187",
  ITRate3 = "0.187",
  ITRate1S = "0.187",
  ITRate2S = "0.187",
  ITRate3S = "0.187",
  ITRate4S = "0.187",
  ITRate5S = "0.187",
  ITRate6S = "0.187"
)
# https://boundlesshq.com/guides/denmark/taxes/
# DKK 0 - 46,700        8%
# DKK 46,701 - 544,800  40%
# Over DKK 544,800      56.5%
dk_constants <- list(
  ITPerAll        = "0#y",                              # Personal Allowance
  ITThresh1       = paste0(46700*gbp_per_dkk, "#y"),    # Higher Rate Threshold (HRT)
  ITThresh2       = paste0(544800*gbp_per_dkk, "#y"),   # Additional Rate Threshold (ART)
  ITRate1         = "0.08",                             # First tax rate
  ITRate2         = "0.4",                              # Second tax rate
  ITRate3         = "0.565",                            # Third tax rate
  ITThresh1S      = "0#y",   # 2018/19 to current: Starter rate limit; 2016/17 to 2017/18: Intermediate rate
  ITThresh2S      = "0#y",  # 2018/19 to current: Basic rate limit; 2016/17 to 2017/18: Higher rate limit
  ITThresh3S      = paste0(46700*gbp_per_dkk, "#y"),     # Intermediate rate limit
  ITThresh4S      = paste0(544800*gbp_per_dkk, "#y"),    # Higher rate limit
  ITThresh5S      = paste0(544801*gbp_per_dkk, "#y"),    # Advanced
  ITRate1S        = "0.08",     # 2018/19 to current: Starter rate: 2017/18: Basic rate (Scotland)
  ITRate2S        = "0.08",      # 2018/19 to current: Basic rate; 2017/18: Higher rate (Scotland)
  ITRate3S        = "0.08",     # 2018/19 to current: Intermediate rate; 2017/18: Additional rate (Scotland)
  ITRate4S        = "0.40",     # Higher rate (Scotland)
  ITRate5S        = "0.565",     # Advanced rate (Scotland)
  ITRate6S        = "0.565"      # Top rate (Scotland)
)

default_constants_2024 <- list(
  ITPerAll        = "12570#y",  # Personal Allowance
  ITPerAll75      = NA,         # Personal Age Allowance (75+)
  ITPerSa         = "1000#y",   # Personal Savings Allowance for basic-rate taxpayers
  ITPerSaHRP      = "500#y",    # Personal Savings Allowance for higher-rate taxpayers
  ITPerAllMCT     = "1260#y",   # Transferable marriage allownace for married couples
  ITyprAll        = "1000#y",   # Property income allowance
  ITHigAgeLim     = "75",       # Age threshold for higher age allowance
  ITAllLim        = "100000#y", # Income limit for personal allowances
  ITMca75         = "11080#y",  # Married Couples Allowance - 75 years old or over (maximum amount)
  ITMcaMin        = "4280#y",   # Minimum Married Couples Allowance
  ITCBthresh      = "60000#y",  # Taxation of CB: income threshold
  ITCBwr          = "0.005",    # Taxation of CB: withdrawal rate
  ITRentincdis    = "7500#y",   # Rent threshold for rent-a-room scheme (disregarded from rent income)
  ITThreshDivAll  = "500#y",    # dividend allowance
  ITThresh1Sav    = "37700#y",  # Higher Rate Threshold (HRT) - savings taxation
  ITThresh2Sav    = "125140#y", # Additional Rate Threshold (ART) - savings taxation
  ITThreshStrSav  = "5000#y",   # Starting rate limit for savings income
  ITThreshStrSavS = "5000#y",   # Starting rate band for savings upper threshold
  ITThreshStrSavW = "5000#y",   # Starting rate band for savings upper threshold
  ITSRate1        = "0.2",      # basic tax rate for savings income
  ITSRate2        = "0.4",      # higher tax rate for savings income
  ITSRate3        = "0.45",     # additional tax rate for savings income
  ITDRate1        = "0.0875",   # basic rate tax for dividend income
  ITDRate2        = "0.3375",   # higher rate tax for dividend income
  ITDRate3        = "0.3935",   # additional rate tax for dividend income
  ITThresh1       = "37700#y",  # Higher Rate Threshold (HRT)
  ITThresh2       = "125140#y", # Additional Rate Threshold (ART)
  ITRate1         = "0.2",      # First tax rate
  ITRate2         = "0.4",      # Second tax rate
  ITRate3         = "0.45",     # Third tax rate
  ITThresh1S      = "2306#y",   # 2018/19 to current: Starter rate limit; 2016/17 to 2017/18: Intermediate rate
  ITThresh2S      = "13991#y",  # 2018/19 to current: Basic rate limit; 2016/17 to 2017/18: Higher rate limit
  ITThresh3S      = "31092#y",  # Intermediate rate limit
  ITThresh4S      = "62430#y",  # Higher rate limit
  ITThresh5S      = "125140#y", # Advanced
  ITRateDiscountS = NA,         # English income tax discount rate for Scotland
  ITRate1S        = "0.19",     # 2018/19 to current: Starter rate: 2017/18: Basic rate (Scotland)
  ITRate2S        = "0.2",      # 2018/19 to current: Basic rate; 2017/18: Higher rate (Scotland)
  ITRate3S        = "0.21",     # 2018/19 to current: Intermediate rate; 2017/18: Additional rate (Scotland)
  ITRate4S        = "0.42",     # Higher rate (Scotland)
  ITRate5S        = "0.45",     # Advanced rate (Scotland)
  ITRate6S        = "0.48",     # Top rate (Scotland)
  ITThresh1W      = "37700#y",  # Higher Rate Threshold (HRT) - Wales
  ITThresh2W      = "125140#y", # Additional Rate Threshold (ART) - Wales
  ITRateDiscountW = "0.1",      # English income tax discount rate for Wales
  ITRate1W        = "0.1",      # First rate (Wales)
  ITRate2W        = "0.1",      # Second rate (Wales)
  ITRate3W        = "0.1"       # Third rate (Wales)
)
