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
    index_date="2018-03-01",
    population=patients.all(),

    # Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.5, "U": 0.01}},
        },
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
)
       