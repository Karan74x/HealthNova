"""
Train the six disease-risk models.

    python train.py

For each disease:
  1. Hold out 20% of the data as a test set the models never see while training.
  2. Compare three candidate models on the remaining 80% with 5-fold
     cross-validation, scored by ROC-AUC.
  3. Evaluate the winner once on the held-out test set. Those are the numbers
     reported in models/metrics.json.
  4. Refit the winner on all of the data and save it for the API.

Every model is a scikit-learn Pipeline, so missing-value imputation, scaling and
one-hot encoding are part of the saved model and are applied identically at
prediction time.
"""
import json
import time
from datetime import datetime, timezone
from pathlib import Path

import joblib
import numpy as np
import sklearn
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import HistGradientBoostingClassifier, RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score, confusion_matrix, f1_score, precision_score, recall_score, roc_auc_score,
)
from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import FunctionTransformer, OneHotEncoder, StandardScaler

from diseases import DISEASES, categorical_columns, feature_columns, numeric_columns

MODEL_DIR = Path(__file__).resolve().parent / "models"
RANDOM_STATE = 42


def preprocessor(key):
    spec = DISEASES[key]
    numeric = numeric_columns(key)
    categorical = categorical_columns(key)
    logged = [c for c in spec["log_columns"] if c in numeric]
    plain = [c for c in numeric if c not in logged]

    transformers = []
    if plain:
        transformers.append(("numeric", Pipeline([
            ("impute", SimpleImputer(strategy="median")),
            ("scale", StandardScaler()),
        ]), plain))
    if logged:
        # Lab values such as enzymes are heavily skewed; a log keeps a handful
        # of extreme readings from dominating the linear model.
        transformers.append(("skewed", Pipeline([
            ("impute", SimpleImputer(strategy="median")),
            ("log", FunctionTransformer(np.log1p, feature_names_out="one-to-one")),
            ("scale", StandardScaler()),
        ]), logged))
    if categorical:
        transformers.append(("categorical", Pipeline([
            ("impute", SimpleImputer(strategy="most_frequent")),
            ("encode", OneHotEncoder(handle_unknown="ignore")),
        ]), categorical))
    return ColumnTransformer(transformers)


def candidates(key):
    # class_weight="balanced" stops the rarer outcome (stroke is ~5% of its
    # dataset) from being ignored in favour of always predicting "no".
    return {
        "logistic_regression": Pipeline([
            ("prep", preprocessor(key)),
            ("model", LogisticRegression(max_iter=5000, class_weight="balanced")),
        ]),
        "random_forest": Pipeline([
            ("prep", preprocessor(key)),
            ("model", RandomForestClassifier(
                n_estimators=300, min_samples_leaf=4, class_weight="balanced",
                random_state=RANDOM_STATE, n_jobs=-1)),
        ]),
        "gradient_boosting": Pipeline([
            ("prep", preprocessor(key)),
            ("model", HistGradientBoostingClassifier(
                learning_rate=0.05, max_iter=200, max_leaf_nodes=15, l2_regularization=1.0,
                class_weight="balanced", random_state=RANDOM_STATE)),
        ]),
    }


def evaluate(model, X_test, y_test):
    probability = model.predict_proba(X_test)[:, 1]
    predicted = (probability >= 0.5).astype(int)
    tn, fp, fn, tp = confusion_matrix(y_test, predicted, labels=[0, 1]).ravel()
    return {
        "rocAuc": round(float(roc_auc_score(y_test, probability)), 3),
        "accuracy": round(float(accuracy_score(y_test, predicted)), 3),
        "sensitivity": round(float(recall_score(y_test, predicted, zero_division=0)), 3),
        "specificity": round(float(tn / (tn + fp)) if (tn + fp) else 0.0, 3),
        "precision": round(float(precision_score(y_test, predicted, zero_division=0)), 3),
        "f1": round(float(f1_score(y_test, predicted, zero_division=0)), 3),
        "confusionMatrix": {"tn": int(tn), "fp": int(fp), "fn": int(fn), "tp": int(tp)},
    }


def train_one(key):
    spec = DISEASES[key]
    X, y = spec["loader"]()
    X = X[feature_columns(key)]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, stratify=y, random_state=RANDOM_STATE)

    folds = StratifiedKFold(n_splits=5, shuffle=True, random_state=RANDOM_STATE)
    cv_scores = {}
    for name, pipeline in candidates(key).items():
        scores = cross_val_score(pipeline, X_train, y_train, cv=folds, scoring="roc_auc")
        cv_scores[name] = {"mean": round(float(scores.mean()), 3), "std": round(float(scores.std()), 3)}

    best = max(cv_scores, key=lambda name: cv_scores[name]["mean"])

    held_out = candidates(key)[best].fit(X_train, y_train)
    test_metrics = evaluate(held_out, X_test, y_test)

    final = candidates(key)[best].fit(X, y)
    joblib.dump({"key": key, "model": final, "columns": feature_columns(key)},
                MODEL_DIR / f"{key}.joblib")

    return {
        "name": spec["name"],
        "dataset": spec["dataset"],
        "rows": int(len(X)),
        "positiveRate": round(float(y.mean()), 3),
        "trainRows": int(len(X_train)),
        "testRows": int(len(X_test)),
        "selectedModel": best,
        "crossValidationRocAuc": cv_scores,
        "testSet": test_metrics,
        "features": [feature["name"] for feature in spec["features"]],
    }


def train_all(verbose=True):
    MODEL_DIR.mkdir(exist_ok=True)
    started = time.time()
    report = {
        "trainedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "sklearnVersion": sklearn.__version__,
        "randomState": RANDOM_STATE,
        "models": {},
    }
    for key in DISEASES:
        if verbose:
            print(f"training {key} ...", flush=True)
        report["models"][key] = train_one(key)
        if verbose:
            m = report["models"][key]
            print(f"  {m['selectedModel']:20s} test ROC-AUC {m['testSet']['rocAuc']:.3f}  "
                  f"accuracy {m['testSet']['accuracy']:.3f}", flush=True)
    report["trainingSeconds"] = round(time.time() - started, 1)
    (MODEL_DIR / "metrics.json").write_text(json.dumps(report, indent=2))
    if verbose:
        print(f"done in {report['trainingSeconds']}s -> {MODEL_DIR}")
    return report


if __name__ == "__main__":
    train_all()
