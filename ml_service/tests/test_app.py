"""
Tests for the prediction service.

    pip install -r requirements-dev.txt
    python -m pytest -q

Besides the API contract, each disease gets a sanity check: a textbook
high-risk profile must score higher than a textbook low-risk one. A model that
had its labels the wrong way round would fail this immediately.
"""
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import app  # noqa: E402
from diseases import DISEASES  # noqa: E402

client = TestClient(app)

PROFILES = {
    "diabetes": (
        {"pregnancies": 1, "glucose": 85, "bloodPressure": 66, "bmi": 22.0, "age": 24},
        {"pregnancies": 6, "glucose": 190, "bloodPressure": 85, "bmi": 38.5, "age": 52,
         "insulin": 300, "diabetesPedigree": 1.2},
    ),
    "heart": (
        {"age": 35, "sex": "female", "chestPain": "nonAnginal", "restingBloodPressure": 115,
         "cholesterol": 180, "highFastingSugar": "no", "maxHeartRate": 180, "exerciseAngina": "no",
         "stDepression": 0, "stSlope": "up", "majorVessels": 0, "thalassemia": "normal"},
        {"age": 64, "sex": "male", "chestPain": "none", "restingBloodPressure": 160,
         "cholesterol": 300, "highFastingSugar": "yes", "maxHeartRate": 110, "exerciseAngina": "yes",
         "stDepression": 3.0, "stSlope": "flat", "majorVessels": 3, "thalassemia": "reversible"},
    ),
    "liver": (
        {"age": 30, "gender": "female", "totalBilirubin": 0.6, "alkalinePhosphatase": 150,
         "alt": 18, "ast": 20, "albumin": 4.2},
        {"age": 55, "gender": "male", "totalBilirubin": 8.0, "alkalinePhosphatase": 700,
         "alt": 400, "ast": 600, "albumin": 2.2, "directBilirubin": 4.0},
    ),
    "kidney": (
        {"age": 40, "bloodPressure": 70, "serumCreatinine": 0.9, "hemoglobin": 15.5,
         "hypertension": "no", "diabetes": "no", "specificGravity": "1.025", "urineAlbumin": "0"},
        {"age": 62, "bloodPressure": 100, "serumCreatinine": 6.5, "hemoglobin": 8.5,
         "hypertension": "yes", "diabetes": "yes", "specificGravity": "1.010", "urineAlbumin": "4"},
    ),
    "stroke": (
        {"gender": "female", "age": 28, "hypertension": "no", "heartDisease": "no",
         "avgGlucose": 85, "bmi": 22, "smokingStatus": "never"},
        {"gender": "male", "age": 79, "hypertension": "yes", "heartDisease": "yes",
         "avgGlucose": 230, "bmi": 31, "smokingStatus": "current"},
    ),
    "hypertension": (
        {"sex": "female", "age": 32, "bmi": 21.5, "currentSmoker": "no", "diabetes": "no",
         "heartRate": 65, "glucose": 80},
        {"sex": "male", "age": 66, "bmi": 36.0, "currentSmoker": "yes", "diabetes": "yes",
         "cigarettesPerDay": 20, "heartRate": 95, "glucose": 180, "totalCholesterol": 290},
    ),
}


def predict(key, inputs):
    return client.post(f"/predict/{key}", json={"inputs": inputs})


def test_health_lists_all_six_models():
    body = client.get("/health").json()
    assert body["status"] == "ok"
    assert set(body["models"]) == set(DISEASES)


def test_models_describe_fields_without_internal_columns():
    data = client.get("/models").json()["data"]
    assert [d["key"] for d in data] == list(DISEASES)
    for disease in data:
        assert disease["metrics"]["rocAuc"] > 0.7
        for feature in disease["features"]:
            assert "column" not in feature  # dataset internals stay on the server
            if feature["kind"] == "select":
                assert all(set(o) == {"value", "label"} for o in feature["options"])


@pytest.mark.parametrize("key", list(DISEASES))
def test_high_risk_profile_scores_above_low_risk(key):
    low, high = PROFILES[key]
    low_body, high_body = predict(key, low).json(), predict(key, high).json()
    assert high_body["probability"] > low_body["probability"], (low_body, high_body)
    assert high_body["riskLevel"] == "High", high_body
    assert low_body["riskLevel"] == "Low", low_body


@pytest.mark.parametrize("key", list(DISEASES))
def test_response_shape(key):
    body = predict(key, PROFILES[key][1]).json()
    assert body["disease"] == DISEASES[key]["name"]
    assert body["riskLevel"] in {"Low", "Moderate", "High"}
    assert 0 <= body["probability"] <= 1
    assert body["confidence"] == round(body["probability"] * 100)
    assert body["result"].startswith(body["riskLevel"])
    assert "not a diagnosis" in body["disclaimer"]


def test_optional_fields_can_be_left_out():
    minimal = {f["name"]: PROFILES["heart"][1][f["name"]]
               for f in DISEASES["heart"]["features"] if f["required"]}
    assert predict("heart", minimal).status_code == 200


def test_blank_strings_count_as_missing():
    inputs = dict(PROFILES["diabetes"][0], insulin="", skinThickness=" ")
    assert predict("diabetes", inputs).status_code == 200


def test_missing_required_field_is_named():
    inputs = dict(PROFILES["diabetes"][0])
    del inputs["glucose"]
    response = predict("diabetes", inputs)
    assert response.status_code == 422
    assert "Glucose" in response.json()["message"]


def test_out_of_range_value_is_rejected():
    response = predict("diabetes", dict(PROFILES["diabetes"][0], age=400))
    assert response.status_code == 422
    assert "between" in response.json()["message"]


def test_non_numeric_value_is_rejected():
    response = predict("diabetes", dict(PROFILES["diabetes"][0], bmi="tall"))
    assert response.status_code == 422


def test_unknown_select_option_is_rejected():
    response = predict("stroke", dict(PROFILES["stroke"][0], smokingStatus="sometimes"))
    assert response.status_code == 422
    assert "one of" in response.json()["message"]


def test_numbers_sent_as_strings_are_accepted():
    inputs = {k: str(v) for k, v in PROFILES["diabetes"][0].items()}
    assert predict("diabetes", inputs).status_code == 200


def test_unknown_disease_is_404():
    response = predict("flu", {})
    assert response.status_code == 404
    assert "message" in response.json()
