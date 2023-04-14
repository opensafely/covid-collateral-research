/* ===========================================================================
Do file name:   flowchart.do
Project:        COVID Collateral
Date:           17/11/2022
Author:         Ruth Costello
Description:    Generates numbers for flowchart
==============================================================================*/
cap log using ./logs/flowchart.log, replace

import delimited using ./output/measures/tables/input_flowchart_2020-01-01.csv, clear
describe
* Inclusion criteria
* has_follow_up AND
* (age >=18 AND age <= 110) AND
* (NOT died) AND
* (sex = 'M' OR sex = 'F') AND
* (imd != 0) AND
* (stp != 'missing') AND
* (household>=1 AND household<=15) 
table sex
safecount
drop if has_follow_up!=1
safecount
drop if died==1
safecount
drop if (age<18 | age>110)
safecount
drop if (sex=="U" | sex=="I")
safecount
drop if imd==0
safecount 
drop if stp==""
safecount
drop if (household==0 | household>15)
safecount