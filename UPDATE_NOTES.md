# HealthNova – complete system update

This archive holds only the files that are new or changed compared with `main`
(115 files). Copy the `HealthNova` folder over your local clone, keeping the
folder structure, then follow **Getting Started (Windows)** in `README.md`.

## What is new

- `ml_service/` – Python prediction service with six trained models (new folder).
- `backend/` – doctors, appointments, predictions, statistics, own-account
  editing, CORS, seed script and tests.
- `admin_dashboard/` – all admin and doctor management screens and an
  editable profile.
- `hospital/` – the Flutter app connected to the backend: login, sign-up,
  doctors, booking, appointments, risk checks, profile.

## After copying

1. `cd backend && npm install` (adds `cors`), create `backend/.env` from
   `.env.example`, then `npm run seed` for demo data.
2. `cd ml_service`, create the virtual environment, `pip install -r requirements.txt`.
3. `cd hospital && flutter pub get` (adds `http` and `shared_preferences`).
4. Optional clean-up: the root `package.json` and `package-lock.json` only
   held `bcryptjs`, which `backend/package.json` now lists itself – they can
   be deleted. `README.mdx` at the root is an older copy of `README.md`.

## Flutter note

The Flutter changes are made on the `hospital/` code that is on GitHub
(`main`). Screens built locally since then and not yet pushed need to be merged
with these files, using `lib/services/healthnova_api.dart` for the API calls.
