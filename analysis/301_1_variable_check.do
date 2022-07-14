* Sense checking
* Checking missingness for static variables
cap log using ./logs/variable_check.log, replace
foreach period in pre pandemic wave1 easing1 wave2 easing2 wave3 easing3 {
use ./output/prep_survival_`period', clear
di "`period'""
* Display missing STP
di "Missing STP"
count if stp==""
* Check variables
sum age
* Check all those with IMD has hsoa
tab has_msoa imd
* Check comorbidities
foreach var in has_t1_diabetes has_t2_diabetes cvd_subgroup has_asthma has_copd resp_subgroup mh_subgroup {
    tab `var', m
    }
}

/* Check files from 2018
import delimited "./output/measures/cvd/input_2018-03-01.csv", clear
misstable summarize imd 
count if sex==""

import delimited "./output/measures/mh/input_mh_2018-03-01.csv", clear
misstable summarize imd
count if sex==""

* check files from 2019
import delimited "./output/measures/cvd/input_2019-05-01.csv", clear
misstable summarize imd
count if sex==""

import delimited "./output/measures/mh/input_mh_2019-05-01.csv", clear
misstable summarize imd
count if sex==""

* check files from 2020
import delimited "./output/measures/cvd/input_2020-06-01.csv", clear
misstable summarize imd
count if sex==""

import delimited "./output/measures/mh/input_mh_2020-06-01.csv", clear
misstable summarize imd
count if sex==""

* check files from 2021
import delimited "./output/measures/cvd/input_2021-07-01.csv", clear
misstable summarize imd
count if sex==""

import delimited "./output/measures/mh/input_mh_2021-07-01.csv", clear
misstable summarize imd
count if sex==""

* Checking files created with the 2020 static cohort
* Check files from 2018
import delimited "./output/measures/cvd/test/input_2018-03-01.csv", clear
misstable summarize age imd
count if sex==""
count if region==""
        
import delimited "./output/measures/cvd/test/input_2020-03-01.csv", clear
misstable summarize age imd
count if sex==""
count if region==""
*/

/* Checking dates survival analysis
foreach period in pre pandemic wave1 easing1 wave2 easing2 wave3 easing3 {
    use ./output/prep_survival_`period', clear
    list anx_admit_date in 1/5 if anx_admit_date!=.
    gen anx_admit=(anx_admit_date!=.)
    tab anx_admit

    count if anx_admit_date < index_date
    count if end_date < index_date

    gen anx_end = end_date
    replace anx_end = anx_admit_date if anx_admit==1
}*/

log close