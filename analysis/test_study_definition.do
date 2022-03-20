/* ===========================================================================
Do file name:   test_study_definition.do
Project:        COVID Collateral
Date:           10/03/2022
Author:         Ruth Costello
Description:    Testing the population generated is as expected
==============================================================================*/
cap log using ./logs/test.log, replace

* Checking input file for a single month is as expected for general study population
clear
import delimited using ./output/measures/input_2020-03-01.csv
count
* Age should be between 18 & 110
sum age, d
* No missing gender
tab sex, m
* Ethnicity not missing
tab ethnicity, m
* STP not missing
tab stp, m
* IMD not missing
tab imd, m
* Household less than 15
sum household, m

* Check input file for diabetes cohort
clear
import delimited using ./output/measures/input_dm_2020-03-01.csv
count
* Check all have DM
tab has_t1_diabetes has_t2_diabetes, m