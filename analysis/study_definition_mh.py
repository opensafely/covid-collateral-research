# Creates study population with no restirctions but include indicators for
# mental health and CVD where clinical monitoring is diagnosis specific
from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
)
from codelists import *

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
        age=patients.age_as_of(
            "index_date",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
        ),
        # Sex
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.5, "U": 0.01}},
            },
        ),
        imd=patients.categorised_as(
            {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=0 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation <= 32844""",
            },
        index_of_multiple_deprivation=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
            ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                    }
                },
            },
        ),
    ),
    mh_subgroup=patients.with_these_clinical_events(
    severe_mental_illness_codes,
    returning="binary_flag",
    on_or_before="index_date",
    return_expectations={"incidence": 0.2},
        ),

    # Clinical monitoring
    # Systolic blood pressure - cvd population & mental health population
    systolic_bp=patients.with_these_clinical_events(
        codelist=systolic_bp_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    
    # Hospital admissions - mental health
    depression_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=depression_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    anxiety_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=anxiety_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    smi_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=severe_mental_illness_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    self_harm_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=self_harm_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    eating_dis_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=eating_disorder_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    ocd_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=ocd_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),

    # Hospital admissions - mental health
    depression_admission=patients.admitted_to_hospital(
        with_these_diagnoses=depression_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    anxiety_admission=patients.admitted_to_hospital(
        with_these_diagnoses=anxiety_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    smi_admission=patients.admitted_to_hospital(
        with_these_diagnoses=severe_mental_illness_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    self_harm_admission=patients.admitted_to_hospital(
        with_these_diagnoses=self_harm_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    eating_dis_admission=patients.admitted_to_hospital(
        with_these_diagnoses=eating_disorder_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    ocd_admission=patients.admitted_to_hospital(
        with_these_diagnoses=ocd_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Emergency admissions
    # CVD - codelists still required

    # Mental health
    anxiety_emergency=patients.attended_emergency_care(
        with_these_diagnoses=anxiety_snomed_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    ocd_emergency=patients.attended_emergency_care(
        with_these_diagnoses=ocd_snomed_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    eating_dis_emergency=patients.attended_emergency_care(
        with_these_diagnoses=eating_disorder_snomed_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    self_harm_emergency=patients.attended_emergency_care(
        with_these_diagnoses=self_harm_snomed_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    smi_emergency=patients.attended_emergency_care(
        with_these_diagnoses=severe_mental_illness_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),

 )

measures = [
    # Clinical monitoring
    Measure(
        id="systolic_bp_mh_ethnicity_rate",
        numerator="systolic_bp",
        denominator="mh_subgroup",
        group_by=["ethnicity"],
    ),
    Measure(
        id="systolic_bp_mh_imd_rate",
        numerator="systolic_bp",
        denominator="mh_subgroup",
        group_by=["imd"],
    ),
    # Hospital admissions for depression
    Measure(
        id="depression_admission_ethnicity_rate",
        numerator="depression_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="depression_admission_imd_rate",
        numerator="depression_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for anxiety
    Measure(
        id="anxiety_admission_ethnicity_rate",
        numerator="anxiety_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="anxiety_admission_imd_rate",
        numerator="anxiety_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for severe mental illness
    Measure(
        id="smi_admission_ethnicity_rate",
        numerator="smi_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="smi_admission_imd_rate",
        numerator="smi_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for self harm
    Measure(
        id="self_harm_admission_ethnicity_rate",
        numerator="self_harm_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="self_harm_admission_imd_rate",
        numerator="self_harm_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for eating disorders
    Measure(
        id="eating_dis_admission_ethnicity_rate",
        numerator="eating_dis_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="eating_dis_admission_imd_rate",
        numerator="eating_dis_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for OCD
    Measure(
        id="ocd_admission_ethnicity_rate",
        numerator="ocd_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="ocd_admission_imd_rate",
        numerator="ocd_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for depression
    Measure(
        id="depression_primary_admission_ethnicity_rate",
        numerator="depression_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="depression_primary_admission_imd_rate",
        numerator="depression_primary_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for anxiety
    Measure(
        id="anxiety_primary_admission_ethnicity_rate",
        numerator="anxiety_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="anxiety_primary_admission_imd_rate",
        numerator="anxiety_primary_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for severe mental illness
    Measure(
        id="smi_primary_admission_ethnicity_rate",
        numerator="smi_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="smi_primary_admission_imd_rate",
        numerator="smi_primary_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for self harm
    Measure(
        id="self_harm_primary_admission_ethnicity_rate",
        numerator="self_harm_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="self_harm_primary_admission_imd_rate",
        numerator="self_harm_primary_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Emergency admissions for anxiety
    Measure(
        id="anxiety_emergency_ethnicity_rate",
        numerator="anxiety_emergency",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="anxiety_emergency_imd_rate",
        numerator="anxiety_emergency",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for severe mental illness
    Measure(
        id="smi_emergency_ethnicity_rate",
        numerator="smi_emergency",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="smi_emergency_imd_rate",
        numerator="smi_emergency",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for self harm
    Measure(
        id="self_harm_emergency_ethnicity_rate",
        numerator="self_harm_emergency",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="self_harm_emergency_imd_rate",
        numerator="self_harm_emergency",
        denominator="population",
        group_by=["imd"],
    ),
]