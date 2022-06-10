# Creates study population with no restirctions for mortality outcomes
from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    combine_codelists,
    filter_codes_by_category,
)
from codelists import *

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
    ocd_icd_codes,
    suicide_icd_codes
)
study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.05,
    },
    # Update index date to 2018-03-01 when ready to run on full dataset
    index_date="2019-02-01",
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
    # Mortality - Diabetes - currently only have DM keto codes
    keto_mortality=patients.with_these_codes_on_death_certificate(
        dm_keto_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        match_only_underlying_cause=True,
        returning="binary_flag",
    ),
    # Each CVD outcome
    stroke_mortality = patients.with_these_codes_on_death_certificate(
    stroke_icd_codes,
    between=["index_date", "last_day_of_month(index_date)"],
    match_only_underlying_cause=True,
    returning="binary_flag",
    ),
    vte_mortality = patients.with_these_codes_on_death_certificate(
    vte_icd_codes,
    between=["index_date", "last_day_of_month(index_date)"],
    match_only_underlying_cause=True,
    returning="binary_flag",
    ),
    mi_mortality = patients.with_these_codes_on_death_certificate(
    filter_codes_by_category(mi_icd_codes, include=["1"]),
    between=["index_date", "last_day_of_month(index_date)"],
    match_only_underlying_cause=True,
    returning="binary_flag",
    ),
    heart_failure_mortality = patients.with_these_codes_on_death_certificate(
    filter_codes_by_category(heart_failure_icd_codes, include=["1"]),
    between=["index_date", "last_day_of_month(index_date)"],
    match_only_underlying_cause=True,
    returning="binary_flag",
    ),

    # Mortality CVD
    cvd_mortality=patients.satisfying(
        """
        stroke_mortality OR
        vte_mortality OR
        mi_mortality OR
        heart_failure_mortality
        """,
    ),
    # Mortality respiratory disease - asthma and COPD
    resp_mortality=patients.with_these_codes_on_death_certificate(
        all_resp_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        match_only_underlying_cause=True,
        returning="binary_flag",
    ),
    asthma_mortality=patients.with_these_codes_on_death_certificate(
        asthma_exacerbation_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        match_only_underlying_cause=True,
        returning="binary_flag",
    ),
    copd_exac_mortality=patients.with_these_codes_on_death_certificate(
        copd_exacerbation_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        match_only_underlying_cause=True,
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    copd_diag_mortality=patients.with_these_codes_on_death_certificate(
        copd_icd_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        match_only_underlying_cause=True,
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    copd_mortality=patients.satisfying(
        """copd_exac_mortality OR 
        copd_diag_mortality """,
        ),
    # Mortality - mental health conditions - combined as unlikely to die 
    # specifically of anxiety for example.. 
    mh_mortality=patients.with_these_codes_on_death_certificate(
        all_mh_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        match_only_underlying_cause=True,
        returning="binary_flag",
    ),
    # All-cause mortality
    all_cause_mortality=patients.died_from_any_cause(
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
    ),
)
# Currently rates all for general population - not any subpopulations..
measures = [
    Measure(
        id="keto_mortality_ethnic_rate",
        numerator="keto_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="cvd_mortality_ethnic_rate",
        numerator="cvd_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="resp_mortality_ethnic_rate",
        numerator="resp_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="mh_mortality_ethnic_rate",
        numerator="mh_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="mi_mortality_ethnic_rate",
        numerator="mi_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="stroke_mortality_ethnic_rate",
        numerator="stroke_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="heart_failure_mortality_ethnic_rate",
        numerator="heart_failure_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="vte_mortality_ethnic_rate",
        numerator="vte_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="asthma_mortality_ethnic_rate",
        numerator="asthma_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="copd_mortality_ethnic_rate",
        numerator="copd_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="all_cause_mortality_ethnic_rate",
        numerator="all_cause_mortality",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="keto_mortality_imd_rate",
        numerator="keto_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="cvd_mortality_imd_rate",
        numerator="cvd_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="resp_mortality_imd_rate",
        numerator="resp_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="mh_mortality_imd_rate",
        numerator="mh_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="mi_mortality_imd_rate",
        numerator="mi_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="stroke_mortality_imd_rate",
        numerator="stroke_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="heart_failure_mortality_imd_rate",
        numerator="heart_failure_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="vte_mortality_imd_rate",
        numerator="vte_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="asthma_mortality_imd_rate",
        numerator="asthma_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="copd_mortality_imd_rate",
        numerator="copd_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    Measure(
        id="all_cause_mortality_imd_rate",
        numerator="all_cause_mortality",
        denominator="population",
        group_by=["imd"],
    ),
    ]