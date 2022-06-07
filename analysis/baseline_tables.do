/*==============================================================================
DO FILE NAME:			baseline_tables.do
PROJECT:				COVID collateral 
DATE: 					28 April 2022 
AUTHOR:					R Costello
						adapted from R Mathur and K Wing	
DESCRIPTION OF FILE:	Produce a table of baseline characteristics for 3 years (2019, 2020, 2021)
DATASETS USED:			output/measures/tables/input_tables_*
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in excel: baseline_table*.xlsx
						Log file: logs/table1_descriptives
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)	
  
 Notes:
 Table 1 population is people who are in the study population on 1st January 2019, 2020 & 2021
 ==============================================================================*/

*local dataset `1'
adopath + ./analysis/ado 

capture log close
log using ./logs/table1_descriptives.log, replace

cap mkdir ./output/tables

* Create  baseline tables for 3 years
forvalues i=2019/2021 {
* Import csv file
    import delimited ./output/measures/tables/input_tables_`i'-01-01.csv, clear
    *update variable with missing so that . is shown as unknown (just for this table)
    *(1) ethnicity
    replace ethnicity=6 if ethnicity==.
    label define eth5 			1 "White"  					///
                                2 "Mixed"				///						
                                3 "Asian"  					///
                                4 "Black"					///
                                5 "Other"					///
                                6 "Unknown"
                        

    label values ethnicity eth5
    safetab ethnicity, m
    *(2) IMD
    replace imd=6 if imd==0

    * Create age categories
    egen age_cat = cut(age), at(18, 40, 60, 80, 120) icodes
    label define age 0 "18 - 40 years" 1 "41 - 60 years" 2 "61 - 80 years" 3 ">80 years"
    label values age_cat age

    preserve
    * Create baseline table
    table1_mc, vars(age_cat cate \ sex cate \ ethnicity cate \ eth cate \ ethnicity_sus cate \ imd cate \ region cate \ has_t1_diabetes cate ///
    \ has_t2_diabetes cate \ has_asthma cate \ has_copd cate \ cvd_subgroup cate \ mh_subgroup cate) clear
    export delimited using ./output/tables/baseline_table_`i'.csv
    restore
    drop if ethnicity==6
    gen white = (ethnicity==1)
    gen mixed = (ethnicity==2)
    gen asian = (ethnicity==3)
    gen black = (ethnicity==4)
    gen other = (ethnicity==5)

    tempfile tempfile
    preserve
    keep if ethnicity==1
    table1_mc, vars(age_cat cate \ sex cate \ imd cate \ region cate \ has_t1_diabetes cate ///
    \ has_t2_diabetes cate \ has_asthma cate \ has_copd cate \ cvd_subgroup cate \ mh_subgroup cate) clear
    save `tempfile', replace
    restore
    forvalues j=2/5 {
      preserve
      keep if ethnicity==`j'
      table1_mc, vars(age_cat cate \ sex cate \ imd cate \ region cate \  has_t1_diabetes cate ///
      \ has_t2_diabetes cate \ has_asthma cate \ has_copd cate \ cvd_subgroup cate \ mh_subgroup cate) clear
      append using `tempfile'
      save `tempfile', replace
      restore
      }
    use `tempfile', clear
    export delimited using ./output/tables/baseline_table_strata`i'.csv
    }

* Close log file 
log close