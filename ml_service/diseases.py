"""
The six disease-risk models, described in one place.

Both the trainer and the API read from this file, so the form fields the
mobile app shows, the validation the API applies and the columns the model was
trained on cannot drift apart.

Every feature has:
  name      the key the API accepts (camelCase, as the apps send it)
  column    the column it maps to in the training dataset
  kind      "number" or "select"
  required  optional fields are imputed when left blank
For a select, `options` maps each API value to the value used in the dataset.
"""
from pathlib import Path

import numpy as np
import pandas as pd

DATA_DIR = Path(__file__).resolve().parent / "data"

YES_NO = [
    {"value": "yes", "label": "Yes", "data": 1},
    {"value": "no", "label": "No", "data": 0},
]


def num(name, column, label, unit, minimum, maximum, required=True, step=1, help_text=""):
    return {
        "name": name, "column": column, "label": label, "kind": "number", "unit": unit,
        "min": minimum, "max": maximum, "step": step, "required": required, "help": help_text,
    }


def select(name, column, label, options, required=True, help_text=""):
    return {
        "name": name, "column": column, "label": label, "kind": "select",
        "options": options, "required": required, "help": help_text,
    }


# --------------------------------------------------------------------- loaders
# Each loader returns (features DataFrame using dataset column names, 0/1 target)


def load_diabetes():
    df = pd.read_csv(DATA_DIR / "diabetes.csv")
    # In this dataset a zero means "not measured" for these columns
    for column in ["Glucose", "BloodPressure", "SkinThickness", "Insulin", "BMI"]:
        df[column] = df[column].replace(0, np.nan)
    return df.drop(columns=["Outcome"]), df["Outcome"].astype(int)


def load_heart():
    df = pd.read_csv(DATA_DIR / "heart.csv").drop(columns=["Unnamed: 0"], errors="ignore")
    target = (df["AHD"].str.strip() == "Yes").astype(int)
    return df.drop(columns=["AHD"]), target


def load_liver():
    df = pd.read_csv(DATA_DIR / "liver.csv")
    # ILPD encodes 1 = liver patient, 2 = not a liver patient
    target = (df["Dataset"] == 1).astype(int)
    return df.drop(columns=["Dataset"]), target


def load_kidney():
    df = pd.read_csv(DATA_DIR / "kidney.csv")
    # The raw file has stray tabs and "?" for missing values
    for column in df.columns:
        if df[column].dtype == object:
            df[column] = df[column].astype(str).str.strip().replace({"?": np.nan, "nan": np.nan})
    for column in ["age", "bp", "sg", "al", "su", "bgr", "bu", "sc", "hemo"]:
        df[column] = pd.to_numeric(df[column], errors="coerce")
    target = (df["classification"] == "ckd").astype(int)
    return df.drop(columns=["classification", "id"]), target


def load_stroke():
    df = pd.read_csv(DATA_DIR / "stroke.csv")
    df = df[df["gender"] != "Other"]  # a single row; too few to learn from
    return df.drop(columns=["stroke", "id"]), df["stroke"].astype(int)


def load_hypertension():
    df = pd.read_csv(DATA_DIR / "framingham.csv")
    return df.drop(columns=["prevalentHyp"]), df["prevalentHyp"].astype(int)


# ------------------------------------------------------------------- diseases

