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
        region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and the Humber": 0.1,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East of England": 0.1,
                    "London": 0.2,
                    "South East": 0.2,
                    },
                },
            },
        ),
    ### PRIMIS overall flag for shielded group
    shielded=patients.satisfying(
            """ severely_clinically_vulnerable
            AND NOT less_vulnerable""", 
        return_expectations={
            "incidence": 0.01,
                },

            ### SHIELDED GROUP - first flag all patients with "high risk" codes
        severely_clinically_vulnerable=patients.with_these_clinical_events(
            high_risk_codes, # note no date limits set
            find_last_match_in_period = True,
            return_expectations={"incidence": 0.02,},
        ),

        # find date at which the high risk code was added
        date_severely_clinically_vulnerable=patients.date_of(
            "severely_clinically_vulnerable", 
            date_format="YYYY-MM-DD",   
        ),

        ### NOT SHIELDED GROUP (medium and low risk) - only flag if later than 'shielded'
        less_vulnerable=patients.with_these_clinical_events(
            not_high_risk_codes, 
            on_or_after="date_severely_clinically_vulnerable",
            return_expectations={"incidence": 0.01,},
            ),
        ),
        # Subgroups
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
        diabetes_subgroup=patients.satisfying(
            """
            has_t1_diabetes OR 
            has_t2_diabetes
            """,
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
        resp_subgroup=patients.satisfying(
                """
                has_asthma OR
                has_copd""",
        ),
        mh_subgroup=patients.with_these_clinical_events(
        severe_mental_illness_codes,
        returning="binary_flag",
        on_or_before="index_date",
        return_expectations={"incidence": 0.2},
            ),
        urban_rural=patients.address_as_of(
            "index_date",
            returning="rural_urban_classification",
            return_expectations={
            "rate": "universal",
            "category": 
                {"ratios": {
                    "1": 0.1,
                    "2": 0.1,
                    "3": 0.1,
                    "4": 0.1,
                    "5": 0.1,
                    "6": 0.1,
                    "7": 0.2,
                    "8": 0.2,
                    }
                },
            },
        ),
)
