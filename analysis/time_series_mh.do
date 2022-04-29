/* ===========================================================================
Do file name:   time_series_mh.do
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
local a "systolic_bp_mh depression_admission anxiety_admission smi_admission self_harm_admission eating_dis_admission ocd_admission" 
forvalues i=1/7 {
    local c: word `i' of `a' 
	local b "ethnicity imd"
	forvalues i=1/2 {
    	local d: word `i' of `b'
		import delimited "./output/measures/measure_`c'_`d'_rate.csv", numericcols(4) clear	//get csv
        putexcel set ./output/time_series/tsreg_tables_mh, sheet(`c'_`d') modify			//open xlsx
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
        }
    }

local a "depression_primary_admission anxiety_primary_admission smi_primary_admission self_harm_primary_admission eating_dis_primary_admission ocd_primary_admission anxiety_emergency smi_emergency self_harm_emergency eating_dis_emergency ocd_emergency"
local b "depress anxiety smi sh eat_dis ocd anx_emergency smi_emergency sh_emergency ed_emergency ocd_emergency"
forvalues i=1/11 {
	local c: word `i' of `a'
	local d: word `i' of `b'
	import delimited "./output/measures/collapse_measure_`c'_ethnicity_rate.csv", numericcols(3) clear	//get csv
    putexcel set ./output/time_series/tsreg_tables_mh, sheet(`d'_eth) modify			//open xlsx
        *Format time
        gen temp_date=date(date, "DM20Y")
        format temp_date %td
        gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
        gen quarter=qofd(temp_date)
        format quarter %tq
        drop temp_date
        *Value to rate per 100k
        gen rate = value*100000
        *Run time series with EWH-robust SE and 1 Lag
        tsset ethnicity month
        newey rate i.ethnicity##i.postcovid i.season, lag(1) force
        *Export results
        putexcel E1=("Number of obs") G1=(e(N))
        putexcel E2=("F") G2=(e(F))
        putexcel E3=("Prob > F") G3=(Ftail(e(df_m), e(df_r), e(F)))
        matrix a = r(table)'
        putexcel A6 = matrix(a), rownames
        putexcel save
        }
    }

local a "depression_primary_admission anxiety_primary_admission smi_primary_admission self_harm_primary_admission eating_dis_primary_admission ocd_primary_admission anxiety_emergency smi_emergency self_harm_emergency eating_dis_emergency ocd_emergency"
local b "depress anxiety smi sh eat_dis ocd anx_emergency smi_emergency sh_emergency ed_emergency ocd_emergency"
forvalues i=1/11 {
	local c: word `i' of `a'
	local d: word `i' of `b'
	import delimited "./output/measures/measure_`c'_imd_rate.csv", numericcols(3) clear	//get csv
    putexcel set ./output/time_series/tsreg_tables_mh, sheet(`d'_imd) modify			//open xlsx
        *Format time
        gen temp_date=date(date, "DM20Y")
        format temp_date %td
        gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
        gen quarter=qofd(temp_date)
        format quarter %tq
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
        }
    }