DISEASES = {
    "diabetes": {
        "name": "Diabetes",
        "description": "Estimates the risk of type 2 diabetes from glucose, blood pressure, BMI and age.",
        "dataset": "Pima Indians Diabetes Database (NIDDK, via UCI). 768 adult women.",
        "loader": load_diabetes,
        "log_columns": ["Insulin", "DiabetesPedigreeFunction"],
        "features": [
            num("pregnancies", "Pregnancies", "Number of pregnancies", "", 0, 20,
                help_text="Enter 0 if none or not applicable."),
            num("glucose", "Glucose", "Glucose (2-hour test)", "mg/dL", 40, 300),
            num("bloodPressure", "BloodPressure", "Blood pressure (lower number)", "mm Hg", 30, 140,
                help_text="The diastolic value, e.g. 80 in 120/80."),
            num("bmi", "BMI", "BMI", "kg/m²", 10, 70, step=0.1),
            num("age", "Age", "Age", "years", 1, 120),
            num("skinThickness", "SkinThickness", "Skin fold thickness", "mm", 5, 100, required=False),
            num("insulin", "Insulin", "Insulin (2-hour)", "µU/mL", 10, 900, required=False),
            num("diabetesPedigree", "DiabetesPedigreeFunction", "Family history score", "", 0.05, 2.5,
                required=False, step=0.01,
                help_text="Diabetes pedigree function. Leave blank if unknown."),
        ],
    },
    "heart": {
        "name": "Heart Disease",
        "description": "Estimates the risk of coronary heart disease from vital signs, symptoms and test results.",
        "dataset": "Cleveland Heart Disease data (UCI). 303 patients.",
        "loader": load_heart,
        "log_columns": [],
        "features": [
            num("age", "Age", "Age", "years", 1, 120),
            select("sex", "Sex", "Sex", [
                {"value": "male", "label": "Male", "data": 1},
                {"value": "female", "label": "Female", "data": 0},
            ]),
            select("chestPain", "ChestPain", "Chest pain type", [
                {"value": "typical", "label": "Typical angina", "data": "typical"},
                {"value": "atypical", "label": "Atypical angina", "data": "nontypical"},
                {"value": "nonAnginal", "label": "Non-anginal pain", "data": "nonanginal"},
                {"value": "none", "label": "No chest pain", "data": "asymptomatic"},
            ]),
            num("restingBloodPressure", "RestBP", "Resting blood pressure (upper number)", "mm Hg", 80, 220),
            num("cholesterol", "Chol", "Cholesterol", "mg/dL", 100, 600),
            select("highFastingSugar", "Fbs", "Fasting blood sugar above 120 mg/dL", YES_NO),
            select("restingEcg", "RestECG", "Resting ECG result", [
                {"value": "normal", "label": "Normal", "data": 0},
                {"value": "stAbnormality", "label": "ST-T wave abnormality", "data": 1},
                {"value": "lvHypertrophy", "label": "Left ventricular hypertrophy", "data": 2},
            ], required=False),
            num("maxHeartRate", "MaxHR", "Maximum heart rate (stress test)", "bpm", 60, 220, required=False),
            select("exerciseAngina", "ExAng", "Chest pain during exercise", YES_NO, required=False),
            num("stDepression", "Oldpeak", "ST depression (stress test)", "mm", 0, 7, required=False, step=0.1),
            select("stSlope", "Slope", "ST segment slope", [
                {"value": "up", "label": "Upsloping", "data": 1},
                {"value": "flat", "label": "Flat", "data": 2},
                {"value": "down", "label": "Downsloping", "data": 3},
            ], required=False),
            num("majorVessels", "Ca", "Major vessels seen on fluoroscopy", "", 0, 3, required=False),
            select("thalassemia", "Thal", "Thallium stress test", [
                {"value": "normal", "label": "Normal", "data": "normal"},
                {"value": "fixed", "label": "Fixed defect", "data": "fixed"},
                {"value": "reversible", "label": "Reversible defect", "data": "reversable"},
            ], required=False),
        ],
    },
    "liver": {
        "name": "Liver Disease",
        "description": "Estimates the risk of liver disease from a liver function test (LFT) report.",
        "dataset": "Indian Liver Patient Dataset (ILPD, UCI). 583 patients.",
        "loader": load_liver,
        "log_columns": ["Total_Bilirubin", "Direct_Bilirubin", "Alkaline_Phosphotase",
                        "Alamine_Aminotransferase", "Aspartate_Aminotransferase"],
        "features": [
            num("age", "Age", "Age", "years", 1, 120),
            select("gender", "Gender", "Gender", [
                {"value": "male", "label": "Male", "data": "Male"},
                {"value": "female", "label": "Female", "data": "Female"},
            ]),
            num("totalBilirubin", "Total_Bilirubin", "Total bilirubin", "mg/dL", 0.1, 80, step=0.1),
            num("alkalinePhosphatase", "Alkaline_Phosphotase", "Alkaline phosphatase (ALP)", "IU/L", 20, 2500),
            num("alt", "Alamine_Aminotransferase", "ALT / SGPT", "IU/L", 5, 2500),
            num("ast", "Aspartate_Aminotransferase", "AST / SGOT", "IU/L", 5, 5000),
            num("albumin", "Albumin", "Albumin", "g/dL", 0.5, 6, step=0.1),
            num("directBilirubin", "Direct_Bilirubin", "Direct bilirubin", "mg/dL", 0, 40,
                required=False, step=0.1),
            num("totalProteins", "Total_Protiens", "Total proteins", "g/dL", 2, 10, required=False, step=0.1),
            num("agRatio", "Albumin_and_Globulin_Ratio", "Albumin/globulin ratio", "", 0.1, 3,
                required=False, step=0.01),
        ],
    },
    "kidney": {
        "name": "Kidney Disease",
        "description": "Estimates the risk of chronic kidney disease from blood and urine test results.",
        "dataset": "Chronic Kidney Disease dataset (UCI). 400 patients.",
        "loader": load_kidney,
        "log_columns": ["bgr", "bu", "sc"],
        "features": [
            num("age", "age", "Age", "years", 1, 120),
            num("bloodPressure", "bp", "Blood pressure (lower number)", "mm Hg", 40, 180),
            num("serumCreatinine", "sc", "Serum creatinine", "mg/dL", 0.2, 80, step=0.1),
            num("hemoglobin", "hemo", "Hemoglobin", "g/dL", 3, 20, step=0.1),
            select("hypertension", "htn", "Diagnosed with high blood pressure", [
                {"value": "yes", "label": "Yes", "data": "yes"},
                {"value": "no", "label": "No", "data": "no"},
            ]),
            select("diabetes", "dm", "Diagnosed with diabetes", [
                {"value": "yes", "label": "Yes", "data": "yes"},
                {"value": "no", "label": "No", "data": "no"},
            ]),
            num("bloodUrea", "bu", "Blood urea", "mg/dL", 1, 400, required=False),
            num("bloodGlucose", "bgr", "Blood glucose (random)", "mg/dL", 20, 500, required=False),
            select("specificGravity", "sg", "Urine specific gravity", [
                {"value": v, "label": v, "data": float(v)}
                for v in ["1.005", "1.010", "1.015", "1.020", "1.025"]
            ], required=False),
            select("urineAlbumin", "al", "Urine albumin level", [
                {"value": str(v), "label": str(v), "data": v} for v in range(6)
            ], required=False, help_text="0 to 5, from a urine dipstick test."),
            select("appetite", "appet", "Appetite", [
                {"value": "good", "label": "Good", "data": "good"},
                {"value": "poor", "label": "Poor", "data": "poor"},
            ], required=False),
            select("pedalEdema", "pe", "Swelling in the feet", [
                {"value": "yes", "label": "Yes", "data": "yes"},
                {"value": "no", "label": "No", "data": "no"},
            ], required=False),
            select("anemia", "ane", "Diagnosed with anemia", [
                {"value": "yes", "label": "Yes", "data": "yes"},
                {"value": "no", "label": "No", "data": "no"},
            ], required=False),
        ],
    },
    "stroke": {
        "name": "Stroke",
        "description": "Estimates the risk of stroke from age, medical history, glucose and BMI.",
        "dataset": "Stroke Prediction dataset (Kaggle, fedesoriano). 5,110 people.",
        "loader": load_stroke,
        "log_columns": ["avg_glucose_level"],
        "features": [
            select("gender", "gender", "Gender", [
                {"value": "male", "label": "Male", "data": "Male"},
                {"value": "female", "label": "Female", "data": "Female"},
            ]),
            num("age", "age", "Age", "years", 1, 120),
            select("hypertension", "hypertension", "Diagnosed with high blood pressure", YES_NO),
            select("heartDisease", "heart_disease", "Diagnosed with heart disease", YES_NO),
            num("avgGlucose", "avg_glucose_level", "Average glucose level", "mg/dL", 40, 300, step=0.1),
            num("bmi", "bmi", "BMI", "kg/m²", 10, 70, required=False, step=0.1),
            select("smokingStatus", "smoking_status", "Smoking", [
                {"value": "never", "label": "Never smoked", "data": "never smoked"},
                {"value": "former", "label": "Used to smoke", "data": "formerly smoked"},
                {"value": "current", "label": "Smokes", "data": "smokes"},
                {"value": "unknown", "label": "Prefer not to say", "data": "Unknown"},
            ], required=False),
        ],
    },
    "hypertension": {
        "name": "Hypertension",
        "description": "Estimates the risk of high blood pressure from age, lifestyle and blood tests. "
                       "Blood pressure itself is deliberately not an input.",
        "dataset": "Framingham Heart Study teaching dataset. 4,240 participants.",
        "loader": load_hypertension,
        "log_columns": ["glucose"],
        "features": [
            select("sex", "male", "Sex", [
                {"value": "male", "label": "Male", "data": 1},
                {"value": "female", "label": "Female", "data": 0},
            ]),
            num("age", "age", "Age", "years", 18, 120),
            num("bmi", "BMI", "BMI", "kg/m²", 10, 70, step=0.1),
            select("currentSmoker", "currentSmoker", "Currently smokes", YES_NO),
            select("diabetes", "diabetes", "Diagnosed with diabetes", YES_NO),
            num("cigarettesPerDay", "cigsPerDay", "Cigarettes per day", "", 0, 70, required=False),
            num("totalCholesterol", "totChol", "Total cholesterol", "mg/dL", 100, 700, required=False),
            num("heartRate", "heartRate", "Resting heart rate", "bpm", 40, 150, required=False),
            num("glucose", "glucose", "Glucose", "mg/dL", 40, 400, required=False),
            select("previousStroke", "prevalentStroke", "Has had a stroke", YES_NO, required=False),
        ],
    },
}

# Probability bands used to describe a result
RISK_BANDS = [(0.65, "High"), (0.35, "Moderate"), (0.0, "Low")]

DISCLAIMER = (
    "This is a statistical estimate from a machine-learning model trained on a public "
    "research dataset. It is not a diagnosis. Please consult a doctor about your results."
)


def risk_level(probability):
    for threshold, label in RISK_BANDS:
        if probability >= threshold:
            return label
    return "Low"


def feature_columns(key):
    return [feature["column"] for feature in DISEASES[key]["features"]]


def numeric_columns(key):
    """Columns treated as numbers by the model.

    Selects whose stored values are numeric (yes/no as 1/0, ordinal levels) are
    numeric too; only selects with text values are one-hot encoded.
    """
    columns = []
    for feature in DISEASES[key]["features"]:
        if feature["kind"] == "number":
            columns.append(feature["column"])
        elif all(isinstance(option["data"], (int, float)) for option in feature["options"]):
            columns.append(feature["column"])
    return columns


def categorical_columns(key):
    numeric = set(numeric_columns(key))
    return [column for column in feature_columns(key) if column not in numeric]
