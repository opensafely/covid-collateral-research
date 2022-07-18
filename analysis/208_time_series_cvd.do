/* ===========================================================================
Do file name:   time_series_cvd.do
Project:        COVID Collateral
Date:     		29/04/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run time series after model checks
==============================================================================*/

*Log file
cap log using ./logs/tsreg_cvd.log, replace
cap mkdir ./output/time_series
* Time series analysis CVD outcomes
* Clinical monitoring: BP measurement
* Hospital admissions: any code and primary code for MI, stroke, heart failure and vte
local a "bp_meas_cvd mi_admission stroke_admission heart_failure_admission vte_admission mi_primary_admission stroke_primary_admission heart_failure_primary_admission vte_primary_admission"
local z "bp_cvd mi_admit stroke_admit hf_admit vte_admit mi_pri stroke_pri hf_pri vte_pri"
forvalues i=1/9 {
    local c: word `i' of `a' 
    local e: word `i' of `z'
	local b "ethnicity imd"
	forvalues i=1/2 {
    	local d: word `i' of `b'
		import delimited "./output/measures/cvd/measure_`c'_`d'_rate.csv", numericcols(4) clear	//get csv
        putexcel set ./output/time_series/tsreg_tables_cvd, sheet(`e'_`d') modify			//open xlsx
        * Drop records where ethnicity is missing - no missing IMD
        drop if `d'==0
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
        tsset `d' month
        newey rate i.`d'##i.postcovid i.season, lag(1) force
        *Export results
        putexcel E1=("Number of obs") G1=(e(N))
        putexcel E2=("F") G2=(e(F))
        putexcel E3=("Prob > F") G3=(Ftail(e(df_m), e(df_r), e(F)))
        matrix a = r(table)'
        putexcel A6 = matrix(a), rownames
        putexcel save
        quietly margins `d'##postcovid
        marginsplot
        graph export ./output/time_series/margins_cvd_`e'_`d'.svg, as(svg) replace
        import excel using ./output/time_series/tsreg_tables_cvd.xlsx, sheet (`e'_`d') clear
        export delimited using ./output/time_series/tsreg_cvd_`e'_`d'.csv, replace
        }
    }