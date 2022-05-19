/*==============================================================================
DO FILE NAME:			baseline_tables.do
PROJECT:				COVID collateral 
DATE: 					28 April 2022 
AUTHOR:					R Costello
						adapted from R Mathur and K Wing	
DESCRIPTION OF FILE:	Produce a table of baseline characteristics for 3 years (2019, 2020, 2021)
DATASETS USED:			output/measures/tables/input_tables_*
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in txt: table1.txt 
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
    replace imd=6 if imd==.

    * Create age categories
    egen age_cat = cut(age), at(18, 40, 60, 80, 120) icodes
    label define age 1 "18 - 40 years" 2 "41 - 60 years" 3 "61 - 80 years" 4 ">80 years"
    label values age_cat age

    * Use new package
    table1_mc, vars(age_cat cate \ sex cate \ ethnicity cate \ eth cate \ ethnicity_sus cate \ imd cate \ region cate) clear
    export delimited using ./output/tables/baseline_table_`i'.csv
    }

* Close log file 
log close