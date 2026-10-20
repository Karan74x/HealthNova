# HealthNova – Prediction Service

Python service that estimates disease risk for the six conditions in the
HealthNova scope: diabetes, heart disease, liver disease, kidney disease,
stroke and hypertension. It is trained with scikit-learn on public research
datasets and served with FastAPI. The Node backend calls it; the mobile app and
dashboards never talk to it directly.

> Every result is a statistical estimate, not a diagnosis. Each response
> carries a disclaimer saying so, and the apps display it.

## Running it

Requires Python 3.10 or later.

```powershell
cd ml_service
python -m venv .venv
.venv\Scripts\activate          # macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
python app.py                   # http://127.0.0.1:8000
```

The trained models are included in `models/`. If they are missing, or were
saved by a different scikit-learn version than the one installed, the service
retrains them itself on start-up (about 30 seconds), so a fresh checkout works
without a separate step. To retrain on demand:

```powershell
python train.py
```

Run the tests with `pip install -r requirements-dev.txt` then `python -m pytest -q`.

## How the models are built

For each disease, `train.py`:

1. holds out 20% of the data as a test set that training never sees;
2. compares logistic regression, a random forest and gradient boosting on the
   other 80% with 5-fold cross-validation, scored by ROC-AUC;
3. evaluates the winner once on the held-out test set — the numbers below;
4. refits the winner on all the data and saves it.

Each model is a scikit-learn `Pipeline`, so median imputation of blank
optional fields, log-scaling of skewed lab values, standardisation and one-hot
encoding are part of the saved model and run identically at prediction time.
All candidates use balanced class weights, so a rare outcome such as stroke
(5% of its dataset) is not simply predicted as "no" every time.

## Results on the held-out test sets

| Disease | Model chosen | Test ROC-AUC | Accuracy | Sensitivity | Specificity | Test rows |
|---|---|---|---|---|---|---|
| Diabetes | Logistic regression | 0.811 | 0.734 | 0.722 | 0.740 | 154 |
| Heart Disease | Logistic regression | 0.958 | 0.869 | 0.929 | 0.818 | 61 |
| Liver Disease | Random forest | 0.792 | 0.726 | 0.771 | 0.618 | 117 |
| Kidney Disease | Logistic regression | 0.978 | 0.988 | 1.000 | 0.967 | 80 |
| Stroke | Logistic regression | 0.840 | 0.734 | 0.820 | 0.729 | 1022 |
| Hypertension | Logistic regression | 0.742 | 0.652 | 0.658 | 0.650 | 848 |

Full detail, including every candidate's cross-validation score and each
confusion matrix, is in `models/metrics.json`.

Read these honestly: heart and kidney score very well partly because their test
sets are small (61 and 80 rows), so one or two cases move the figures a lot.
Liver disease is genuinely hard to separate with this data, which matches the
published literature on ILPD. Hypertension is modest by design, because blood
pressure itself is excluded as an input (see `data/SOURCES.md`).

## Risk levels

The model's probability for the at-risk class is reported as:

| Probability | Risk level |
|---|---|
| 0.65 and above | High |
| 0.35 – 0.65 | Moderate |
| below 0.35 | Low |

Because the models are trained with balanced class weights, this probability is
a relative risk score rather than a calibrated population probability. It is
stored as `confidence` (0–100) in the backend's Prediction collection.

## API

| Method / Endpoint | Purpose |
|---|---|
| `GET /health` | Status and the loaded models |
| `GET /models` | Every disease with its form fields, units, ranges and test metrics |
| `POST /predict/{key}` | Body `{"inputs": {...}}`; returns `result`, `riskLevel`, `probability`, `confidence`, `disclaimer` |

Keys are `diabetes`, `heart`, `liver`, `kidney`, `stroke`, `hypertension`.

`GET /models` is what lets the mobile app build each prediction form without
hard-coding any fields: labels, units, allowed ranges, select options and
which fields are optional all come from `diseases.py`. Errors return
`{"message": "..."}` naming the field at fault, for example
`"Glucose (2-hour test) is required."`.

Example:

```bash
curl -X POST http://127.0.0.1:8000/predict/diabetes \
  -H "Content-Type: application/json" \
  -d '{"inputs": {"pregnancies": 2, "glucose": 148, "bloodPressure": 72, "bmi": 33.6, "age": 50}}'
```

## Files

| File | Purpose |
|---|---|
| `diseases.py` | Form fields, dataset mapping and cleaning for all six diseases |
| `train.py` | Model selection, evaluation and saving |
| `app.py` | The FastAPI service |
| `models/` | Saved models and `metrics.json` |
| `data/` | The six datasets and `SOURCES.md` |
| `tests/` | API and model sanity tests |

Configuration: `ML_HOST` (default `127.0.0.1`) and `ML_PORT` (default `8000`).
