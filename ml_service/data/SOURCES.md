# Datasets

All six are public research datasets, used here for an academic project. Each
file was downloaded from the GitHub mirror listed below; where a second
independent mirror existed, the two copies were compared and found identical.
Line endings were normalised to `\n`; no values were changed. Cleaning (for
example treating a zero glucose reading as "not measured") happens in code, in
`diseases.py`, so the raw files stay as published.

| File | Dataset | Original source | Mirror used | Rows | Target |
|---|---|---|---|---|---|
| `diabetes.csv` | Pima Indians Diabetes Database | National Institute of Diabetes and Digestive and Kidney Diseases, via the UCI Machine Learning Repository | `github.com/plotly/datasets` | 768 | `Outcome` (1 = diabetes) |
| `heart.csv` | Cleveland Heart Disease | UCI Machine Learning Repository (Detrano et al., 1989) | `github.com/rashida048/Datasets` (`Heart.csv`) | 303 | `AHD` (Yes = disease) |
| `liver.csv` | Indian Liver Patient Dataset (ILPD) | UCI Machine Learning Repository (Ramana et al., 2012) | `github.com/lamavar/liver-disease-prediction`, checked against `github.com/gileno/pyne2018` | 583 | `Dataset` (1 = liver patient) |
| `kidney.csv` | Chronic Kidney Disease | UCI Machine Learning Repository (Rubini & Soundarapandian, 2015) | `github.com/ap-atul/chronic-kidney-disease` | 400 | `classification` (ckd) |
| `stroke.csv` | Stroke Prediction Dataset | Kaggle, published by fedesoriano | `github.com/darshchaurasia/stroke-prediction-dataset`, checked against two further mirrors | 5,110 | `stroke` (1 = stroke) |
| `framingham.csv` | Framingham Heart Study (teaching subset) | Framingham Heart Study, as distributed for teaching | `github.com/GauravPadawe/Framingham-Heart-Study`, checked against `github.com/TarekDib03/Analytics` | 4,240 | `prevalentHyp` (1 = hypertension) |

## Notes on the choices

- **Heart disease** uses the original Cleveland labels. A widely shared Kaggle
  copy (`heart.csv` with a `target` column) is avoided because its target is
  reported to be inverted relative to the original data.
- **Hypertension** is predicted from age, BMI, smoking, diabetes and blood
  tests. Systolic and diastolic blood pressure and blood-pressure medication
  are deliberately excluded: they define hypertension, so including them would
  make the model trivially "accurate" and useless as a risk estimate.
- **Stroke** uses clinical inputs only. The dataset's marital status, work type
  and residence columns are left out of the form.
