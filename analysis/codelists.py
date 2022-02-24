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
