# HealthNova – Admin & Doctor Dashboard

React web application for the HealthNova Smart Healthcare Management System.
One application serves both staff roles: the role on the signed-in account
decides whether it opens the administrator area (`/admin`) or the doctor area
(`/doctor`). Patients use the Flutter app instead.
Part of the MCA Semester 3 group project; this module is maintained by
Harshrajsinh Zala and sits alongside `backend/` (Karan Rahani), `hospital/`
(Mohammad Anas Qureshi) and `ml_service/`.

## Tech stack

React 19 · Vite 6 · React Router 7 · Axios · Lucide React · plain CSS

No CSS framework and no state-management library are used. Theme values live in
`src/styles/variables.css`.

## Running it

The backend (and, for predictions, `ml_service`) must be running first — see
the root README.

```powershell
cd admin_dashboard
npm install
copy .env.example .env     # macOS/Linux: cp .env.example .env
npm run dev                # http://localhost:5173
```

`VITE_API_TARGET` in `.env` must match the backend's `PORT` (default
`http://localhost:5000`). A wrong value shows "Cannot reach the HealthNova
backend" on the login screen.

The dashboard calls the relative path `/api/...` and Vite forwards it to
`VITE_API_TARGET`, for both `npm run dev` and `npm run preview`. The browser
only ever talks to one origin, so no CORS setup is involved.

For a production build: `npm run build`, then serve `dist/` with anything that
forwards `/api` to the backend.

## Signing in

| Role | Lands on | Sees |
|---|---|---|
| `admin` | `/admin` | Dashboard, Doctors, Patients, Appointments, Predictions, Profile |
| `doctor` | `/doctor` | Dashboard, Appointments, Patients, Profile |
| `patient` | `/unauthorized` | Access Denied – patients use the mobile app |

Each area is guarded separately, so a doctor opening `/admin` is refused just
as an administrator opening `/doctor` is. This mirrors `roleMiddleware` on the
backend, which answers `403` to the wrong role.

`npm run seed` in `backend/` creates demo accounts (admin
`admin@healthnova.com` / `Admin@123`, doctor `alex.doe@healthnova.demo` /
`Doctor@123`). New doctors are created from **Doctors → Add doctor**, which
creates their login with a temporary password.

## Screens

**Administrator**

- **Dashboard** – live counts (each card links to its list), requests awaiting
  approval with Approve / Reject, and the latest predictions.
- **Doctors** – search; add (creates the login), edit, delete with
  confirmation.
- **Patients** – search; details with the patient's prediction history; delete
  (also removes their appointments and predictions).
- **Appointments** – filter by status, search; Approve / Reject pending,
  Complete approved, delete.
- **Predictions** – filter by disease, search by patient; details show the
  risk, probability and every value the patient entered. Read-only.

**Doctor**

- **Dashboard** – today's appointments, pending requests, patients seen,
  completed visits; requests to Accept / Decline; today's schedule.
- **Appointments** – filter, search, details dialog, Accept / Decline /
  Mark completed.
- **Patients** – everyone who has booked this doctor, with visit history and
  the patient's risk checks from the app.

**Both** – **Profile**: edit name, phone, gender and date of birth; doctors
also edit hospital, fee, experience and availability (specialization and
qualification stay with the administrator).

Every list has loading, error-with-retry and empty states, and actions confirm
with a short message. Tables turn into stacked cards on phone-sized screens.

## Backend endpoints used

| Area | Endpoints |
|---|---|
| Auth | `POST /api/auth/login` |
| Own account | `GET /api/user/me`, `PUT /api/user/me`, `GET /api/user/profile` |
| Admin | `GET /api/admin/stats`; `GET/POST /api/admin/doctors`, `PUT/DELETE /api/admin/doctors/:id`; `GET /api/admin/patients`, `DELETE /api/admin/patients/:id`; `GET /api/admin/appointments`, `PATCH /api/admin/appointments/:id/status`, `DELETE /api/admin/appointments/:id`; `GET /api/admin/predictions` |
| Doctor | `GET /api/doctor/stats`; `GET/PUT /api/doctor/profile`; `GET /api/doctor/appointments`, `PATCH /api/doctor/appointments/:id/status`; `GET /api/doctor/patients/:id` |

Two contracts worth noting, both encoded in `src/api/axiosInstance.js`:

- `authMiddleware` passes `req.headers.authorization` straight to `jwt.verify`,
  so the token is sent **bare**, not as `Bearer <token>`.
- Failed logins return **400**, not 401, so they are shown as a credentials
  error. A 401 on any other call means the session has expired: the dashboard
  clears it and returns to the login screen.

## Project structure

```
admin_dashboard/
├── vite.config.js          /api proxy to VITE_API_TARGET
├── .env.example
└── src/
    ├── api/                axiosInstance, authApi, userApi, adminApi, doctorApi
    ├── context/            AuthContext, token storage helpers
    ├── hooks/              useAuth, useResource (loading / error / reload)
    ├── config/             navigation.js – per-role links, titles, landing path
    ├── routes/             ProtectedRoute, RoleLanding
    ├── layouts/            DashboardLayout (shared shell)
    ├── components/         Sidebar, Header, DataTable, Modal, ConfirmDialog,
    │                       PageToolbar, Toast, StatCard, Badge, states
    ├── pages/              Login, AdminDashboard, DoctorDashboard, Profile,
    │   │                   Unauthorized, NotFound
    │   ├── admin/          AdminDoctors, AdminPatients, AdminAppointments,
    │   │                   AdminPredictions
    │   └── doctor/         DoctorAppointments, DoctorPatients
    ├── utils/format.js     dates, names, fees, status and risk colours
    └── styles/             variables.css (theme), global.css
```

## Theme

Colours are taken from the Flutter application in `hospital/lib` so both
clients read as the same product. Each token in `variables.css` names its Dart
source. Three deliberate differences are documented in that file: the mid-blue
Flutter scaffold background and `Colors.grey` body text both fail WCAG contrast
and are used as accents rather than as text/background, and a danger colour is
introduced from Material `red[600]` because the Flutter app contains no red.
