cap log using ./logs/check.log, replace
clear 
import delimited using "./output/measures/input_2020-03-01.csv"
tab ethnicity, m

log close
