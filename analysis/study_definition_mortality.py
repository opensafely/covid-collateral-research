# Creates study population with no restirctions for mortality outcomes
from math import comb
from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    combine_codelists
)
from codelists import *
# Combine CVD codelists - MI, stroke, heart failure and vte
stroke_vte_codes = combine_codelists(
    stroke_icd_codes,
    vte_icd_codes
)
# Combine asthma and COPD codelists
all_resp_codes = combine_codelists(
    asthma_exacerbation_icd_codes,
    copd_icd_codes
)
# Combine mental health codelists
all_mh_codes = combine_codelists(
    depression_icd_codes,
    anxiety_icd_codes,
    severe_mental_illness_icd_codes,
    self_harm_icd_codes,
    eating_disorder_icd_codes,
    ocd_icd_codes
)
study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.05,
    },
    # Update index date to 2018-03-01 when ready to run on full dataset
    index_date="2020-03-01",
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
    # Mortality - Diabetes - currently only have DM keto codes
    dm_mortality=patients.with_these_codes_on_death_certificate(
        dm_keto_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
    ),
    # Mortality CVD
    cvd_mortality=patients.satisfying(
        """
        stroke_vte_mortality OR
        mi_mortality OR
        heart_failure_mortality
        """,
        stroke_vte_mortality = patients.with_these_codes_on_death_certificate(
        stroke_vte_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        ),
        mi_mortality = patients.with_these_codes_on_death_certificate(
        mi_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        ),
        heart_failure_mortality = patients.with_these_codes_on_death_certificate(
        heart_failure_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        ),
    ),
    # Mortality respiratory disease - asthma and COPD
    resp_mortality=patients.with_these_codes_on_death_certificate(
        all_resp_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
    ),
    # Mortality - mental health conditions
    mh_mortality=patients.with_these_codes_on_death_certificate(
        all_mh_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
    ),
)

measures = [
    Measure(
        id="dm_mortality_rate",
        numerator="dm_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="cvd_mortality_rate",
        numerator="cvd_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="resp_mortality_rate",
        numerator="resp_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="mh_mortality_rate",
        numerator="mh_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="dm_mortality_rate",
        numerator="dm_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="cvd_mortality_rate",
        numerator="cvd_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="resp_mortality_rate",
        numerator="resp_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="mh_mortality_rate",
        numerator="mh_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    ]