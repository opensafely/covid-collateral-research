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
        (imd != 'missing') AND
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
    age=patients.age_as_of(
            "index_date",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
        ), 
    has_asthma=patients.with_these_clinical_events(
        asthma_codes,
        between=["index_date - 3 years", "index_date"],
        returning="binary_flag",
        return_expectations={"incidence":0.2,}
    ),
    has_copd=patients.satisfying(
        """has_copd_code AND age>40""",
        has_copd_code=patients.with_these_clinical_events(
            copd_codes,
            on_or_before="index_date",
            returning="binary_flag",
            return_expectations={"incidence":0.8,}
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
    imd=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
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
    # Clinical monitoring - COPD review in the last 12 months
    copd_review=patients.with_these_clinical_events(
        codelist=copd_review_codes,
        between=["index_date - 12 months", "index_date"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Clinical monitoring - asthma review in the last 12 months
    asthma_review=patients.with_these_clinical_events(
        codelist=asthma_review_codes,
        between=["index_date - 12 months", "index_date"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Hospital admission - COPD exacerbation
    copd_exacerbation=patients.satisfying(
        """copd_exacerbation_hospital OR 
        copd_hospital OR 
        (lrti_hospital AND copd_any)""",
        copd_exacerbation_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=copd_exacerbation_icd_codes,
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
    asthma_exacerbation=patients.admitted_to_hospital(
        with_these_primary_diagnoses=asthma_exacerbation_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
    ),
    # No need to do primary and any code for hospital admissions because 
    # of the way asthma and copd exacerbation are defined
   
    # Emergency admissions - SNOMED codelists still to be defined
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
]
