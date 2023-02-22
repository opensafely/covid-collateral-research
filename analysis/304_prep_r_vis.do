/* ===========================================================================
Do file name:   prep_r_vis.do
Project:        COVID Collateral
Date:     		21/09/2022
Author:         Ruth Costello 
Description:    Combines outputs from Cox models ready for R visualisations
==============================================================================*/

*Log file
cap log using ./logs/prep_r_vis.log, replace
cap mkdir ./output/tempdata
cap mkdir ./output/tables
* Reviewer comment: putting files together for each ethnic group reference category 
forvalues j=1/5 {
	import delimited using ./output/tables/anx_`j'_cox_models.txt, stringcols(3) clear
	tempfile tempfile
	* Generate risk differences between waves for each ethnic group
	* count to reorder
	gen number = _n
	preserve
	* calculate by ethnic group, save as temporary file, then merge back on
	* First do white then loop through rest
	keep if ethnic_group=="Other"
	* Create variables with rate/HR to compare to
	foreach var in rate unadj_hr p_adj_hr f_adj_hr {
		gen `var'_pre = `var' if period=="pre"
		replace `var'_pre = `var'_pre[_n-1] if `var'_pre==. & `var'_pre[_n-1]!=.
	}
	* Calculate incidence rate ratio
	gen IRR_vs_pre = rate/rate_pre if period!="pre"
	* Calculate incident rate difference
	gen IRD_vs_pre = rate - rate_pre if period!="pre"
	* Calculate hazard rate ratio for each HR
	gen unadj_HRR_vs_pre = unadj_hr/unadj_hr_pre if period!="pre"
	gen P_HRR_vs_pre = p_adj_hr/p_adj_hr_pre if period!="pre"
	gen F_HRR_vs_pre = f_adj_hr/f_adj_hr_pre if period!="pre"
	keep period ethnic_group IRR_vs_pre-F_HRR_vs_pre number
	save `tempfile', replace
	restore

	* Other ethnic group 
	replace ethnic_group = "Asian" if ethnic_group=="South Asian"
	foreach group in Mixed Black Asian White {
		* Generate risk differences between waves for each ethnic group
		preserve
		keep if ethnic_group=="`group'"
		* calculate by ethnic group, save as temporary file, then merge back on
		* First do white then loop through rest
		foreach var in rate unadj_hr p_adj_hr f_adj_hr {
			gen `var'_pre = `var' if period=="pre"
			replace `var'_pre = `var'_pre[_n-1] if `var'_pre==. & `var'_pre[_n-1]!=.
			}
		* Calculate incidence rate ratio
		gen IRR_vs_pre = rate/rate_pre if period!="pre"
		* Calculate incident rate difference
		gen IRD_vs_pre = rate - rate_pre if period!="pre"
		* Calculate hazard rate ratio for each HR
		gen unadj_HRR_vs_pre = unadj_hr/unadj_hr_pre if period!="pre"
		gen P_HRR_vs_pre = p_adj_hr/p_adj_hr_pre if period!="pre"
		gen F_HRR_vs_pre = f_adj_hr/f_adj_hr_pre if period!="pre"
		keep period ethnic_group IRR_vs_pre-F_HRR_vs_pre number 
		append using `tempfile'
		save `tempfile', replace
		sort number
		restore
		}

	merge 1:1 period ethnic_group using `tempfile'
	gen group="Mental Health"
	gen outcome="Anxiety"
	save ./output/tables/all_cox_data_`j', replace

	* add mi back in when upload
	local a "depress asthma copd dm_keto t1dm t2dm hf mi stroke vte"
	local b "MH Respiratory Respiratory Diabetes Diabetes Diabetes Cardiovascular_hfmi Cardiovascular_hfmi Cardiovascular Cardiovascular" 
	forvalues i=1/9 {
		local outcome: word `i' of `a'
		local category: word `i' of `b'

		import delimited using ./output/tables/`outcome'_`j'_cox_models.txt, stringcols(3) clear
		tempfile tempfile
		* Generate risk differences between waves for each ethnic group
		* count to reorder
		gen number = _n
		preserve
		* calculate by ethnic group, save as temporary file, then merge back on
		* First do white then loop through rest
		keep if ethnic_group=="Other"
		* Create variable with rate to compare to
		foreach var in rate unadj_hr p_adj_hr f_adj_hr {
			gen `var'_pre = `var' if period=="pre"
			replace `var'_pre = `var'_pre[_n-1] if `var'_pre==. & `var'_pre[_n-1]!=.
			}
		* Calculate incidence rate ratio
		gen IRR_vs_pre = rate/rate_pre if period!="pre"
		* Calculate incident rate difference
		gen IRD_vs_pre = rate - rate_pre if period!="pre"
		* Calculate hazard rate ratio for each HR
		gen unadj_HRR_vs_pre = unadj_hr/unadj_hr_pre if period!="pre"
		gen P_HRR_vs_pre = p_adj_hr/p_adj_hr_pre if period!="pre"
		gen F_HRR_vs_pre = f_adj_hr/f_adj_hr_pre if period!="pre"
		keep period ethnic_group IRR_vs_pre-F_HRR_vs_pre number
		gen group = "`category'"
		gen outcome = "`outcome'"
		save `tempfile', replace
		restore

		* Other ethnic group 
		replace ethnic_group = "Asian" if ethnic_group=="South Asian"
		foreach group in Mixed Black Asian White {
			* Generate risk differences between waves for each ethnic group
			preserve
			* calculate by ethnic group, save as temporary file, then merge back on
			* First do white then loop through rest
			keep if ethnic_group=="`group'"
			foreach var in rate unadj_hr p_adj_hr f_adj_hr {
				gen `var'_pre = `var' if period=="pre"
				replace `var'_pre = `var'_pre[_n-1] if `var'_pre==. & `var'_pre[_n-1]!=.
				}
			* Calculate incidence rate ratio
			gen IRR_vs_pre = rate/rate_pre if period!="pre"
			* Calculate incident rate difference
			gen IRD_vs_pre = rate - rate_pre if period!="pre"
			* Calculate hazard rate ratio for each HR
			gen unadj_HRR_vs_pre = unadj_hr/unadj_hr_pre if period!="pre"
			gen P_HRR_vs_pre = p_adj_hr/p_adj_hr_pre if period!="pre"
			gen F_HRR_vs_pre = f_adj_hr/f_adj_hr_pre if period!="pre"
			keep period ethnic_group IRR_vs_pre-F_HRR_vs_pre number
			gen group = "`category'"
			gen outcome = "`outcome'"
			append using `tempfile'
			save `tempfile', replace
			sort number
			restore
			}

		merge 1:1 period ethnic_group using `tempfile'
		append using ./output/tables/all_cox_data_`j'
		save ./output/tables/all_cox_data_`j', replace	
		
	}

	replace denominator="redacted" if denominator=="redact"
	gen ethnic_order = 1 if ethnic_group=="White"
	replace ethnic_order=2 if ethnic_group=="Asian"
	replace ethnic_order=3 if ethnic_group=="Black"
	replace ethnic_order=4 if ethnic_group=="Mixed"
	replace ethnic_order=5 if ethnic_group=="Other"
	gen time_order=1 if period=="pre"
	replace time_order=2 if period=="pandemic"
	replace time_order=3 if period=="wave1"
	replace time_order=4 if period=="easing1"
	replace time_order=5 if period=="wave2"
	replace time_order=6 if period=="easing2"
	replace time_order=7 if period=="wave3"
	replace time_order=8 if period=="easing3"
	* Update period variable
	gen period_n="Pre" if period=="pre"
	replace period_n="Pandemic" if period=="pandemic"
	replace period_n="Wave 1" if period=="wave1"
	replace period_n="Easing 1" if period=="easing1"
	replace period_n="Wave 2" if period=="wave2"
	replace period_n="Easing 2" if period=="easing2"
	replace period_n="Wave 3" if period=="wave3"
	replace period_n="Easing 3" if period=="easing3"
	drop period
	replace group= "Mental Health" if group == "MH"
	gen outcome_n = "Stroke" if outcome=="stroke"
	replace outcome_n = "VTE" if outcome=="vte"
	replace outcome_n = "Heart failure" if outcome=="hf"
	replace outcome_n = "MI" if outcome=="mi"
	replace outcome_n = "DKA" if outcome=="dm_keto"
	replace outcome_n = "T1 DM" if outcome=="t1dm"
	replace outcome_n = "T2 DM" if outcome=="t2dm"
	replace outcome_n = "Anxiety" if outcome=="Anxiety"
	replace outcome_n = "Depression" if outcome=="depress"
	replace outcome_n = "Asthma" if outcome=="asthma"
	replace outcome_n = "COPD" if outcome=="copd"
	drop outcome
	order group outcome_n period_n ethnic_group
	sort group outcome_n time_order ethnic_order
	drop time_order ethnic_order
	rename ethnic_group Ethnicity
	rename period_n Period
	rename group Group
	rename outcome_n Outcome
	rename denominator Denominator
	rename rate Rate
	rename f_adj_lci F_adj_lci
	rename f_adj_uci F_adj_uci
	rename f_adj_hr F_adj_hr
	rename p_adj_lci P_adj_lci
	rename p_adj_uci P_adj_uci
	rename p_adj_hr P_adj_hr
	drop v* number _merge
	* Export data for table including confidence intervals
	export delimited using $savedir\all_cox_data_inc_ci_`j'.csv, replace
	* drop formated confidence intervals
	drop unadj_ci p_adj_ci f_adj_ci
	save ./output/tables/all_cox_data_`j', replace
	export delimited using ./output/tables/all_cox_data_`j'.csv, replace
	}