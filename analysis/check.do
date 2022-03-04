cap log using ./logs/check.log, replace

clear 
import delimited using ./output/measures/measure_asthma_rate.csv
* generate rate per 100,000
gen rate = value*100000
* Format date
gen dateA = date(date, "YMD")
drop date
format dateA %dD/M/Y
tab dateA 
* reshape dataset so columns with rates for each ethnicity 
reshape wide value rate population asthma, i(dateA) j(ethnicity)
rename value1 white
rename value2 mixed
rename value3 asian
rename value4 black
rename value5 other

* Generate line graph
graph twoway line rate1 rate2 date, name(test) 
*|| line mixed date || line asian date || line black date || line other date
graph export ./output/line_ethnic_asthma.svg, name(test)

log close
