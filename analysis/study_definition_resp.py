# Defining study population for people with either COPD or asthma for
# respiratory outcomes
from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists
)
from codelists import *
from common_variables import common_variables

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
        (household <=15) AND
        (has_asthma OR has_copd)
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
        
    # Clinical monitoring - COPD review in the last 12 months
    copd_review=patients.with_these_clinical_events(
        codelist=copd_review_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Clinical monitoring - asthma review in the last 12 months
    asthma_review=patients.with_these_clinical_events(
        codelist=asthma_review_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Hospital admission - COPD exacerbation
    copd_exacerbation=patients.satisfying(
        """copd_exacerbation_hospital OR 
        copd_hospital OR 
        (lrti_hospital AND copd_any)""",
        copd_exacerbation_hospital=patients.admitted_to_hospital(
            with_these_primary_diagnoses=copd_exacerbation_icd_codes,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="binary_flag",
            return_expectations={"incidence": 0.1},
        ),
        copd_hospital=patients.admitted_to_hospital(
            with_these_primary_diagnoses=copd_icd_codes,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="binary_flag",
            return_expectations={"incidence": 0.1},
            ),
        lrti_hospital=patients.admitted_to_hospital(
            with_these_primary_diagnoses=lrti_icd_codes,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="binary_flag",
            return_expectations={"incidence": 0.1},
            ),
        copd_any=patients.admitted_to_hospital(
            with_these_diagnoses=copd_icd_codes,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="binary_flag",
            return_expectations={"incidence": 0.1},
        ),
    ),
    copd_exacerbation_nolrti=patients.satisfying(
        """
        copd_exacerbation_hospital2 OR 
        copd_hospital2
        """,
        copd_exacerbation_hospital2=patients.admitted_to_hospital(
            with_these_primary_diagnoses=copd_exacerbation_icd_codes,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="binary_flag",
            return_expectations={"incidence": 0.1},
        ),
        copd_hospital2=patients.admitted_to_hospital(
            with_these_primary_diagnoses=copd_icd_codes,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="binary_flag",
            return_expectations={"incidence": 0.1},
            ),
    ),
    asthma_exacerbation=patients.admitted_to_hospital(
        with_these_primary_diagnoses=asthma_exacerbation_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # No need to do primary and any code for hospital admissions because 
    # of the way asthma and copd exacerbation are defined
   
    # Emergency admissions - SNOMED codelists still to be defined
    **common_variables
)

# Generate measures

measures = [
   # Clinical monitoring - Asthma review in last 12 months in those with asthma
    # by ethnicity
    Measure(
        id="asthma_monitoring_ethnicity_rate",
        numerator="asthma_review",
        denominator="has_asthma",
        group_by=["ethnicity"],
    ),
    # by IMD
    Measure(
        id="asthma_monitoring_imd_rate",
        numerator="asthma_review",
        denominator="has_asthma",
        group_by=["imd"],
    ),
    # Clinical monitoring - COPD review in last 12 months in those with COPD
    # by ethnicity
    Measure(
        id="copd_monitoring_ethnicity_rate",
        numerator="copd_review",
        denominator="has_copd",
        group_by=["ethnicity"],
    ),
    # by IMD
    Measure(
        id="copd_monitoring_imd_rate",
        numerator="copd_review",
        denominator="has_copd",
        group_by=["imd"],
    ),
    # Hospital admission for asthma in those with asthma
    # by ethnicity
    Measure(
        id="asthma_exacerbation_ethnicity_rate",
        numerator="asthma_exacerbation",
        denominator="has_asthma",
        group_by=["ethnicity"],
    ),
    # by IMD
    Measure(
        id="asthma_exacerbation_imd_rate",
        numerator="asthma_exacerbation",
        denominator="has_asthma",
        group_by=["imd"],
    ),
    # Hospital admission for copd in those with copd
    # by ethnicity
    Measure(
        id="copd_exacerbation_ethnicity_rate",
        numerator="copd_exacerbation",
        denominator="has_copd",
        group_by=["ethnicity"],
    ),
    # by IMD
    Measure(
        id="copd_exacerbation_imd_rate",
        numerator="copd_exacerbation",
        denominator="has_copd",
        group_by=["imd"],
    ),
    Measure(
        id="copd_exac_nolrti_ethnicity_rate",
        numerator="copd_exacerbation_nolrti",
        denominator="has_copd",
        group_by=["ethnicity"],
    ),
    # by IMD
    Measure(
        id="copd_exac_nolrti_imd_rate",
        numerator="copd_exacerbation_nolrti",
        denominator="has_copd",
        group_by=["imd"],
    ),
]
