# HealthNova — Smart Healthcare Management System

HealthNova is a full-stack healthcare platform built as an MCA Semester 3 academic project. It brings
appointment management, role-based healthcare services and ML-based disease-risk prediction together in
one system, with a Flutter mobile application for patients and a React web dashboard for administrators
and doctors, both served by a single Node.js + Express REST API backed by MongoDB.

---

## Table of Contents

- [Team](#team)
- [Project Status](#project-status)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [1. Backend API](#1-backend-api)
  - [2. Admin Dashboard (React)](#2-admin-dashboard-react)
  - [3. Patient App (Flutter)](#3-patient-app-flutter)
- [Environment Variables](#environment-variables)
- [API Reference](#api-reference)
- [Roles and Authorization](#roles-and-authorization)
- [Creating an Admin Account](#creating-an-admin-account)
- [Known Issues and Gotchas](#known-issues-and-gotchas)
- [Branching and Workflow](#branching-and-workflow)
- [Roadmap](#roadmap)
- [Documentation](#documentation)

---

## Team

| Role | Member | Enrolment |
| --- | --- | --- |
| Backend and database | Karan Rahani | C37 |
| Flutter patient application | Mohammad Anas Qureshi | C34 |
| React Admin/Doctor dashboard | Harshrajsinh Zala | C49 |

**Institute:** LJ University — Master of Computer Applications (MCA), Semester 3, Academic Year 2026–27
**Group:** 12  **Faculty / Coordinator:** Ajay Chauhan Sir
**Target completion:** December 2026

---

## Project Status

| Module | Status | Notes |
| --- | --- | --- |
| Backend REST API (Node.js + Express) | Implemented | Six endpoints live |
| MongoDB database | Implemented | Hosted on MongoDB Atlas |
| Authentication (bcrypt + JWT) | Implemented | 7-day tokens, hashed passwords |
| Role-based authorization | Implemented | `patient` / `doctor` / `admin` route gates |
| React Admin dashboard | In development | Login, Dashboard, Profile, Access Denied working against the live API |
| Flutter patient app | In development | UI built; API integration pending |
| Admin management modules | Not started | Needs doctor / patient / appointment endpoints |
| React Doctor dashboard | Not started | Planned after the Admin modules |
| Disease-risk prediction | Not started | External / pre-developed prediction API to be selected |

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Patient app | Flutter 3.44.8 (Dart SDK ^3.12.2) |
| Web dashboard | React 19, Vite 6, React Router 7, Axios, Lucide React, plain CSS |
| Backend | Node.js 22.15.0, Express 5, Mongoose 9 |
| Database | MongoDB (Atlas, M0 cluster) |
| Auth | bcryptjs (password hashing), jsonwebtoken (JWT sessions) |
| ML integration | Pre-developed disease-prediction API *(provider to be selected)* |
| Tooling | Git, GitHub, nodemon, dotenv |

---

## Repository Structure

```
HealthNova/
├── backend/                     # Node.js + Express REST API
│   ├── server.js                # Entry point: loads .env, connects DB, starts server
│   ├── package.json
│   └── src/
│       ├── app.js               # Express app, JSON parser, route mounting
│       ├── config/db.js         # Mongoose connection
│       ├── controllers/
│       │   └── authControllers.js   # registerUser, loginUser
│       ├── middleware/
│       │   ├── authMiddleware.js    # JWT verification
│       │   └── roleMiddleware.js    # Role gate (403 on mismatch)
│       ├── models/userModel.js      # User schema
│       └── routes/                  # auth, user, admin, doctor, patient
│
├── admin_dashboard/             # React Admin web application (see its own README)
│   ├── vite.config.js           # Dev proxy: /api -> backend
│   └── src/
│       ├── api/                 # axiosInstance, authApi, userApi
│       ├── components/          # Sidebar, Header, StatCard, Badge, states
│       ├── context/             # AuthContext, authStorage
│       ├── hooks/useAuth.js
│       ├── layouts/AdminLayout.jsx
│       ├── pages/               # Login, Dashboard, Profile, Unauthorized, NotFound
│       ├── routes/ProtectedRoute.jsx
│       └── styles/              # variables.css (design tokens), global.css
│
└── hospital/                    # Flutter patient application
    └── lib/
        ├── main.dart
        ├── splace_Screen.dart, Login_screen.dart, singup_Screen.dart
        ├── Home_screen.dart, DoctorListScreen.dart, AppointmentScreen.dart
        ├── ReportsScreen.dart, bottombar.dart
        └── pratric.dart
```

---

## Prerequisites

| Tool | Version | Needed for |
| --- | --- | --- |
| Node.js | 18+ (project uses 22.15.0) | Backend and Admin dashboard |
| npm | Ships with Node.js | Both |
| MongoDB Atlas account | Free M0 tier is enough | Database |
| Flutter SDK | 3.44.8 | Patient app |
| Git | Any recent version | Source control |

On Windows PowerShell, if `npm` scripts are blocked, either allow them once with
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` or call `npm.cmd` instead of `npm`.

---

## Getting Started

Clone the repository first:

```bash
git clone https://github.com/Karan74x/HealthNova.git
cd HealthNova
```

### 1. Backend API

```bash
cd backend
npm install
npm install bcryptjs        # see Known Issues — not yet in backend/package.json
```

Create `backend/.env` (see [Environment Variables](#environment-variables)), then start the server:

```bash
node server.js
# or, with auto-reload during development:
npx nodemon server.js
```

Expected output:

```
HealthNova server is running on port 5000
MongoDB Connected Successfully
```

### 2. Admin Dashboard (React)

In a second terminal, with the backend still running:

```bash
cd admin_dashboard
npm install
copy .env.example .env      # macOS/Linux: cp .env.example .env
npm run dev
```

Open the printed URL (usually `http://localhost:5173`) and sign in with an **admin** account.
A patient account will authenticate successfully but land on the Access Denied screen, which is the
role gate working as intended.

The dashboard talks to the backend through Vite's dev proxy (`/api` → `VITE_API_TARGET`), so requests
are same-origin from the browser's point of view. The backend does not register CORS middleware yet, so
calling it directly from a different origin will fail — see [Known Issues](#known-issues-and-gotchas).

### 3. Patient App (Flutter)

```bash
cd hospital
flutter pub get
flutter run
```

The patient app currently renders sample data. Integration with the backend API is the next stage of
its development.

---

## Environment Variables

**`backend/.env`** — never commit this file.

| Variable | Example | Purpose |
| --- | --- | --- |
| `PORT` | `5000` | Port the Express server listens on |
| `MONGO_URI` | `mongodb+srv://<user>:<pass>@<cluster>.mongodb.net/healthnova` | Mongoose connection string |
| `JWT_SECRET` | any long random string | Secret used to sign and verify JWTs |

**`admin_dashboard/.env`**

| Variable | Example | Purpose |
| --- | --- | --- |
| `VITE_API_TARGET` | `http://localhost:5000` | Backend address the Vite dev proxy forwards `/api` to |

> Paste connection strings **without** the angle brackets from the Atlas template — `<password>`
> placeholders left in place are the most common cause of a failed connection.

---

## API Reference

Base URL: `http://localhost:5000`

| Method / Endpoint | Access | Request | Response |
| --- | --- | --- | --- |
| `POST /api/auth/register` | Public | `phone`, `email`, `password` | `201` with the created user; `400` if the email already exists |
| `POST /api/auth/login` | Public | `email`, `password` | `200` with a JWT and the user object; `400` on invalid credentials |
| `GET /api/user/profile` | Any signed-in user | Token in header | `200` with the decoded token payload |
| `GET /api/admin/dashboard` | `admin` only | Token in header | `200` on success; `403` for other roles |
| `GET /api/doctor/dashboard` | `doctor` only | Token in header | `200` on success; `403` for other roles |
| `GET /api/patient/dashboard` | `patient` only | Token in header | `200` on success; `403` for other roles |

**Validation rules:** `phone` must be exactly 10 digits, `email` is unique and stored lowercase,
`password` must be at least 6 characters and is stored as a bcrypt hash (salt rounds 10).

**Authorization header:** the token is sent **raw**, without a `Bearer ` prefix:

```
Authorization: <token>
```

`authMiddleware` passes `req.headers.authorization` straight into `jwt.verify`, so a `Bearer ` prefix
would make verification fail. Tokens expire after 7 days.

---

## Roles and Authorization

Every account has a `role` of `patient`, `doctor` or `admin`.

1. `authMiddleware` verifies the JWT and attaches the decoded payload (`userId`, `role`) to `req.user`.
2. `roleMiddleware("admin")` compares `req.user.role` against the required role and returns
   `403 Access denied` on a mismatch.
3. On the dashboard, `ProtectedRoute` mirrors this in the UI: unauthenticated users are redirected to
   `/login`, and a signed-in user with the wrong role is shown the Access Denied page.

---

## Creating an Admin Account

`registerUser` always creates accounts with `role: "patient"` and ignores any role sent in the request
body. Promoting an account is therefore a manual step:

1. Register the account normally:

   ```powershell
   $body = '{"phone":"9000000001","email":"admin@healthnova.com","password":"Admin@123"}'
   Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" -Method Post -ContentType "application/json" -Body $body
   ```

   ```bash
   # macOS/Linux
   curl -X POST http://localhost:5000/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"phone":"9000000001","email":"admin@healthnova.com","password":"Admin@123"}'
   ```

2. In MongoDB Atlas, open **Browse Collections → your database → `users`**.
3. Find the new document and change `role` from `"patient"` to `"admin"`, then save.
4. Sign in to the dashboard with that email and password.

---

## Known Issues and Gotchas

| Issue | Effect | Fix / workaround |
| --- | --- | --- |
| `bcryptjs` is declared in the **root** `package.json`, not `backend/package.json` | A fresh clone fails with `Cannot find module 'bcryptjs'`, because it only resolves when a copy happens to exist in a parent folder | Run `cd backend && npm install bcryptjs`, commit the updated `backend/package.json`, and delete the stray root `package.json` / `package-lock.json` |
| No CORS middleware on the backend | A browser calling the API from another origin is blocked | The dashboard uses Vite's `/api` proxy in development. For deployment, add the `cors` package to Express |
| `registerUser` ignores any `role` in the request body | Admin and doctor accounts cannot be created through the API | Promote the account manually in Atlas (see above) |
| Atlas Network Access allowlist | `Server Error` (500) on login when your IP changes, e.g. on a mobile hotspot | Add your current IP, or *Allow Access From Anywhere* (`0.0.0.0/0`) for development only |
| Backend has no `start` / `dev` npm script | `npm start` and `npm run dev` fail inside `backend/` | Use `node server.js` or `npx nodemon server.js` |
| `.env` files | Contain the database password and JWT secret | Already git-ignored — never commit them |

---

## Branching and Workflow

| Branch | Contents |
| --- | --- |
| `main` | Integrated backend and Flutter application |
| `backend` | Backend development |
| `feature-login` | Authentication work |
| `flutter-ui` | Flutter UI development |
| `feature-admin-dashboard` | React Admin dashboard |

Conventions used across the project:

- Feature and fix work happens on its own branch, never directly on `main`.
- Changes are merged through pull requests so they can be reviewed.
- Commit messages are written to describe *why* the change was made.
- Naming: `camelCase` for variables, functions and backend file names; `PascalCase` for classes,
  React components and component files; `kebab-case` for CSS class names and custom properties;
  `UPPER_SNAKE_CASE` for environment variables.

---

## Roadmap

1. Implement the Doctor, Appointment and Prediction models in MongoDB.
2. Build administrator management endpoints for doctors, patients and appointments.
3. Add dashboard statistics endpoints for the overview cards.
4. Build the Admin dashboard management modules against those endpoints.
5. Develop the React Doctor dashboard.
6. Select and integrate the disease-prediction API, and store prediction history.
7. Connect the Flutter patient application to the backend API.
8. Test all modules, including unauthorised-access testing.
9. Final integration, documentation and demonstration preparation.

---

## Documentation

- `admin_dashboard/README.md` — dashboard-specific setup, the backend contract it depends on, and the
  design tokens taken from the Flutter application.
- Review 2 project documentation and presentation are maintained separately as part of the academic
  submission.

---

*Academic project developed at LJ University for the MCA programme. Not intended for clinical use: the
disease-risk prediction feature is indicative only and is not a substitute for professional medical
advice.*
