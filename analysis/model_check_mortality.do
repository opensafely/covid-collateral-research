/* ===========================================================================
Do file name:   model_check_mortality.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run model checks before time-series
==============================================================================*/

*Log file
cap log using ./logs/model_checks_mortality.log, replace
cap mkdir ./output/time_series

* Mortality outcomes - DM outcomes not currently included
* cvd, resp, mh, mi, stroke, heart failure, vte, asthma, copd
foreach c in cvd resp mh mi stroke heart_failure vte asthma copd all_cause {
	import delimited "./output/measures/mortality/measure_`c'_mortality_ethnic_rate.csv", numericcols(4) clear	//get csv
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
	tsset ethnicity month 
	*Kernel density plots to check for normality and extreme values
	kdensity rate if ethnicity==1, normal name(kd_ethnicity_1_`c')
	kdensity rate if ethnicity==2, normal name(kd_ethnicity_2_`c')
    kdensity rate if ethnicity==3, normal name(kd_ethnicity_3_`c')
    kdensity rate if ethnicity==4, normal name(kd_ethnicity_4_`c')
    kdensity rate if ethnicity==5, normal name(kd_ethnicity_5_`c')
	*Autoregression plots by ethnicity
    ac rate if ethnicity==1, name(ac_ethnicity_1_`c')
	ac rate if ethnicity==2, name(ac_ethnicity_2_`c')
    ac rate if ethnicity==3, name(ac_ethnicity_3_`c')
    ac rate if ethnicity==4, name(ac_ethnicity_4_`c')
    ac rate if ethnicity==5, name(ac_ethnicity_5_`c')
	*Partial autoregression plots by ethnicity
	pac rate if ethnicity==1, name(pac_ethnicity_1_`c')
	pac rate if ethnicity==2, name(pac_ethnicity_2_`c')
    pac rate if ethnicity==3, name(pac_ethnicity_3_`c')
    pac rate if ethnicity==4, name(pac_ethnicity_4_`c')
    pac rate if ethnicity==5, name(pac_ethnicity_5_`c')
	*Combine Graphs
	graph combine kd_ethnicity_1_`c' kd_ethnicity_2_`c' kd_ethnicity_3_`c' kd_ethnicity_4_`c' kd_ethnicity_5_`c', altshrink
	graph export ./output/time_series/mortality_kd_`c'_ethnicity.svg, as(svg) replace
	graph combine ac_ethnicity_1_`c' ac_ethnicity_2_`c' ac_ethnicity_3_`c' ac_ethnicity_4_`c' ac_ethnicity_5_`c', altshrink
	graph export ./output/time_series/mortality_ac_`c'_ethnicity.svg, as(svg) replace
    graph combine pac_ethnicity_1_`c' pac_ethnicity_2_`c' pac_ethnicity_3_`c' pac_ethnicity_4_`c' pac_ethnicity_5_`c', altshrink
	graph export ./output/time_series/mortality_pac_`c'_ethnicity.svg, as(svg) replace
	}

* IMD
foreach c in cvd resp mh mi stroke heart_failure vte asthma copd all_cause {
	import delimited "./output/measures/mortality/measure_`c'_mortality_imd_rate.csv", numericcols(4) clear	//get csv
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
	kdensity rate if imd==1, normal name(kd_imd_1_`c')
	kdensity rate if imd==2, normal name(kd_imd_2_`c')
    kdensity rate if imd==3, normal name(kd_imd_3_`c')
    kdensity rate if imd==4, normal name(kd_imd_4_`c')
    kdensity rate if imd==5, normal name(kd_imd_5_`c')
	*Autoregression plots by imd
    ac rate if imd==1, name(ac_imd_1_`c')
	ac rate if imd==2, name(ac_imd_2_`c')
    ac rate if imd==3, name(ac_imd_3_`c')
    ac rate if imd==4, name(ac_imd_4_`c')
    ac rate if imd==5, name(ac_imd_5_`c')
	*Partial autoregression plots by imd
	pac rate if imd==1, name(pac_imd_1_`c')
	pac rate if imd==2, name(pac_imd_2_`c')
    pac rate if imd==3, name(pac_imd_3_`c')
    pac rate if imd==4, name(pac_imd_4_`c')
    pac rate if imd==5, name(pac_imd_5_`c')
	*Combine Graphs
	graph combine kd_imd_1_`c' kd_imd_2_`c' kd_imd_3_`c' kd_imd_4_`c' kd_imd_5_`c', altshrink
	graph export ./output/time_series/mortality_kd_`c'_imd.svg, as(svg) replace
	graph combine ac_imd_1_`c' ac_imd_2_`c' ac_imd_3_`c' ac_imd_4_`c' ac_imd_5_`c', altshrink
	graph export ./output/time_series/mortality_ac_`c'_imd.svg, as(svg) replace
    graph combine pac_imd_1_`c' pac_imd_2_`c' pac_imd_3_`c' pac_imd_4_`c' pac_imd_5_`c', altshrink
	graph export ./output/time_series/mortality_pac_`c'_imd.svg, as(svg) replace
	}


log close