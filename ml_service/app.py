"""
HealthNova disease-risk prediction service.

    python app.py            # serves on http://127.0.0.1:8000

Endpoints
  GET  /health            service status and which models are loaded
  GET  /models            every disease with its form fields and test metrics
  POST /predict/{key}     body {"inputs": {...}} -> risk level and probability

The Node backend is the only intended caller; the apps reach these endpoints
through it. On start-up the service trains the models itself if they are
missing or were saved by a different scikit-learn version, so it works on a
fresh checkout without a separate training step.
"""
import json
import math
import os
import warnings
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
import sklearn
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from diseases import DISCLAIMER, DISEASES, risk_level
from train import MODEL_DIR, train_all

METRICS_PATH = MODEL_DIR / "metrics.json"


def _same_minor(a, b):
    return a.split(".")[:2] == b.split(".")[:2]


def load_models():
    """Load saved models, retraining first when they are absent or stale."""
    metrics = None
    if METRICS_PATH.exists():
        metrics = json.loads(METRICS_PATH.read_text())
    missing = [k for k in DISEASES if not (MODEL_DIR / f"{k}.joblib").exists()]
    stale = metrics is None or not _same_minor(metrics.get("sklearnVersion", "0.0"), sklearn.__version__)

    if missing or stale:
        reason = "missing" if missing else (
            f"saved with scikit-learn {metrics.get('sklearnVersion')}, "
            f"installed is {sklearn.__version__}")
        print(f"models {reason}; training now (about a minute) ...", flush=True)
        metrics = train_all(verbose=True)

    try:
        return _read_models(), metrics
    except Exception as error:  # e.g. a pickle from an incompatible library version
        print(f"saved models could not be loaded ({error}); retraining ...", flush=True)
        metrics = train_all(verbose=True)
        return _read_models(), metrics


def _read_models():
    from sklearn.exceptions import InconsistentVersionWarning

    models = {}
    with warnings.catch_warnings():
        # A model saved by another scikit-learn version may load but predict
        # wrongly, so that one warning is treated as a failure to load.
        warnings.simplefilter("error", InconsistentVersionWarning)
        for key in DISEASES:
            models[key] = joblib.load(MODEL_DIR / f"{key}.joblib")
    return models


MODELS, METRICS = load_models()

app = FastAPI(title="HealthNova Prediction Service", version="1.0.0")


class PredictionRequest(BaseModel):
    inputs: dict


def public_feature(feature):
    """A feature as the client needs it: no dataset column names or encodings."""
    out = {k: v for k, v in feature.items() if k not in ("column", "options")}
    if feature["kind"] == "select":
        out["options"] = [{"value": o["value"], "label": o["label"]} for o in feature["options"]]
    return out


def describe(key):
    spec = DISEASES[key]
    m = METRICS["models"][key]
    return {
        "key": key,
        "name": spec["name"],
        "description": spec["description"],
        "dataset": spec["dataset"],
        "model": m["selectedModel"],
        "metrics": {
            "rocAuc": m["testSet"]["rocAuc"],
            "accuracy": m["testSet"]["accuracy"],
            "sensitivity": m["testSet"]["sensitivity"],
            "specificity": m["testSet"]["specificity"],
            "testRows": m["testRows"],
        },
        "features": [public_feature(f) for f in spec["features"]],
    }


def to_row(key, inputs):
    """Validate the submitted values and build the one-row frame the model expects.

    Raises HTTPException(422) with a message that names the offending field, so
    the app can show it next to the input.
    """
    row = {}
    for feature in DISEASES[key]["features"]:
        raw = inputs.get(feature["name"])
        blank = raw is None or (isinstance(raw, str) and raw.strip() == "")

        if blank:
            if feature["required"]:
                raise HTTPException(422, f"{feature['label']} is required.")
            row[feature["column"]] = np.nan
            continue

        if feature["kind"] == "number":
            try:
                value = float(raw)
            except (TypeError, ValueError):
                raise HTTPException(422, f"{feature['label']} must be a number.")
            if not math.isfinite(value) or not (feature["min"] <= value <= feature["max"]):
                unit = f" {feature['unit']}" if feature["unit"] else ""
                raise HTTPException(
                    422, f"{feature['label']} must be between {feature['min']} and {feature['max']}{unit}.")
            row[feature["column"]] = value
        else:
            match = next((o for o in feature["options"] if o["value"] == str(raw)), None)
            if match is None:
                allowed = ", ".join(o["value"] for o in feature["options"])
                raise HTTPException(422, f"{feature['label']} must be one of: {allowed}.")
            row[feature["column"]] = match["data"]

    frame = pd.DataFrame([row], columns=MODELS[key]["columns"])
    # Missing optional selects must be NaN in an object column, not a float one
    for column in frame.columns:
        if frame[column].isna().all():
            frame[column] = frame[column].astype(object)
    return frame


@app.exception_handler(HTTPException)
async def http_error(request, exc):
    # {"message": ...} matches the error shape the rest of HealthNova uses
    return JSONResponse(status_code=exc.status_code, content={"message": exc.detail})


@app.get("/health")
def health():
    return {"status": "ok", "models": list(MODELS), "sklearnVersion": sklearn.__version__,
            "trainedAt": METRICS.get("trainedAt")}


@app.get("/models")
def models():
    return {"data": [describe(key) for key in DISEASES]}


@app.post("/predict/{key}")
def predict(key: str, request: PredictionRequest):
    if key not in DISEASES:
        raise HTTPException(404, f"Unknown disease '{key}'. Use one of: {', '.join(DISEASES)}.")

    frame = to_row(key, request.inputs)
    probability = float(MODELS[key]["model"].predict_proba(frame)[0, 1])
    level = risk_level(probability)
    name = DISEASES[key]["name"]

    return {
        "key": key,
        "disease": name,
        "result": f"{level} risk of {name.lower()}",
        "riskLevel": level,
        "probability": round(probability, 4),
        "confidence": round(probability * 100),
        "model": METRICS["models"][key]["selectedModel"],
        "disclaimer": DISCLAIMER,
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host=os.environ.get("ML_HOST", "127.0.0.1"),
                port=int(os.environ.get("ML_PORT", "8000")))
