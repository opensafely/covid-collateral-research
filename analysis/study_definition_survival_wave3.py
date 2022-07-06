from cohortextractor import (
    StudyDefinition,
    patients,
    codelist,
    filter_codes_by_category,
)
from codelists import *
from common_variables import common_variables

# Create ICD-10 codelists for type 1 and type 2 diabetes
# Remove once codelists are on opencodelists
t1dm_icd_codes = codelist(["E10"], system="icd10")
t2dm_icd_codes = codelist(["E11"], system="icd10")

end_date="2021-12-14"

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.05,
    },
    index_date="2021-05-28",
    population=patients.satisfying(
        """
        has_follow_up AND
        (age >=18 AND age <= 110) AND
        (NOT died) AND
        (sex = 'M' OR sex = 'F') AND
        (stp != 'missing') AND
        (imd != 0) AND
        (household <=15) 
        """,
        has_follow_up=patients.registered_with_one_practice_between(
            "index_date - 3 months", "index_date"
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
    dereg_date=patients.date_deregistered_from_all_supported_practices(
        on_or_after="index_date",
        date_format="YYYY-MM",
        return_expectations={"date": {"earliest": "2020-03-01"}}
    ),
    died_fu=patients.died_from_any_cause(
            on_or_after="index_date",
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2020-03-01"}}
    ),
    # Hospitalisation with primary reason CVD (inc. MI, stroke, heart failure, VTE)
    # MI
    mi_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=filter_codes_by_category(mi_icd_codes, include=["1"]),
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    # Stroke
    stroke_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=stroke_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    # Heart failure
    heart_failure_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=filter_codes_by_category(heart_failure_icd_codes, include=["1"]),
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    # VTE
    vte_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=vte_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    cvd_admission_date=patients.minimum_of(
        "mi_primary_admission",
        "stroke_primary_admission",
        "heart_failure_primary_admission",
        "vte_primary_admission"),
    # Hospitalisation with primary reason diabetes (T1, T2 or ketoacidosis)
    # Type 1 DM
    t1dm_admission_primary=patients.admitted_to_hospital(
        with_these_primary_diagnoses=t1dm_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    # Type 2 DM
    t2dm_admission_primary=patients.admitted_to_hospital(
        with_these_primary_diagnoses=t2dm_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    # Ketoacidosis
    dm_keto_admission_primary=patients.admitted_to_hospital(
        with_these_primary_diagnoses=dm_keto_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    dm_admission=patients.minimum_of(
        "t1dm_admission_primary",
        "t2dm_admission_primary",
        "dm_keto_admission_primary"),
    # Hospitalisation for COPD exacerbation
    # Hospital admission - COPD exacerbation      
    copd_exacerbation_hospital=patients.admitted_to_hospital(
        with_these_diagnoses=copd_exacerbation_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
    ),
    copd_hospital=patients.admitted_to_hospital(
        with_these_primary_diagnoses=copd_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
        ),
    lrti_hospital=patients.admitted_to_hospital(
        with_these_primary_diagnoses=lrti_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
        ),
    copd_any=patients.admitted_to_hospital(
        with_these_diagnoses=copd_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
        ),
    
    copd_hospitalisation_date=patients.minimum_of(
        "copd_any", 
        "lrti_hospital", 
        "copd_hospital", 
        "copd_exacerbation_hospital"),
    
    asthma_exacerbation=patients.admitted_to_hospital(
        with_these_primary_diagnoses=asthma_exacerbation_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
        ),
    # Hospital admissions - mental health
    depression_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=depression_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
        ),
    anxiety_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=anxiety_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
        ),
    smi_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=severe_mental_illness_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
        ),
    self_harm_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=self_harm_icd_codes,
        between=["index_date", end_date],
        returning="date_admitted",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2018-03-01"}},
        ),
    mh_admission=patients.minimum_of(
        "depression_primary_admission",
        "anxiety_primary_admission",
        "smi_primary_admission",
        "self_harm_primary_admission"),
    **common_variables
)