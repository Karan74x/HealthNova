# HealthNova – Admin & Doctor Dashboard

React web application for the HealthNova Smart Healthcare Management System.
One application serves both staff roles: the role on the signed-in account
decides whether it opens the administrator area (`/admin`) or the doctor area
(`/doctor`).
Part of the MCA Semester 3 group project; this module is maintained by
Harshrajsinh Zala and sits alongside `backend/` (Karan Rahani) and `hospital/`
(Mohammad Anas Qureshi).

## Tech stack

React 19 · Vite 6 · React Router 7 · Axios · Lucide React · plain CSS

No CSS framework and no state-management library are used. Theme values live in
`src/styles/variables.css`.

## Running it

```bash
cd admin_dashboard
npm install
cp .env.example .env     # then set VITE_API_TARGET to the backend's port
npm run dev              # http://localhost:5173
```

The backend must be running separately:

```bash
cd backend
npm install
node server.js
```

### Setting `VITE_API_TARGET`

`backend/server.js` reads `process.env.PORT` and has no fallback, so the port
comes from `backend/.env`. Put the same address in `admin_dashboard/.env`:

```
VITE_API_TARGET=http://localhost:5000
```

If the backend logs `HealthNova server is running on port 3000`, change the
value to match. A wrong value shows "Cannot reach the HealthNova backend" on
the login screen.

### Why requests go through a proxy

The backend does not enable CORS, so a browser cannot call it cross-origin.
The dashboard therefore requests the relative path `/api/...`, and the Vite dev
server forwards it to the backend server-to-server, where CORS does not apply
(`vite.config.js`). No backend change is required for development.

This applies to `npm run dev`. If the dashboard is ever deployed as a static
build pointing at a remote API, `cors` will need to be added to the backend at
that point.

## Signing in

The dashboard accepts **administrator and doctor accounts**. One login screen
serves both: after authentication the role decides where you land.

| Role | Lands on | Sees |
|---|---|---|
| `admin` | `/admin` | Administrator dashboard and profile |
| `doctor` | `/doctor` | Doctor dashboard and profile |
| `patient` | `/unauthorized` | Access Denied – patients use the mobile app |

Each area is guarded separately, so a doctor opening `/admin` is refused just
as an administrator opening `/doctor` is. This mirrors `roleMiddleware` on the
backend, which answers `403` to the wrong role.

`POST /api/auth/register` ignores the `role` field and creates every account as
`patient`, so neither an admin nor a doctor can be created through the API. To
create one, change a user's `role` to `"admin"` or `"doctor"` directly in
MongoDB (Compass or Atlas).

## Backend endpoints used

| Method | Endpoint | Used by |
|---|---|---|
| POST | `/api/auth/login` | Login |
| GET | `/api/user/profile` | Profile |
| GET | `/api/admin/dashboard` | Administrator dashboard |
| GET | `/api/doctor/dashboard` | Doctor dashboard |

Two contracts worth noting, both encoded in `src/api/`:

- `authMiddleware` passes `req.headers.authorization` straight to `jwt.verify`
  without stripping a scheme, so the token is sent **bare**, not as
  `Bearer <token>`.
- Failed logins return **400**, not 401, so they are shown as a credentials
  error rather than treated as a session expiry.

## Current scope

Implemented and working against the real backend:

- Login with validation and error states
- JWT storage, session restore on reload, expiry handling
- Protected routes with a separate role gate for each staff area
- Logout
- Responsive layout (sidebar, header, content) shared by both areas
- Role-aware navigation: each role sees only its own links
- Administrator dashboard – verifies the admin role gate end to end
- Doctor dashboard – verifies the doctor role gate end to end
- Profile – read-only account and session details, for both roles

Not implemented, because no backend endpoint exists yet:

- Administrator: dashboard counts, and Doctor / Patient / Appointment /
  Prediction management
- Doctor: assigned appointments, appointment detail, accept / reject, mark
  completed, patient details, availability

These appear in each sidebar as disabled entries so the intended structure is
visible without implying the features work. No mock or placeholder data is used
anywhere in this application.

## Project structure

```
admin_dashboard/
├── vite.config.js          /api dev proxy
├── .env.example
└── src/
    ├── api/                axios instance + endpoint wrappers
    ├── context/            AuthContext, token storage helpers
    ├── hooks/              useAuth
    ├── config/             navigation.js – per-role links, titles, landing path
    ├── routes/             ProtectedRoute, RoleLanding
    ├── layouts/            DashboardLayout (shared shell)
    ├── components/         Sidebar, Header, StatCard, Badge, states
    ├── pages/              Login, AdminDashboard, DoctorDashboard, Profile,
    │                       Unauthorized, NotFound
    └── styles/             variables.css (theme), global.css
```

## Theme

Colours are taken from the Flutter application in `hospital/lib` so both
clients read as the same product. Each token in `variables.css` names its Dart
source. Three deliberate differences are documented in that file: the mid-blue
Flutter scaffold background and `Colors.grey` body text both fail WCAG contrast
and are used as accents rather than as text/background, and a danger colour is
introduced from Material `red[600]` because the Flutter app contains no red.
