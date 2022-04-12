# Creating script for common variables: age, gender, ethnicity & IMD
from cohortextractor import patients
from codelists import *

common_variables = dict(
        # Age
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
        # Subgroups
        diabetes_subgroup=patients.satisfying(
            """
            has_t1_diabetes OR 
            has_t2_diabetes
            """,
            has_t1_diabetes=patients.with_these_clinical_events(
            t1dm_codes,
            on_or_before="index_date",
            returning="binary_flag",
            return_expectations={"incidence":0.2,}
            ),
            has_t2_diabetes=patients.with_these_clinical_events(
            t2dm_codes,
            on_or_before="index_date",
            returning="binary_flag",
            return_expectations={"incidence":0.8,}
            ),
        ),
        cvd_subgroup=patients.satisfying(
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
        resp_subgroup=patients.satisfying(
            """
            has_asthma OR
            has_copd""",
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
        mh_subgroup=patients.with_these_clinical_events(
        severe_mental_illness_codes,
        returning="binary_flag",
        on_or_before="index_date",
        return_expectations={"incidence": 0.2},
        ),
    ),
)