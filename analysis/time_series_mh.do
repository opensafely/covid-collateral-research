/* ===========================================================================
Do file name:   time_series_mh.do
Project:        COVID Collateral
Date:     		29/04/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run time series after model checks
==============================================================================*/

*Log file
cap log using ./logs/tsreg_mh.log, replace
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
		import delimited "./output/measures/mh/measure_`c'_`d'_rate.csv", numericcols(4) clear	//get csv
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
        import excel using ./output/time_series/tsreg_tables_mh.xlsx, sheet (`c'_`d') clear
        export delimited using ./output/time_series/tsreg_mh_`c'_`d'.csv
        }
    }

local a "depression_primary_admission anxiety_primary_admission smi_primary_admission self_harm_primary_admission anxiety_emergency smi_emergency self_harm_emergency"
local b "depress_pri anxiety_pri smi_pri sh_pri anx_emergency smi_emergency sh_emergency"
forvalues i=1/7 {
	local c: word `i' of `a'
    local d: word `i' of `b' 
	local e "ethnicity imd"
	forvalues i=1/2 {
    	local f: word `i' of `e'
        import delimited "./output/measures/mh/measure_`c'_`f'_rate.csv", numericcols(3) clear	//get csv
        putexcel set ./output/time_series/tsreg_tables_mh, sheet(`d'_`f') modify			//open xlsx
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
        tsset `f' month
        newey rate i.`f'##i.postcovid i.season, lag(1) force
        *Export results
        putexcel E1=("Number of obs") G1=(e(N))
        putexcel E2=("F") G2=(e(F))
        putexcel E3=("Prob > F") G3=(Ftail(e(df_m), e(df_r), e(F)))
        matrix a = r(table)'
        putexcel A6 = matrix(a), rownames
        putexcel save
        import excel using ./output/time_series/tsreg_tables_mh.xlsx, sheet (`d'_`f') clear
        export delimited using ./output/time_series/tsreg_mh_`d'_`f'.csv, replace
        }
    }

