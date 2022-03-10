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
    # Clinical monitoring
    # asthma
    asthma_review=patients.with_these_clinical_events(
        codelist=asthma_review_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # COPD
    copd_review=patients.with_these_clinical_events(
        codelist=copd_review_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # CVD risk assessment
    cvd_risk=patients.with_these_clinical_events(
        codelist=qrisk_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Thyroid stimulating hormone
    tsh=patients.with_these_clinical_events(
        codelist=tsh_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Liver function test - ALT
    alt=patients.with_these_clinical_events(
        codelist=alt_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Cholesterol
    cholesterol=patients.with_these_clinical_events(
        codelist=cholesterol_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Hba1c
    hba1c=patients.with_these_clinical_events(
        codelist=hba1c_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Full blood count - red blood cells
    rbc=patients.with_these_clinical_events(
        codelist=rbc_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # sodium
    sodium=patients.with_these_clinical_events(
        codelist=sodium_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
    # Systolic blood pressure
    systolic_bp=patients.with_these_clinical_events(
        codelist=systolic_bp_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1},
        ),
)

measures = [
    Measure(
        id="asthma_review_rate",
        numerator="asthma_review",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="copd_review_rate",
        numerator="copd_review",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="cvd_risk_rate",
        numerator="cvd_risk",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="tsh_rate",
        numerator="tsh",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="alt_rate",
        numerator="alt",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="cholesterol_rate",
        numerator="cholesterol",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="hba1c_rate",
        numerator="hba1c",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="rbc_rate",
        numerator="rbc",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="sodium_rate",
        numerator="sodium",
        denominator="population",
        group_by=["ethnicity"],
    ),
    Measure(
        id="systolic_bp_rate",
        numerator="systolic_bp",
        denominator="population",
        group_by=["ethnicity"],
    ),
]