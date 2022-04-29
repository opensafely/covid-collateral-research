/* ===========================================================================
Do file name:   time_series_resp.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run time series after model checks
==============================================================================*/

*Log file
cap log using ./logs/tsreg_resp.log, replace
cap mkdir ./output/time_series
* Time series analysis for asthma monitoring, COPD monitoring and exacerbation by ethnicity & IMD
foreach var in asthma_monitoring copd_monitoring copd_exacerbation {
	foreach strata in ethnicity imd {
	import delimited ./output/measures/resp/measure_`var'_`strata'_rate.csv, numericcols(4) clear	//get csv
	putexcel set ./output/time_series/tsreg_tables_resp, sheet(`var'_`strata') modify			//open xlsx
	*Format time
	gen temp_date=date(date, "YMD")
	format temp_date %td
	gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
	gen month=mofd(temp_date)
	format month %tm
	*Define Seasons
	gen season=4
	replace season = 1 if inrange(month(temp_date),3,5)
	replace season = 2 if inrange(month(temp_date),6,8)
	replace season = 3 if inrange(month(temp_date),9,11)
	label define seasonlab 1 "Spring" 2 "Summer" 3 "Autumn" 4 "Winter"
	label values season seasonlab
	drop temp_date
	*Value to rate per 100k
	gen rate = value*100000
	*Run time series with EWH-robust SE and 1 Lag
	tsset `strata' month
	newey rate i.`strata'##i.postcovid i.season, lag(1) force
	*Export results
	putexcel E1=("Number of obs") G1=(e(N))
	putexcel E2=("F") G2=(e(F))
	putexcel E3=("Prob > F") G3=(Ftail(e(df_m), e(df_r), e(F)))
	matrix a = r(table)'
	putexcel A6 = matrix(a), rownames
	putexcel save
	}
}

* Time series analysis for asthma exacerbation by IMD
import delimited ./output/measures/resp/measure_asthma_exacerbation_imd_rate.csv, numericcols(4) clear	//get csv
putexcel set ./output/time_series/tsreg_tables, sheet(asthma_exacerbation_imd) modify			//open xlsx
*Format time
gen temp_date=date(date, "YMD")
format temp_date %td
gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
gen month=mofd(temp_date)
format month %tm
*Define Seasons
gen season=4
replace season = 1 if inrange(month(temp_date),3,5)
replace season = 2 if inrange(month(temp_date),6,8)
replace season = 3 if inrange(month(temp_date),9,11)
label define seasonlab 1 "Spring" 2 "Summer" 3 "Autumn" 4 "Winter"
label values season seasonlab
drop temp_date
*Value to rate per 100k
gen rate = value*100000
*Run time series with EWH-robust SE and 1 Lag
tsset imd month
newey rate i.imd##i.postcovid i.season, lag(1) force
*Export results
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F") G2=(e(F))
putexcel E3=("Prob > F") G3=(Ftail(e(df_m), e(df_r), e(F)))
matrix a = r(table)'
putexcel A6 = matrix(a), rownames
putexcel save


log close