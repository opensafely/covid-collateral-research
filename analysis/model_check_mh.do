/* ===========================================================================
Do file name:   model_check_mh.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run model checks before time-series
==============================================================================*/

*Log file
cap log using ./logs/model_checks_mh.log, replace
cap mkdir ./output/time_series

* Mental health outcomes
* Clinical monitoring: BP measurement
* Hospital admissions: any code and primary code for depression, anxiety, smi, self harm, eating disorders, OCD
* Likely to need to update file paths as ethnicity 3-monthly
local a "systolic_bp_mh depression_admission anxiety_admission smi_admission self_harm_admission eating_dis_admission ocd_admission" 
local z "bp_mh depress_admit anx_admit smi_admit sh_admit eat_dis_admit ocd_admit"
forvalues i=1/7 {
    local c: word `i' of `a' 
	local e: word `i' of `z'
	local b "ethnicity imd"
	forvalues i=1/2 {
    	local d: word `i' of `b'
		import delimited "./output/measures/measure_`c'_`d'_rate.csv", numericcols(4) clear	//get csv
		gen temp_date=date(date, "YMD")
		format temp_date %td
		gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
		gen month=mofd(temp_date)
		format month %tm
		drop temp_date
		*Value to rate per 100k
		gen rate = value*100000
		label variable rate "Rate of `c' per 100,000"
		*Set time series
		tsset `d' month 
		*Kernel density plots to check for normality and extreme values
		kdensity rate if `d'==1, normal name(kd_`d'_1_`e')
		kdensity rate if `d'==2, normal name(kd_`d'_2_`e')
		kdensity rate if `d'==3, normal name(kd_`d'_3_`e')
		kdensity rate if `d'==4, normal name(kd_`d'_4_`e')
		kdensity rate if `d'==5, normal name(kd_`d'_5_`e')
		*Autoregression plots by ethnicity
		ac rate if `d'==1, name(ac_`d'_1_`e')
		ac rate if `d'==2, name(ac_`d'_2_`e')
		ac rate if `d'==3, name(ac_`d'_3_`e')
		ac rate if `d'==4, name(ac_`d'_4_`e')
		ac rate if `d'==5, name(ac_`d'_5_`e')
		*Partial autoregression plots by ethnicity
		pac rate if `d'==1, name(pac_`d'_1_`e')
		pac rate if `d'==2, name(pac_`d'_2_`e')
		pac rate if `d'==3, name(pac_`d'_3_`e')
		pac rate if `d'==4, name(pac_`d'_4_`e')
		pac rate if `d'==5, name(pac_`d'_5_`e')
		*Combine Graphs
		graph combine kd_`d'_1_`e' kd_`d'_2_`e' kd_`d'_3_`e' kd_`d'_4_`e' kd_`d'_5_`e', altshrink
		graph export ./output/time_series/mh_kd_`c'_`d'.svg, as(svg) replace
		graph combine ac_`d'_1_`e' ac_`d'_2_`e' ac_`d'_3_`e' ac_`d'_4_`e' ac_`d'_5_`e', altshrink
		graph export ./output/time_series/mh_ac_`c'_`d'.svg, as(svg) replace
		graph combine pac_`d'_1_`e' pac_`d'_2_`e' pac_`d'_3_`e' pac_`d'_4_`e' pac_`d'_5_`e', altshrink
		graph export .output/graphs/mh_pac_`c'_`d'.svg, as(svg) replace
		}
	}

