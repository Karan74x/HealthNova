# HealthNova – Patient App (Flutter)

The patient side of HealthNova. Patients sign up, find doctors, book
appointments, follow their status, and check their risk of six diseases with
the trained models in `ml_service`. Maintained by Mohammad Anas Qureshi.

## Running it

The backend and the prediction service must be running first (see the root
README). Then:

```powershell
cd hospital
flutter pub get
flutter run
```

### Which backend address the app uses

| Running on | Address | What to do |
|---|---|---|
| Android emulator | `http://10.0.2.2:5000` | Nothing (default) |
| Chrome, Windows, macOS, iOS simulator | `http://localhost:5000` | Nothing (default) |
| A real phone | Your computer's Wi-Fi IP | `flutter run --dart-define=API_URL=http://192.168.1.20:5000` |

For a real phone, find the computer's IP with `ipconfig`, keep both on the same
Wi-Fi, and allow Node.js through Windows Firewall. The Profile tab shows the
address in use. The logic is in `lib/services/api_config.dart`.

Android and iOS are configured to allow plain `http://` during development
(`usesCleartextTraffic` in `AndroidManifest.xml`, `NSAllowsLocalNetworking`
in `Info.plist`); macOS has the network-client entitlement.

## Screens

| Screen | File | What it does |
|---|---|---|
| Splash | `splace_Screen.dart` | Restores a saved login, else opens Sign Up |
| Sign Up / Login | `singup_Screen.dart`, `Login_screen.dart` | Create an account (signs in straight after) / sign in. Doctor and admin accounts are pointed to the web dashboard |
| Home | `Home_screen.dart` | Greeting, doctor search, shortcuts, next upcoming appointment |
| Doctors | `DoctorListScreen.dart` | Search by name, speciality or hospital; pull to refresh |
| Doctor detail | `DoctorDetailScreen.dart` | Profile, date picker, time slots, reason → request appointment |
| Bookings | `AppointmentScreen.dart` | Own appointments with status; cancel while Pending |
| Report | `ReportsScreen.dart` | The six risk checks and the patient's earlier results |
| Risk check | `PredictionScreen.dart` | Form built from the model's fields, then the result with probability, advice and disclaimer |
| Profile | `ProfileScreen.dart` | Edit name, phone, gender, date of birth; log out |

## How it talks to the backend

- `lib/services/healthnova_api.dart` – every API call the app makes.
- `lib/services/api_client.dart` – JSON over `http`, the token sent **bare**
  in the `Authorization` header (the backend rejects a `Bearer ` prefix), and
  readable error messages. A `401` clears the session and returns to Login.
- `lib/services/session.dart` – keeps the token and account in
  `shared_preferences`, so the patient stays signed in; expired tokens are
  dropped on start.
- `lib/models/` – `Doctor`, `Appointment`, `DiseaseModel` / `FeatureField` /
  `Prediction`, read from the API's JSON.

The risk-check forms are not hard-coded: `GET /api/patient/prediction-models`
returns each disease's fields, units, ranges and options, and
`PredictionScreen` builds the form from it.

## Tests

```powershell
flutter test
```

Covers the login form's validation and the parsing of doctors, appointments,
prediction forms, booking dates and token expiry.
