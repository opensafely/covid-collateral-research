* Checking missingness for static variables
cap log using ./logs/missing_check.log, replace
* Check files from 2018
import delimited "./output/measures/cvd/input_2018-03-01.csv", clear
misstable summarize age sex imd region
        
import delimited "./output/measures/mh/input_mh_2018-03-01.csv", clear
misstable summarize age sex imd region

* check files from 2019
import delimited "./output/measures/cvd/input_2019-05-01.csv", clear
misstable summarize age imd
count if sex==""
count if region==""

import delimited "./output/measures/mh/input_mh_2019-05-01.csv", clear
misstable summarize age imd
count if sex==""
count if region==""

* check files from 2020
import delimited "./output/measures/cvd/input_2020-06-01.csv", clear
misstable summarize imd
count if sex==""
count if region==""

import delimited "./output/measures/mh/input_mh_2020-06-01.csv", clear
misstable summarize imd
count if sex==""
count if region==""

* check files from 2021
import delimited "./output/measures/cvd/input_2021-07-01.csv", clear
misstable summarize imd
count if sex==""
count if region==""

import delimited "./output/measures/mh/input_mh_2021-07-01.csv", clear
misstable summarize imd
count if sex==""
count if region==""

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

log close