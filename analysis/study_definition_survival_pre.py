# Defines coholistrt pre-pandemic 1st March 2018 - 23rd March 2020
from cohortextractor import (
    StudyDefinition,
    patients,
    codelist,
)
from codelists import *
from common_variables import common_variables

# Create ICD-10 codelists for type 1 and type 2 diabetes
# Remove once codelists are on opencodelists
t1dm_icd_codes = codelist(["E10"], system="icd10")
t2dm_icd_codes = codelist(["E11"], system="icd10")

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.05,
    },
    index_date="2018-03-01",
    population=patients.satisfying(
        """
        has_follow_up AND
        (age >=18 AND age <= 110) AND
        (NOT died) AND
        (sex = 'M' OR sex = 'F') AND
        (stp != 'missing') AND
        (imd != 'missing') AND
        (household <=15) 
        """,
        has_follow_up=patients.registered_with_one_practice_between(
            "index_date - 3 months", "2020-02-01"
        ),
        died=patients.died_from_any_cause(
            on_or_before="index_date"
        ),
        stp=patients.registered_practice_as_of(
            "index_date",
            returning="stp_code",
            return_expectations={
               "category": {"ratios": {"STP1": 0.3, "STP2": 0.2, "STP3": 0.5}},
            },
        ),
        household=patients.household_as_of(
            "2020-02-01",
            returning="household_size",
        ),
    ),
    # Hospitalisation with primary reason CVD (inc. MI, stroke, heart failure, VTE)
    # MI
    mi_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=mi_icd_codes,
        on_or_before="2020-03-22",
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    **common_variables
)