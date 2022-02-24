from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    filter_codes_by_category,
)
from codelists import *

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
            "index_date - 3 months", "index_date"
        ),
        age=patients.age_as_of(
            "index_date",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
        ),
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.5, "U": 0.01}},
            }
        ),
        stp=patients.registered_practice_as_of(
            "index_date",
            returning="stp_code",
            return_expectations={
               "category": {"ratios": {"STP1": 0.3, "STP2": 0.2, "STP3": 0.5}},
            },
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
        household=patients.household_as_of(
            "index_date",
            returning="household_size",
        ),
    ),

    MI=patients.satisfying(
        "mi_gp OR mi_hospital OR mi_ons",
        mi_gp=patients.with_these_clinical_events(
            mi_codes,
            between=["index_date", "last_day_of_month(index_date)"],
            return_expectations={"incidence": 0.05},
        ),
        mi_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=filter_codes_by_category(
            mi_codes_hospital, include=["1"]),
            between=["index_date", "last_day_of_month(index_date)"],
            return_expectations={"incidence": 0.05},
        ),
        mi_ons=patients.with_these_codes_on_death_certificate(
            filter_codes_by_category(mi_codes_hospital, include=["1"]),
            between=["index_date", "last_day_of_month(index_date)"],
            return_expectations={"incidence": 0.05},
        ),
    ),
) 

measures = [
    Measure(
        id="MI_rate",
        numerator="MI",
        denominator="population",
        group_by=["sex"],
    ),
]