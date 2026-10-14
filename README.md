# HealthNova — Smart Healthcare Management System

HealthNova is a full-stack healthcare platform built as an MCA Semester 3 academic project. Patients use
a Flutter app to find doctors, book appointments and check their risk of six diseases with trained
machine-learning models. Administrators and doctors use a React web dashboard to manage doctors,
patients, appointments and results. Both talk to one Node.js + Express REST API backed by MongoDB, which
in turn calls a Python prediction service.

---

## Table of Contents

- [Team](#team)
- [What Works](#what-works)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Getting Started (Windows)](#getting-started-windows)
- [Demo Accounts](#demo-accounts)
- [Environment Variables](#environment-variables)
- [API Reference](#api-reference)
- [Disease-Risk Prediction](#disease-risk-prediction)
- [Roles and Authorization](#roles-and-authorization)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Branching and Workflow](#branching-and-workflow)

---

## Team

| Role | Member | Enrolment |
| --- | --- | --- |
| Backend and database | Karan Rahani | C37 |
| Flutter patient application | Mohammad Anas Qureshi | C34 |
| React Admin/Doctor dashboard | Harshrajsinh Zala | C49 |

**Institute:** LJ University — Master of Computer Applications (MCA), Semester 3, Academic Year 2026–27
**Group:** 12  **Faculty / Coordinator:** Ajay Chauhan Sir

---

## What Works

| Module | Features |
| --- | --- |
| **Authentication** | Register, login (email case-insensitive), bcrypt-hashed passwords, 7-day JWT sessions, role gates |
| **Patient app (Flutter)** | Sign up and log in with a saved session; browse and search doctors; book an appointment (date + time slot + reason); track status and cancel pending requests; run any of the six disease-risk checks and see the result and history; edit profile; log out |
| **Admin dashboard (React)** | Live statistics; add / edit / delete doctors (creates their login); search and remove patients, with each patient's prediction history; approve, reject, complete and delete appointments; review every prediction and the values entered; edit own profile |
| **Doctor dashboard (React)** | Today's figures; accept or decline new requests; today's schedule; all appointments with filters and details; patient list with visit history and the patient's risk checks; edit practice details (hospital, fee, experience, availability) and personal details |
| **Prediction service (Python)** | Six scikit-learn models trained on public clinical datasets — diabetes, heart disease, liver disease, kidney disease, stroke, hypertension — with input validation and a "not a diagnosis" disclaimer on every result |

---

## Architecture

```
 Flutter patient app ─┐
                      ├──► Node.js + Express API ──► MongoDB (Atlas)
 React web dashboard ─┘    (port 5000)        └───► Python prediction service
   admin + doctor                                   FastAPI + scikit-learn (port 8000)
```

- The apps only ever talk to the Express API. The API calls the prediction service, stores the result
  and returns it, so a stored prediction is always what the model produced.
- The prediction forms are not hard-coded in the app: `GET /api/patient/prediction-models` returns each
  disease's fields, units, ranges and options, and the Flutter app builds the form from that.

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Patient app | Flutter (Dart SDK ^3.12.2), `http`, `shared_preferences` |
| Web dashboard | React 19, Vite 6, React Router 7, Axios, Lucide React, plain CSS |
| Backend | Node.js 22, Express 5, Mongoose 9, bcryptjs, jsonwebtoken, cors |
| Database | MongoDB (Atlas M0 cluster) |
| Prediction service | Python 3.10+, FastAPI, scikit-learn, pandas |
| Tooling | Git, GitHub, nodemon, dotenv, pytest |

---

## Repository Structure

```
HealthNova/
├── backend/                      # Node.js + Express REST API
│   ├── server.js                 # Loads .env, connects to MongoDB, starts the server
│   ├── .env.example              # Copy to .env and fill in
│   ├── scripts/seed.js           # Demo data: npm run seed  (npm run seed -- --remove to undo)
│   ├── src/
│   │   ├── app.js                # Express app, CORS, routes, JSON 404 / error handling
│   │   ├── config/db.js
│   │   ├── controllers/          # auth, user, admin, doctor, patient
│   │   ├── middleware/           # authMiddleware (JWT), roleMiddleware (403)
│   │   ├── models/               # User, Doctor, Appointment, Prediction
│   │   ├── routes/               # /api/auth, /api/user, /api/admin, /api/doctor, /api/patient
│   │   └── services/predictionService.js   # Calls ml_service
│   └── test/                     # api.test.js (no DB needed), live.test.js (real DB)
│
├── ml_service/                   # Python prediction service (see its README)
│   ├── app.py                    # FastAPI: /health, /models, /predict/{disease}
│   ├── diseases.py               # The six diseases: fields, ranges, data cleaning
│   ├── train.py                  # Model selection and training
│   ├── data/                     # Public datasets + SOURCES.md
│   ├── models/                   # Trained models + metrics.json
│   └── tests/
│
├── admin_dashboard/              # React web app for administrators and doctors (see its README)
│   └── src/
│       ├── api/                  # axiosInstance, authApi, userApi, adminApi, doctorApi
│       ├── components/           # Sidebar, Header, DataTable, Modal, Toast, StatCard, …
│       ├── pages/                # AdminDashboard, DoctorDashboard, Profile, Login, …
│       │   ├── admin/            # Doctors, Patients, Appointments, Predictions
│       │   └── doctor/           # Appointments, Patients
│       └── styles/               # variables.css (design tokens from the Flutter app)
│
└── hospital/                     # Flutter patient app
    └── lib/
        ├── main.dart, splace_Screen.dart, Login_screen.dart, singup_Screen.dart
        ├── bottombar.dart        # Home · Doctors · Bookings · Report · Profile
        ├── Home_screen.dart, DoctorListScreen.dart, DoctorDetailScreen.dart
        ├── AppointmentScreen.dart, ReportsScreen.dart, PredictionScreen.dart, ProfileScreen.dart
        ├── models/               # Doctor, Appointment, Prediction / DiseaseModel
        ├── services/             # api_config, api_client, session, healthnova_api
        └── widgets/common.dart   # Status colours, loading / error / empty states
```

---

## Prerequisites

| Tool | Version | Needed for |
| --- | --- | --- |
| Node.js | 18 or later (project uses 22) | Backend and dashboard |
| Python | 3.10 or later | Prediction service |
| MongoDB | Atlas free M0 cluster, or MongoDB Community Server locally | Database |
| Flutter SDK | Matching Dart ^3.12.2 | Patient app |

On Windows PowerShell, if `npm` is blocked by the execution policy, run
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once, or use `npm.cmd`.

---

## Getting Started (Windows)

Four parts run side by side, each in its own terminal. Start them in this order.

### 1. Prediction service

```powershell
cd ml_service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

Leave it running (`http://127.0.0.1:8000`). The trained models are included; if your scikit-learn
version differs, it retrains them automatically on first start (about 30 seconds).

### 2. Backend API

```powershell
cd backend
npm install
copy .env.example .env
```

Open `backend\.env` and set `MONGO_URI` (your Atlas connection string, without the `<` `>` brackets)
and `JWT_SECRET` (any long random string). Then:

```powershell
npm run seed      # optional: demo admin, doctors, patients, appointments and predictions
npm run dev       # or: npm start
```

Expected output:

```
HealthNova server is running on port 5000
MongoDB Connected Successfully
```

`npm run seed` only adds records with `@healthnova.demo` emails (plus an admin if the database has
none), and running it twice does not duplicate anything. `npm run seed -- --remove` deletes only the
demo records.

### 3. Admin and doctor dashboard

```powershell
cd admin_dashboard
npm install
copy .env.example .env
npm run dev
```

Open `http://localhost:5173`. Administrators land on `/admin`, doctors on `/doctor`; patient accounts
are refused (they use the mobile app).

### 4. Patient app

```powershell
cd hospital
flutter pub get
flutter run
```

Where the app looks for the backend:

| Running on | Address used | What to do |
| --- | --- | --- |
| Android emulator | `http://10.0.2.2:5000` | Nothing — this is the default |
| Chrome / Windows desktop | `http://localhost:5000` | Nothing — this is the default |
| A real phone | Your computer's Wi-Fi IP | `flutter run --dart-define=API_URL=http://192.168.1.20:5000` (find the IP with `ipconfig`; phone and computer must be on the same Wi-Fi, and Windows Firewall must allow Node on port 5000) |

The Profile tab shows which address the app is using. After adding the new packages, stop the app and
run it again — a hot reload is not enough to load `shared_preferences`.

---

## Demo Accounts

Created by `npm run seed`:

| Role | Email | Password | Where |
| --- | --- | --- | --- |
| Admin | `admin@healthnova.com` | `Admin@123` | Dashboard (only created if no admin exists) |
| Doctor | `alex.doe@healthnova.demo` (also `john.doe`, `sarah.smith`, `meera.shah`) | `Doctor@123` | Dashboard |
| Patient | `ravi.patel@healthnova.demo` (also `sarah.khan`, `kevin.smith`, `ama.watson`, `arjun.mehta`) | `Patient@123` | Flutter app |

New doctors are added from the dashboard (Doctors → Add doctor), which creates their login. Patients
register themselves in the app. An existing account whose `role` was changed to `doctor` by hand in
Atlas gets a placeholder doctor profile the next time `npm run seed` runs, so it can sign in.

---

## Environment Variables

**`backend/.env`** — never commit this file (it is git-ignored).

| Variable | Example | Purpose |
| --- | --- | --- |
| `PORT` | `5000` | Port the API listens on |
| `MONGO_URI` | `mongodb+srv://USER:PASS@cluster.mongodb.net/healthnova` | MongoDB connection string |
| `JWT_SECRET` | any long random string | Signs login tokens; changing it signs everyone out |
| `ML_SERVICE_URL` | `http://127.0.0.1:8000` | Where the prediction service runs |
| `CORS_ORIGIN` | *(empty)* | Optional comma-separated browser origins; empty allows any (needed for Flutter web) |

**`admin_dashboard/.env`**

| Variable | Example | Purpose |
| --- | --- | --- |
| `VITE_API_TARGET` | `http://localhost:5000` | Backend address the Vite server forwards `/api` to |

**Flutter** — `--dart-define=API_URL=…` as shown above.

---

## API Reference

Base URL `http://localhost:5000`. Send the token **bare** — `Authorization: <token>`, no `Bearer `
prefix. Every response is JSON; errors are `{ "message": "…" }`.

**Authentication and own account**

| Method and path | Access | Notes |
| --- | --- | --- |
| `POST /api/auth/register` | Public | `name`, `email`, `phone` (10 digits), `password` (6+). Always creates a patient |
| `POST /api/auth/login` | Public | Returns `token` and `user` (`_id`, `name`, `email`, `phone`, `role`) |
| `GET /api/user/me` | Signed in | Own account (no password) |
| `PUT /api/user/me` | Signed in | Update `name`, `phone`, `gender`, `dob`; empty string clears gender/dob |
| `GET /api/user/profile` | Signed in | Decoded token payload |

**Patient** (`/api/patient`, patient role)

| Method and path | Notes |
| --- | --- |
| `GET /doctors?search=` | Search matches doctor name, specialization and hospital |
| `GET /doctors/:id` | One doctor's public profile |
| `POST /appointments` | `doctor`, `date` (`YYYY-MM-DD`, not in the past), `time`, `reason`. Starts as Pending |
| `GET /appointments` | Own appointments with doctor details |
| `DELETE /appointments/:id` | Cancel own request while still Pending |
| `GET /prediction-models` | The six disease forms: fields, units, ranges, options, model accuracy |
| `POST /predictions` | `{ "disease": "diabetes", "inputs": { … } }` → stored result + disclaimer |
| `GET /predictions` | Own prediction history |

**Doctor** (`/api/doctor`, doctor role — always scoped to the signed-in doctor)

| Method and path | Notes |
| --- | --- |
| `GET /stats` | Today's appointments, pending requests, patients seen, completed visits |
| `GET /profile`, `PUT /profile` | Own profile; can change hospital, fee, experience, availability, name, phone |
| `GET /appointments?status=` | Own appointments |
| `GET /appointments/:id` | One of own appointments |
| `PATCH /appointments/:id/status` | `Approved`, `Rejected` or `Completed` |
| `GET /patients/:id` | A patient they have an appointment with: details, visits, risk checks |

**Admin** (`/api/admin`, admin role)

| Method and path | Notes |
| --- | --- |
| `GET /stats` | Counts of patients, doctors, appointments, predictions |
| `GET /doctors?search=`, `GET /doctors/:id` | List / read doctors |
| `POST /doctors` | Creates the doctor's login and profile (`name`, `email`, `phone`, `password`, `specialization`, `qualification`, …) |
| `PUT /doctors/:id`, `DELETE /doctors/:id` | Update; delete removes the login and their appointments |
| `GET /patients?search=`, `DELETE /patients/:id` | Delete removes their appointments and predictions |
| `GET /appointments?status=` | All appointments |
| `PATCH /appointments/:id/status`, `DELETE /appointments/:id` | Any status / remove |
| `GET /predictions?patient=` | All predictions, optionally for one patient |

`GET /api/health` answers `{ "message": "HealthNova API is running" }` without a token.

---

## Disease-Risk Prediction

Each model was chosen by 5-fold cross-validation among logistic regression, random forest and gradient
boosting, then scored once on a 20% test set it never saw during training:

| Disease | Dataset | Model | Test accuracy | Test ROC-AUC |
| --- | --- | --- | --- | --- |
| Diabetes | Pima Indians Diabetes (768) | Logistic regression | 73.4% | 0.811 |
| Heart disease | Cleveland Heart Disease (303) | Logistic regression | 86.9% | 0.958 |
| Liver disease | Indian Liver Patient (583) | Random forest | 72.6% | 0.792 |
| Kidney disease | Chronic Kidney Disease (400) | Logistic regression | 98.8% | 0.978 |
| Stroke | Stroke Prediction (5,109) | Logistic regression | 73.4% | 0.840 |
| Hypertension | Framingham Heart Study (4,240) | Logistic regression | 65.2% | 0.742 |

Results are shown as **Low** (under 35% probability), **Moderate** (35–65%) or **High** (65% and
above). `ml_service/README.md` explains the method, sensitivity and specificity, and the limits of each
dataset; `ml_service/data/SOURCES.md` lists where each dataset comes from.

---

## Roles and Authorization

1. `authMiddleware` verifies the JWT and puts `{ userId, role }` on `req.user`; a missing or invalid
   token gets `401`.
2. `roleMiddleware("admin")` (and the doctor / patient equivalents) answers `403` to any other role.
3. Doctor and patient routes take the user from the token, never from the request, so nobody can read
   or change another person's appointments by changing an id.
4. The dashboard mirrors this: signed-out visitors go to `/login`, wrong roles to Access Denied. The
   Flutter app accepts patient accounts only and returns to the login screen when a token expires.

---

## Testing

| Command | What it covers |
| --- | --- |
| `cd backend && npm test` | 93 checks over every route, with an in-memory database — no setup needed |
| `cd backend && npm run test:live` | 63 checks against a real MongoDB. Set `MONGO_URI_TEST` and `JWT_SECRET_TEST` first (use a separate test cluster — it writes to a `healthnova_test` database) |
| `cd ml_service && python -m pytest -q` | 22 checks: every form, validation, and that high-risk profiles score above low-risk ones (`pip install -r requirements-dev.txt` first) |
| `cd hospital && flutter test` | Login form validation and the app's parsing of API responses |

---

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| Backend: `MongoDB Connection Failed` | Wrong `MONGO_URI`, or your IP is not in Atlas → Network Access. Add your IP (or `0.0.0.0/0` for development only) |
| Login works but predictions say "The prediction service is not available" | `ml_service` is not running, or `ML_SERVICE_URL` points elsewhere |
| Dashboard: "Cannot reach the HealthNova backend" | Backend not running, or `VITE_API_TARGET` does not match the backend port |
| Doctor sees "This account has no doctor profile yet" | The account was promoted to doctor by hand. Run `npm run seed`, or create doctors from the admin dashboard |
| Flutter: "Cannot reach the HealthNova server at …" | The address in the message is wrong for your device — see the table in step 4 |
| Flutter: `MissingPluginException` (shared_preferences) | Stop the app completely and run it again after `flutter pub get` |
| `401` from the API with a valid-looking token | A `Bearer ` prefix was added — send the token on its own |

---

## Branching and Workflow

| Branch | Contents |
| --- | --- |
| `main` | Integrated project |
| `backend` | Backend development |
| `feature/login` | Authentication work |
| `flutter-ui` | Flutter UI development |
| `feature-admin-dashboard` | React dashboard |

- Feature and fix work happens on its own branch and reaches `main` through a pull request.
- Naming: `camelCase` for variables, functions and backend files; `PascalCase` for classes, React
  components and their files; `kebab-case` for CSS classes; `UPPER_SNAKE_CASE` for environment
  variables.
- `.env` files hold the database password and JWT secret and are git-ignored — never commit them.

---

*Academic project developed at LJ University for the MCA programme. Not intended for clinical use: the
disease-risk predictions are statistical estimates and not a substitute for professional medical
advice.*
