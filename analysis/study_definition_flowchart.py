from cohortextractor import (
    StudyDefinition,
    patients,
)
from codelists import *
from common_variables import common_variables

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.05,
    },
    index_date="2020-01-01",
    population=patients.all(),
        # has_follow_up AND
        # (age >=18 AND age <= 110) AND
        # (NOT died) AND
        # (sex = 'M' OR sex = 'F') AND
        # (stp != 'missing') AND
        # (imd != 0) AND
        # (household>=1 AND household<=15) 
        
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
    died=patients.died_from_any_cause(
            on_or_before="index_date"
        ),
    # Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.5, "U": 0.01}},
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
        return_expectations={"int" : {"distribution": "normal", "mean": 25, "stddev": 5}, "incidence" : 0.5}
    ),
    imd=patients.categorised_as(
        {
        "0": "DEFAULT",
        "1": """index_of_multiple_deprivation >=0 AND index_of_multiple_deprivation < 32844*1/5 AND has_msoa""",
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
        has_msoa=patients.satisfying(
        "NOT (msoa = '')",
            msoa=patients.address_as_of(
            "index_date",
            returning="msoa",
            return_expectations={"incidence": 0.95},
            ),
        ),
    ),
    )