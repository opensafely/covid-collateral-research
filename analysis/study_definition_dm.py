# Defining study population for diabetes outcome where population needs to be people with type 1 
# or type 2 diabetes at index 
from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists
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
    # Update index date to 2018-03-01 when ready to run on full dataset
    index_date="2018-03-01",
    population=patients.satisfying(
        """
        has_follow_up AND
        (age >=18 AND age <= 110) AND
        (NOT died) AND
        (sex = 'M' OR sex = 'F') AND
        (stp != 'missing') AND
        (imd != 0) AND
        (household>=1 AND household<=15) AND
        (has_t1_diabetes OR has_t2_diabetes)
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
    
    # Clinical monitoring - HbA1c in the last 3 months
    hba1c=patients.with_these_clinical_events(
        codelist=hba1c_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Clinical monitoring - blood pressure measured in last year
    systolic_bp=patients.with_these_clinical_events(
        codelist=systolic_bp_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    bp_meas=patients.with_these_clinical_events(
        codelist=bp_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Inpatient admission with primary code of diabetes 
    # Type 1 DM
    t1dm_admission_primary=patients.admitted_to_hospital(
        with_these_primary_diagnoses=t1dm_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Type 2 DM
    t2dm_admission_primary=patients.admitted_to_hospital(
        with_these_primary_diagnoses=t2dm_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Ketoacidosis
    dm_keto_admission_primary=patients.admitted_to_hospital(
        with_these_primary_diagnoses=dm_keto_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Inpatient admission with any code of diabetes
    # Type 1 DM
    t1dm_admission_any=patients.admitted_to_hospital(
        with_these_diagnoses=t1dm_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Type 2 DM
    t2dm_admission_any=patients.admitted_to_hospital(
        with_these_diagnoses=t2dm_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Ketoacidosis
    dm_keto_admission_any=patients.admitted_to_hospital(
        with_these_diagnoses=dm_keto_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Emergency admission with code of diabetes - codes need defining
    # Type 1 DM
    #t1dm_admission_emergency=patients.attended_emergency_care(
    #    with_these_diagnoses=t1dm_snomed_codes,
    #    between=["index_date", "last_day_of_month(index_date)"],
    #    returning="binary_flag",
    #    return_expectations={"incidence": 0.05},
    #),
    # Type 2 DM
    #t2dm_admission_emergency=patients.attended_emergency_care(
    #    with_these_diagnoses=t2dm_snomed_codes,
    #    between=["index_date", "last_day_of_month(index_date)"],
    #    returning="binary_flag",
    #    return_expectations={"incidence": 0.05},
    #),
    # Ketoacidosis
    #dm_keto_admission_emergency=patients.attended_emergency_care(
    #    with_these_diagnoses=dm_keto_snomed_codes,
    #    between=["index_date", "last_day_of_month(index_date)"],
    #    returning="binary_flag",
    #    return_expectations={"incidence": 0.05},
    #),
    **common_variables
)
# Generate summary data by ethnicity for each outcome
measures = [
    # Clinical monitoring - HbA1c
    Measure(
        id="dm_hba1c_ethnicity_rate",
        numerator="hba1c",
        denominator="population",
        group_by=["ethnicity"],
    ),
    # Clinical monitoring - blood pressure
    Measure(
        id="dm_systolic_bp_ethnicity_rate",
        numerator="systolic_bp",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="dm_bp_meas_ethnicity_rate",
        numerator="bp_meas",
        denominator="population",
        group_by=["ethnicity"],
    ),
    # Primary admission code type 1 DM
    Measure(
        id="dm_t1_primary_ethnicity_rate",
        numerator="t1dm_admission_primary",
        denominator="has_t1_diabetes",
        group_by=["ethnicity"],
    ),
    # Primary admission code type 2 DM
    Measure(
        id="dm_t2_primary_ethnicity_rate",
        numerator="t2dm_admission_primary",
        denominator="has_t2_diabetes",
        group_by=["ethnicity"],
    ),
    # Primary admission code ketoacidosis
    Measure(
        id="dm_keto_primary_ethnicity_rate",
        numerator="dm_keto_admission_primary",
        denominator="population",
        group_by=["ethnicity"],
    ),
    # Admission with type 1 DM code
    Measure(
        id="dm_t1_any_ethnicity_rate",
        numerator="t1dm_admission_any",
        denominator="has_t1_diabetes",
        group_by=["ethnicity"],
    ),
    # Admission with type 2 code
    Measure(
        id="dm_t2_any_ethnicity_rate",
        numerator="t2dm_admission_any",
        denominator="has_t2_diabetes",
        group_by=["ethnicity"],
    ),
    # Admission with ketoacidosis code
    Measure(
        id="dm_keto_any_ethnicity_rate",
        numerator="dm_keto_admission_any",
        denominator="population",
        group_by=["ethnicity"],
    ),
    # Emergency admission with type 1 DM code
    #Measure(
    #   id="dm_t1_emergency_ethnicity_rate",
    #    numerator="t1dm_admission_emergency",
    #    denominator="has_t1_diabetes",
    #    group_by=["ethnicity"],
    #),
    # Emergency admission with type 2 DM code
    #Measure(
    #    id="dm_t2_emergency_ethnicity_rate",
    #    numerator="t2dm_admission_emergency",
    #    denominator="has_t2_diabetes",
    #    group_by=["ethnicity"],
    #),
    # Emergency admission with ketoacidosis code
    #Measure(
    #    id="dm_keto_emergency_ethnicity_rate",
    #    numerator="dm_keto_admission_emergency",
    #    denominator="population",
    #    group_by=["ethnicity"],
    #),
    # Generate summary data by IMD for each outcome
    # Clinical monitoring - HbA1c
    Measure(
        id="dm_hba1c_imd_rate",
        numerator="hba1c",
        denominator="population",
        group_by=["imd"],
    ),
    # Clinical monitoring - blood pressure
    Measure(
        id="dm_systolic_bp_imd_rate",
        numerator="systolic_bp",
        denominator="population",
        group_by=["imd"],
    ),
    # Primary admission code type 1 DM
    Measure(
        id="dm_t1_primary_imd_rate",
        numerator="t1dm_admission_primary",
        denominator="has_t1_diabetes",
        group_by=["imd"],
    ),
    Measure(
        id="dm_bp_meas_imd_rate",
        numerator="bp_meas",
        denominator="population",
        group_by=["imd"],
    ),
    # Primary admission code type 2 DM
    Measure(
        id="dm_t2_primary_imd_rate",
        numerator="t2dm_admission_primary",
        denominator="has_t2_diabetes",
        group_by=["imd"],
    ),
    # Primary admission code ketoacidosis
    Measure(
        id="dm_keto_primary_imd_rate",
        numerator="dm_keto_admission_primary",
        denominator="population",
        group_by=["imd"],
    ),
    # Admission code with type 1 DM
    Measure(
        id="dm_t1_any_imd_rate",
        numerator="t1dm_admission_any",
        denominator="has_t1_diabetes",
        group_by=["imd"],
    ),
    # Admission coded with type 2 DM
    Measure(
        id="dm_t2_any_imd_rate",
        numerator="t2dm_admission_any",
        denominator="has_t2_diabetes",
        group_by=["imd"],
    ),
    # Admission coded with ketoacidosis
    Measure(
        id="dm_keto_any_imd_rate",
        numerator="dm_keto_admission_any",
        denominator="population",
        group_by=["imd"],
    ),
    # Emergency admission coded with type 1 DM
    #Measure(
    #    id="dm_t1_emergency_imd_rate",
    #    numerator="t1dm_admission_emergency",
    #    denominator="has_t1_diabetes",
    #    group_by=["imd"],
    #),
    # Emergency admission coded with type 2 DM
    #Measure(
    #    id="dm_t2_emergency_imd_rate",
    #    numerator="t2dm_admission_emergency",
    #    denominator="has_t2_diabetes",
    #    group_by=["imd"],
    #),
    # Emergency admission coded with ketoacidosis
    #Measure(
    #    id="dm_keto_emergency_imd_rate",
    #    numerator="dm_keto_admission_emergency",
    #    denominator="population",
    #    group_by=["imd"],
    #),
]