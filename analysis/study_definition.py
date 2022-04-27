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
        age=patients.age_as_of(
            "index_date",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
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
    sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.5, "U": 0.01}},
            }
        ),
    ethnicity=patients.categorised_as(
        {"0": "DEFAULT",
            "1": "eth='1' OR (NOT eth AND ethnicity_sus='1')",
            "2": "eth='2' OR (NOT eth AND ethnicity_sus='2')",
            "3": "eth='3' OR (NOT eth AND ethnicity_sus='3')",
            "4": "eth='4' OR (NOT eth AND ethnicity_sus='4')",
            "5": "eth='5' OR (NOT eth AND ethnicity_sus='5')",
            },
        return_expectations={
            "category": {"ratios": {"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.2, "5": 0.2}},
            "incidence": 1.0,
            },
        eth=patients.with_these_clinical_events(
            ethnicity_codes,
            returning="category",
            find_last_match_in_period=True,
            include_date_of_match=False,
            return_expectations={
                "category": {"ratios": {"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.2, "5": 0.2}},
                "incidence": 1.00,
            },
        ),
        # fill missing ethnicity from SUS
        ethnicity_sus=patients.with_ethnicity_from_sus(
            returning="group_6",
            use_most_frequent_code=True,
            return_expectations={
                "category": {"ratios": {"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.2, "5": 0.2}},
                "incidence": 1.00,
            },
        ),
    ),
    # Flag for mental health subgroup for clinical monitoring
    mh_group=patients.with_these_clinical_events(
        severe_mental_illness_codes,
        returning="binary_flag",
        on_or_before="index_date",
        return_expectations={"incidence": 0.2},
    ),
    # Flag for CVD subgroup (with CHD, stroke or TIA) for clinical monitoring
    cvd_group=patients.satisfying(
        """
        has_chd OR
        has_stroke OR
        has_tia
        """,
        has_chd=patients.with_these_clinical_events(
            chd_codes,
            returning="binary_flag",
            on_or_before="index_date",
            return_expectations={"incidence": 0.1},
        ),
        has_stroke=patients.with_these_clinical_events(
            stroke_codes,
            returning="binary_flag",
            on_or_before="index_date",
            return_expectations={"incidence": 0.1},
        ),
        has_tia=patients.with_these_clinical_events(
            tia_codes,
            returning="binary_flag",
            on_or_before="index_date",
            return_expectations={"incidence": 0.1},
        ),
    ),

    imd=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
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
    
    # Clinical monitoring
    # Systolic blood pressure - cvd population & mental health population
    systolic_bp=patients.with_these_clinical_events(
        codelist=systolic_bp_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    
    # Hospital admissions primary diagnosis - CVD
    # MI
    mi_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=mi_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Stroke
    stroke_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=stroke_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # TIA
    #tia_admission=patients.admitted_to_hospital(
    #   with_these_diagnoses=tia_icd_codes,
    #   between=["index_date", "last_day_of_month(index_date)"],
    #   returning="binary_flag",
    #   return_expectations={"incidence": 0.1},
    #),
    # Unstable angina

    # Heart failure
    heart_failure_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=heart_failure_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # VTE
    vte_primary_admission=patients.admitted_to_hospital(
        with_these_primary_diagnoses=vte_icd_codes,
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

    # Hospital admissions any diagnosis - CVD
    # MI
    mi_admission=patients.admitted_to_hospital(
        with_these_diagnoses=mi_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # Stroke
    stroke_admission=patients.admitted_to_hospital(
        with_these_diagnoses=stroke_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # TIA
    #tia_admission=patients.admitted_to_hospital(
    #   with_these_diagnoses=tia_icd_codes,
    #   between=["index_date", "last_day_of_month(index_date)"],
    #   returning="binary_flag",
    #   return_expectations={"incidence": 0.1},
    #),
    # Unstable angina

    # Heart failure
    heart_failure_admission=patients.admitted_to_hospital(
        with_these_diagnoses=heart_failure_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # VTE
    vte_admission=patients.admitted_to_hospital(
        with_these_diagnoses=vte_icd_codes,
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
        id="systolic_bp_cvd_ethnicity_rate",
        numerator="systolic_bp",
        denominator="cvd_group",
        group_by=["ethnicity"],
    ),
    Measure(
        id="systolic_bp_cvd_imd_rate",
        numerator="systolic_bp",
        denominator="cvd_group",
        group_by=["imd"],
    ),
    Measure(
        id="systolic_bp_mh_ethnicity_rate",
        numerator="systolic_bp",
        denominator="mh_group",
        group_by=["ethnicity"],
    ),
    Measure(
        id="systolic_bp_mh_imd_rate",
        numerator="systolic_bp",
        denominator="mh_group",
        group_by=["imd"],
    ),
    # Hospital admissions for MI
    Measure(
        id="mi_admission_ethnicity_rate",
        numerator="mi_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    # Hospital admissions for MI
    Measure(
        id="mi_admission_imd_rate",
        numerator="mi_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for stroke
    Measure(
        id="stroke_admission_ethnicity_rate",
        numerator="stroke_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    # Hospital admissions for stroke
    Measure(
        id="stroke_admission_imd_rate",
        numerator="stroke_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for heart failure
    Measure(
        id="heart_failure_admission_ethnicity_rate",
        numerator="heart_failure_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="heart_failure_admission_imd_rate",
        numerator="heart_failure_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for VTE
    Measure(
        id="vte_admission_ethnicity_rate",
        numerator="vte_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="vte_admission_imd_rate",
        numerator="vte_admission",
        denominator="population",
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
    # Hospital admissions for primary diagnosis MI
    Measure(
        id="mi_primary_admission_ethnicity_rate",
        numerator="mi_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    # Hospital admissions for MI
    Measure(
        id="mi_primary_admission_imd_rate",
        numerator="mi_primary_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for stroke
    Measure(
        id="stroke_primary_admission_ethnicity_rate",
        numerator="stroke_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    # Hospital admissions for stroke
    Measure(
        id="stroke_primary_admission_imd_rate",
        numerator="stroke_primary_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for heart failure
    Measure(
        id="heart_failure_primary_admission_ethnicity_rate",
        numerator="heart_failure_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="heart_failure_primary_admission_imd_rate",
        numerator="heart_failure_primary_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for VTE
    Measure(
        id="vte_primary_admission_ethnicity_rate",
        numerator="vte_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="vte_primary_admission_imd_rate",
        numerator="vte_primary_admission",
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
    # Hospital admissions for eating disorders
    Measure(
        id="eating_dis_primary_admission_ethnicity_rate",
        numerator="eating_dis_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="eating_dis_primary_admission_imd_rate",
        numerator="eating_dis_primary_admission",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for OCD
    Measure(
        id="ocd_primary_admission_ethnicity_rate",
        numerator="ocd_primary_admission",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="ocd_primary_admission_imd_rate",
        numerator="ocd_primary_admission",
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
    # Hospital admissions for eating disorders
    Measure(
        id="eating_dis_emergency_ethnicity_rate",
        numerator="eating_dis_emergency",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="eating_dis_emergency_imd_rate",
        numerator="eating_dis_emergency",
        denominator="population",
        group_by=["imd"],
    ),
    # Hospital admissions for OCD
    Measure(
        id="ocd_emergency_ethnicity_rate",
        numerator="ocd_emergency",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="ocd_emergency_imd_rate",
        numerator="ocd_emergency",
        denominator="population",
        group_by=["imd"],
    ),
]