* Checking missingness for static variables
cap log using ./logs/missing_check.log, replace
* Check files from 2018
import delimited "./output/measures/cvd/input_2018-03-01.csv", clear
misstable summarize
        
import delimited "./output/measures/mh/input_mh_2018-03-01.csv", clear
misstable summarize

* check files from 2019
import delimited "./output/measures/cvd/input_2019-05-01.csv", clear
misstable summarize

import delimited "./output/measures/mh/input_mh_2019-05-01.csv", clear
misstable summarize

* check files from 2020
import delimited "./output/measures/cvd/input_2020-06-01.csv", clear
misstable summarize

import delimited "./output/measures/mh/input_mh_2020-06-01.csv", clear
misstable summarize

* check files from 2021
import delimited "./output/measures/cvd/input_2021-07-01.csv", clear
misstable summarize

import delimited "./output/measures/mh/input_mh_2021-07-01.csv", clear
misstable summarize

log close