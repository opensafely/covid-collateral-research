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
    index_date="2019-01-01",
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
    ),
    household=patients.household_as_of(
            "2020-02-01",
            returning="household_size",
            return_expectations={"int" : {"distribution": "normal", "mean": 25, "stddev": 5}, "incidence" : 0.5}
        ),
    care_home=patients.satisfying(
        """care_home_type!="PR" """,

        care_home_type=patients.care_home_status_as_of(
                "index_date",
                categorised_as={
                    "PC":
                    """
                    IsPotentialCareHome
                    AND LocationDoesNotRequireNursing='Y'
                    AND LocationRequiresNursing='N'
                    """,
                    "PN":
                    """
                    IsPotentialCareHome
                    AND LocationDoesNotRequireNursing='N'
                    AND LocationRequiresNursing='Y'
                    """,
                    "PS": "IsPotentialCareHome",
                    "PR": "NOT IsPotentialCareHome",
                    "": "DEFAULT",
                },
                return_expectations={
                    "rate": "universal",
                    "category": {"ratios": {"PC": 0.05, "PN": 0.05, "PS": 0.05, "PR": 0.84, "": 0.01},},
                },
            ),
    ),
    **common_variables
)