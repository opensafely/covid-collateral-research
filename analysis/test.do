* Testing import 

cap log using ./logs/test.log, replace

* Prepare datasets
foreach period in pre pandemic wave1 easing1 wave2 easing2 wave3 easing3 {
    import delimited using ./output/survival/input_survival_`period'.csv, clear
    describe
    }

 log close