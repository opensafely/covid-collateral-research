/* ===========================================================================
Do file name:   time_series.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run time series after model checks
==============================================================================*/

*Log file
cap log using ./logs/tsreg.log, replace
cap mkdir ./output/time_series

foreach x in asthma copd {
	import delimited ./output/measures/resp/measure_`x'_exacerbation_ethnicity_rate.csv, numericcols(4) clear	//get csv
	putexcel set ./output/time_series/tsreg_tables, sheet(`x'_ethnicity) modify			//open xlsx
	*Format time
	gen temp_date=date(date, "YMD")
	format temp_date %td
	gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
	gen month=mofd(temp_date)
	format month %tm
	drop temp_date
	*Value to rate per 100k
	gen rate = value*100000
	*Run time series with EWH-robust SE and 1 Lag
	tsset ethnicity month
	newey rate i.ethnicity##i.postcovid, lag(1) force
	*Export results
	putexcel E1=("Number of obs") G1=(e(N))
	putexcel E2=("F") G2=(e(F))
	putexcel E3=("Prob > F") G3=(Ftail(e(df_m), e(df_r), e(F)))
	matrix a = r(table)'
	putexcel A6 = matrix(a), rownames
	putexcel save

}


log close