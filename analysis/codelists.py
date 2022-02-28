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
asthma_codelist = codelist_from_csv(
    "codelists/opensafely-asthma-annual-review-qof.csv",
    system="snomed",
    column="code",)

copd_codelist = codelist_from_csv(
    "codelists/opensafely-chronic-obstructive-pulmonary-disease-copd-review-qof.csv",
    system="snomed",
    column="code",)

qrisk_codelist = codelist_from_csv(
    "codelists/opensafely-cvd-risk-assessment-score-qof.csv",
    system="snomed",
    column="code",)

tsh_codelist = codelist_from_csv(
    "codelists/opensafely-thyroid-stimulating-hormone-tsh-testing.csv",
    system="snomed",
    column="code",)

alt_codelist = codelist_from_csv(
    "codelists/opensafely-alanine-aminotransferase-alt-tests.csv",
    system="snomed",
    column="code",)

cholesterol_codelist = codelist_from_csv(
    "codelists/opensafely-cholesterol-tests.csv",
    system="snomed",
    column="code",)

hba1c_codelist = codelist_from_csv(
    "codelists/opensafely-glycated-haemoglobin-hba1c-tests.csv",
    system="snomed",
    column="code",)

rbc_codelist = codelist_from_csv(
    "codelists/opensafely-red-blood-cell-rbc-tests.csv",
    system="snomed",
    column="code",)

sodium_codelist = codelist_from_csv(
    "codelists/opensafely-sodium-tests-numerical-value.csv",
    system="snomed",
    column="code",)

systolic_bp_codelist = codelist_from_csv(
    "codelists/opensafely-systolic-blood-pressure-qof.csv",
    system="snomed",
    column="code",)
