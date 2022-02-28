cap log using ./logs/check.log, replace
clear 
import delimited using "./output/measures/input_2020_03_01.csv"

tab ethnicity, m

log close