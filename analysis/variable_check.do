* Checking missingness for static variables
cap log using ./logs/missing_check.log, replace
forvalues j=3/12 {
    di "`i'_2018 cvd"
    if `j'<10 {
        import delimited "./output/measures/cvd/input_2018-0`j'-01.csv", clear
        misstable summarize
        di "`i'_`j' mh"
        import delimited "./output/measures/mh/input_mh_2018-0`j'-01.csv", clear
        misstable summarize
    }
    else {
        import delimited "./output/measures/cvd/input_2018-`j'-01.csv", clear
        misstable summarize
        di "`i'_`j' mh"
        import delimited "./output/measures/mh/input_mh_2018-`j'-01.csv", clear
        misstable summarize
    }
}
/*forvalues i=2019/2021 {
    forvalues j=1/12 {
        di "`i'_`j' cvd"
        if `j'<10 {
            import delimited "./output/measures/cvd/input_`i'-0`j'-01.csv", clear
            misstable summarize
            di "`i'_`j' mh"
            import delimited "./output/measures/mh/input_mh_`i'-0`j'-01.csv", clear
            misstable summarize
        }
        else {
            import delimited "./output/measures/cvd/input_`i'-`j'-01.csv", clear
            misstable summarize
            di "`i'_`j' mh"
            import delimited "./output/measures/mh/input_mh_`i'-`j'-01.csv", clear
            misstable summarize
        }
    }

}
log close