* Primary and emergency admissions by ethnicity
local a "depression_primary_admission anxiety_primary_admission smi_primary_admission self_harm_primary_admission eating_dis_primary_admission ocd_primary_admission anxiety_emergency smi_emergency self_harm_emergency eating_dis_emergency ocd_emergency"
local b "depress anxiety smi sh eat_dis ocd anx_emergency smi_emergency sh_emergency ed_emergency ocd_emergency"
forvalues i=1/11 {
	local c: word `i' of `a'
	local d: word `i' of `b'
	import delimited "./output/measures/measure_`c'_ethnicity_rate.csv", numericcols(3) clear	//get csv
	gen temp_date=date(date, "YMD")
	format temp_date %td
	gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
	gen month=mofd(temp_date)
	format month %tm
	drop temp_date
	*Value to rate per 100k
	gen rate = value*100000
	label variable rate "Rate of `c' exacerbation per 100,000"
	*Set time series
	tsset ethnicity month
	*Kernel density plots to check for normality and extreme values
	kdensity rate if ethnicity==1, normal name(kd_ethnic_1_`d')
	kdensity rate if ethnicity==2, normal name(kd_ethnic_2_`d')
    kdensity rate if ethnicity==3, normal name(kd_ethnic_3_`d')
    kdensity rate if ethnicity==4, normal name(kd_ethnic_4_`d')
    kdensity rate if ethnicity==5, normal name(kd_ethnic_5_`d')
	*Autoregression plots by ethnicity
    ac rate if ethnicity==1, name(ac_ethnic_1_`d')
	ac rate if ethnicity==2, name(ac_ethnic_2_`d')
    ac rate if ethnicity==3, name(ac_ethnic_3_`d')
    ac rate if ethnicity==4, name(ac_ethnic_4_`d')
    ac rate if ethnicity==5, name(ac_ethnic_5_`d')
	*Partial autoregression plots by ethnicity
	pac rate if ethnicity==1, name(pac_ethnic_1_`d')
	pac rate if ethnicity==2, name(pac_ethnic_2_`d')
    pac rate if ethnicity==3, name(pac_ethnic_3_`d')
    pac rate if ethnicity==4, name(pac_ethnic_4_`d')
    pac rate if ethnicity==5, name(pac_ethnic_5_`d')
	*Combine Graphs
	graph combine kd_ethnic_1_`d' kd_ethnic_2_`d' kd_ethnic_3_`d' kd_ethnic_4_`d' kd_ethnic_5_`d', altshrink
	graph export ./output/time_series/mh_kd_`c'_ethnicity.svg, as(svg) replace
	graph combine ac_ethnic_1_`d' ac_ethnic_2_`d' ac_ethnic_3_`d' ac_ethnic_4_`d' ac_ethnic_5_`d', altshrink
	graph export ./output/time_series/mh_ac_`c'_ethnic.svg, as(svg) replace
    graph combine pac_ethnic_1_`d' pac_ethnic_2_`d' pac_ethnic_3_`d' pac_ethnic_4_`d' pac_ethnic_5_`d', altshrink
	graph export .output/graphs/checks_pac_`c'_ethnicity.svg, as(svg) replace
	}

* Primary and emergency admissions by IMD
local a "depression_primary_admission anxiety_primary_admission smi_primary_admission self_harm_primary_admission eating_dis_primary_admission ocd_primary_admission anxiety_emergency smi_emergency self_harm_emergency eating_dis_emergency ocd_emergency"
local b "depress anxiety smi sh eat_dis ocd anx_emergency smi_emergency sh_emergency ed_emergency ocd_emergency"
forvalues i=1/11 {
	local c: word `i' of `a'
	local d: word `i' of `b'
	import delimited "./output/measures/measure_`c'_imd_rate.csv", numericcols(4) clear	//get csv
	gen temp_date=date(date, "YMD")
	format temp_date %td
	gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
	gen month=mofd(temp_date)
	format month %tm
	drop temp_date
	*Value to rate per 100k
	gen rate = value*100000
	label variable rate "Rate of `c' per 100,000"
	*Set time series
	tsset imd month 
	*Kernel density plots to check for normality and extreme values
	kdensity rate if imd==1, normal name(kd_imd_1_`d')
	kdensity rate if imd==2, normal name(kd_imd_2_`d')
	kdensity rate if imd==3, normal name(kd_imd_3_`d')
	kdensity rate if imd==4, normal name(kd_imd_4_`d')
	kdensity rate if imd==5, normal name(kd_imd_5_`d')
	*Autoregression plots by ethnicity
	ac rate if imd==1, name(ac_imd_1_`d')
	ac rate if imd==2, name(ac_imd_2_`d')
	ac rate if imd==3, name(ac_imd_3_`d')
	ac rate if imd==4, name(ac_imd_4_`d')
	ac rate if imd==5, name(ac_imd_5_`d')
	*Partial autoregression plots by ethnicity
	pac rate if imd==1, name(pac_imd_1_`d')
	pac rate if imd==2, name(pac_imd_2_`d')
	pac rate if imd==3, name(pac_imd_3_`d')
	pac rate if imd==4, name(pac_imd_4_`d')
	pac rate if imd==5, name(pac_imd_5_`d')
	*Combine Graphs
	graph combine kd_imd_1_`d' kd_imd_2_`d' kd_imd_3_`d' kd_imd_4_`d' kd_imd_5_`d', altshrink
	graph export ./output/time_series/mh_kd_`c'_imd.svg, as(svg) replace
	graph combine ac_imd_1_`d' ac_imd_2_`d' ac_imd_3_`d' ac_imd_4_`d' ac_imd_5_`d', altshrink
	graph export ./output/time_series/mh_ac_`c'_imd.svg, as(svg) replace
	graph combine pac_imd_1_`d' pac_imd_2_`d' pac_imd_3_`d' pac_imd_4_`d' pac_imd_5_`d', altshrink
	graph export .output/graphs/mh_pac_`c'_imd.svg, as(svg) replace
	}


log close