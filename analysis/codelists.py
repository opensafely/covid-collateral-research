# Remember to update codelists.txt with new codelists prior to import 
from cohortextractor import codelist_from_csv

mi_codes = codelist_from_csv(
    "codelists/opensafely-myocardial-infarction-2.csv",
    system="ctv3",
    column="CTV3Code",
)
mi_codes_hospital = codelist_from_csv(
    "codelists/opensafely-cardiovascular-secondary-care.csv",
    system="icd10",
    column="icd",
    category_column="mi",
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)
asthma_review_codes= codelist_from_csv(
    "codelists/opensafely-asthma-annual-review-qof.csv",
    system="snomed",
    column="code",)

copd_review_codes= codelist_from_csv(
    "codelists/opensafely-chronic-obstructive-pulmonary-disease-copd-review-qof.csv",
    system="snomed",
    column="code",)

qrisk_codes= codelist_from_csv(
    "codelists/opensafely-cvd-risk-assessment-score-qof.csv",
    system="snomed",
    column="code",)

tsh_codes= codelist_from_csv(
    "codelists/opensafely-thyroid-stimulating-hormone-tsh-testing.csv",
    system="snomed",
    column="code",)

alt_codes= codelist_from_csv(
    "codelists/opensafely-alanine-aminotransferase-alt-tests.csv",
    system="snomed",
    column="code",)

cholesterol_codes= codelist_from_csv(
    "codelists/opensafely-cholesterol-tests.csv",
    system="snomed",
    column="code",)

hba1c_codes= codelist_from_csv(
    "codelists/opensafely-glycated-haemoglobin-hba1c-tests.csv",
    system="snomed",
    column="code",)

rbc_codes= codelist_from_csv(
    "codelists/opensafely-red-blood-cell-rbc-tests.csv",
    system="snomed",
    column="code",)

sodium_codes= codelist_from_csv(
    "codelists/opensafely-sodium-tests-numerical-value.csv",
    system="snomed",
    column="code",)

systolic_bp_codes= codelist_from_csv(
    "codelists/opensafely-systolic-blood-pressure-qof.csv",
    system="snomed",
    column="code",)

t1dm_codes= codelist_from_csv(
    "codelists/opensafely-type-1-diabetes.csv",
    system="ctv3",
    column="CTV3ID",)

t2dm_codes= codelist_from_csv(
    "codelists/opensafely-type-2-diabetes.csv",
    system="ctv3",
    column="CTV3ID",)

asthma_codes = codelist_from_csv(
    "codelists/opensafely-current-asthma.csv",
    system="ctv3",
    column="CTV3ID",)

copd_codes = codelist_from_csv(
    "codelists/opensafely-current-copd.csv",
    system="ctv3",
    column="CTV3ID",)

dm_keto_icd_codes = codelist_from_csv(
    "codelists/opensafely-diabetic-ketoacidosis-secondary-care.csv",
    system="icd10",
    column="icd10_code",)

stroke_icd_codes = codelist_from_csv(
    "codelists/opensafely-stroke-secondary-care.csv",
    system="icd10",
    column="icd",)

vte_icd_codes = codelist_from_csv(
    "codelists/opensafely-venous-thromboembolic-disease-hospital.csv",
    system="icd10",
    column="ICD_code",)

asthma_exacerbation_icd_codes = codelist_from_csv(
    "codelists/opensafely-asthma-exacerbation-secondary-care.csv",
    system="icd10",
    column="code",)

copd_icd_codes = codelist_from_csv(
    "codelists/opensafely-copd-secondary-care.csv",
    system="icd10",
    column="code",)

copd_exacerbation_icd_codes = codelist_from_csv(
    "codelists/opensafely-copd-exacerbation.csv",
    system="icd10",
    column="code",)

depression_icd_codes = codelist_from_csv(
    "codelists/user-emilyherrett-depression_icd10.csv",
    system="icd10",
    column="code",)

severe_mental_illness_icd_codes = codelist_from_csv(
    "codelists/user-emilyherrett-severe_mental_illness_icd10.csv",
    system="icd10",
    column="code",
)

anxiety_icd_codes = codelist_from_csv(
    "codelists/user-emilyherrett-anxiety_icd10.csv",
    system="icd10",
    column="code",
)

ocd_icd_codes = codelist_from_csv(
    "codelists/user-emilyherrett-ocd_icd10.csv",
    system="icd10",
    column="code",
)

eating_disorders_icd_codes = codelist_from_csv(
    "codelists/user-emilyherrett-eating_disorder_icd10.csv",
    system="icd10",
    column="code",
)

self_harm_icd_codes = codelist_from_csv(
    "codelists/user-emilyherrett-self_harm_icd10.csv",
    system="icd10",
    column="code",
)

suicide_icd_codes = codelist_from_csv(
    "codelists/user-hjforbes-suicide-icd-10.csv",
    system="snomed",
    column="code",
)


