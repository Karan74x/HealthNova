/*
 * The same checks, but against a real MongoDB.
 *
 *   cd backend
 *   node test/live.test.js
 *
 * Connection settings, in order of preference:
 *
 *   MONGO_URI_TEST / JWT_SECRET_TEST   a separate cluster and secret, if you
 *                                      want the test fully isolated
 *   MONGO_URI / JWT_SECRET             otherwise the application's own values
 *
 * Either way the database name is FORCED to "healthnova_test", so the data the
 * application uses is never touched, and every document this creates is removed
 * at the end. Environment variables set in the shell win over the .env file, so
 * you can also point it somewhere else for one run without editing anything.
 */
require("dotenv").config();

// A calendar day a few days ahead, so booking tests never fall in the past
const futureDay = (days) => {
  const day = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
  return day.toISOString().slice(0, 10);
};

const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const app = require("../src/app.js");
const userModel = require("../src/models/userModel.js");
const doctorModel = require("../src/models/doctorModel.js");
const appointmentModel = require("../src/models/appointmentModel.js");
const predictionModel = require("../src/models/predictionModel.js");

const TEST_DB = "healthnova_test";

function testUri(uri) {
  if (!uri) return null;
  // mongodb+srv://user:pass@host/<db>?opts  ->  .../healthnova_test?opts
  const [head, query] = uri.split("?");
  const withoutDb = head.replace(/\/[^/]*$/, "");
  return `${withoutDb}/${TEST_DB}${query ? "?" + query : ""}`;
}

const results = [];
function check(name, passed, detail = "") {
  results.push({ name, passed });
  console.log(`${passed ? "PASS" : "FAIL"}  ${name}${!passed && detail ? "  — " + detail : ""}`);
}

let server;
let base;

async function call(method, url, { auth, body } = {}) {
  const headers = { "Content-Type": "application/json" };
  if (auth) headers.Authorization = auth;
  const response = await fetch(base + url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  let payload = null;
  try {
    payload = await response.json();
  } catch {
    payload = null;
  }
  return { status: response.status, body: payload };
}

async function expectStatus(name, method, url, options, expected) {
  const { status, body } = await call(method, url, options);
  check(name, status === expected, `expected ${expected}, got ${status} ${JSON.stringify(body)}`);
  return body;
}

const token = (userId, role) => jwt.sign({ userId, role }, process.env.JWT_SECRET);

async function main() {
  // A dedicated test secret is used when one is provided. The app reads
  // JWT_SECRET, so it is set from whichever value applies before the routes
  // verify any token.
  const secret = process.env.JWT_SECRET_TEST || process.env.JWT_SECRET;
  if (!secret) {
    console.error(
      "No JWT secret found.\n" +
      "Set JWT_SECRET_TEST (or JWT_SECRET) in backend/.env, or pass it for one run:\n" +
      '  $env:JWT_SECRET_TEST="..."; node test/live.test.js',
    );
    process.exit(1);
  }
  process.env.JWT_SECRET = secret;

  const source = process.env.MONGO_URI_TEST || process.env.MONGO_URI;
  const uri = testUri(source);
  if (!uri) {
    console.error(
      "No MongoDB connection string found.\n" +
      "Set MONGO_URI_TEST (or MONGO_URI) in backend/.env, or pass it for one run:\n" +
      '  $env:MONGO_URI_TEST="mongodb://127.0.0.1:27017"; node test/live.test.js',
    );
    process.exit(1);
  }

  const usingDedicated = Boolean(process.env.MONGO_URI_TEST);
  console.log(
    `connecting to the "${TEST_DB}" database on ` +
    (usingDedicated ? "MONGO_URI_TEST" : "MONGO_URI") +
    " (your application data is not touched)\n",
  );
  await mongoose.connect(uri);

  // start from clean collections in the test database
  await Promise.all([
    userModel.deleteMany({}),
    doctorModel.deleteMany({}),
    appointmentModel.deleteMany({}),
    predictionModel.deleteMany({}),
  ]);

  const hashed = await bcrypt.hash("Passw0rd", 10);
  const [admin, docUser, otherDocUser, patient, stranger] = await userModel.create([
    { name: "Admin", email: "t-admin@healthnova.test", phone: "9000000001", password: hashed, role: "admin" },
    { name: "Dr Alex", email: "t-doc1@healthnova.test", phone: "9000000003", password: hashed, role: "doctor" },
    { name: "Dr John", email: "t-doc2@healthnova.test", phone: "9000000004", password: hashed, role: "doctor" },
    { name: "Ravi", email: "t-patient@healthnova.test", phone: "9000000002", password: hashed, role: "patient" },
    { name: "Other", email: "t-other@healthnova.test", phone: "9000000005", password: hashed, role: "patient" },
  ]);

  const [doctor, otherDoctor] = await doctorModel.create([
    { user: docUser._id, specialization: "Cardiologist", qualification: "MD", experience: 12, hospital: "City Care", fee: 500 },
    { user: otherDocUser._id, specialization: "Dentist", qualification: "BDS", experience: 5, hospital: "Smile Clinic", fee: 300 },
  ]);

  const [mine, theirs] = await appointmentModel.create([
    { patient: patient._id, doctor: doctor._id, date: new Date(), time: "12:30 PM", reason: "Checkup" },
    { patient: stranger._id, doctor: otherDoctor._id, date: new Date(), time: "10:00 AM", reason: "Cleaning" },
  ]);

  await predictionModel.create({
    patient: patient._id, disease: "Diabetes",
    inputs: { glucose: 140 }, result: "High risk", riskLevel: "High", confidence: 82,
  });

  server = app.listen(0);
  await new Promise((resolve) => server.once("listening", resolve));
  base = `http://127.0.0.1:${server.address().port}`;

  const adminAuth = token(admin._id, "admin");
  const doctorAuth = token(docUser._id, "doctor");
  const patientAuth = token(patient._id, "patient");

  console.log("--- authentication and role gates ---");
  await expectStatus("no token is refused", "GET", "/api/admin/stats", {}, 401);
  await expectStatus("patient cannot reach admin routes", "GET", "/api/admin/stats", { auth: patientAuth }, 403);
  await expectStatus("admin cannot reach doctor routes", "GET", "/api/doctor/appointments", { auth: adminAuth }, 403);

  console.log("\n--- admin ---");
  const stats = await expectStatus("stats", "GET", "/api/admin/stats", { auth: adminAuth }, 200);
  check("stats counts are right",
    stats?.data?.patients === 2 && stats.data.doctors === 2 && stats.data.appointments === 2 && stats.data.predictions === 1,
    JSON.stringify(stats?.data));

  const doctors = await expectStatus("list doctors", "GET", "/api/admin/doctors", { auth: adminAuth }, 200);
  check("doctors populate their user account", doctors?.data?.[0]?.user?.email !== undefined);
  check("password never leaves the server", !JSON.stringify(doctors).includes("$2"));

  const search = await expectStatus("search doctors by name", "GET", "/api/admin/doctors?search=Alex", { auth: adminAuth }, 200);
  check("search matches on the user's name", search?.data?.length === 1, `${search?.data?.length} returned`);
  const bySpec = await expectStatus("search doctors by specialization", "GET", "/api/admin/doctors?search=Dentist", { auth: adminAuth }, 200);
  check("search matches on specialization", bySpec?.data?.length === 1, `${bySpec?.data?.length} returned`);

  const created = await expectStatus("create doctor", "POST", "/api/admin/doctors",
    { auth: adminAuth, body: { name: "Dr New", email: "t-new@healthnova.test", phone: "9000000010", password: "Passw0rd", specialization: "ENT", qualification: "MS" } }, 201);
  const newUser = await userModel.findOne({ email: "t-new@healthnova.test" });
  check("created doctor gets the doctor role", newUser?.role === "doctor", newUser?.role);
  await expectStatus("the new doctor can sign in", "POST", "/api/auth/login",
    { body: { email: "t-new@healthnova.test", password: "Passw0rd" } }, 200);
  await expectStatus("delete doctor", "DELETE", `/api/admin/doctors/${created.data._id}`, { auth: adminAuth }, 200);
  check("deleting a doctor removes its login account",
    (await userModel.findOne({ email: "t-new@healthnova.test" })) === null);

  await expectStatus("admin approves an appointment", "PATCH", `/api/admin/appointments/${mine._id}/status`, { auth: adminAuth, body: { status: "Approved" } }, 200);
  check("approval persisted", (await appointmentModel.findById(mine._id)).status === "Approved");
  await expectStatus("status must be in the enum", "PATCH", `/api/admin/appointments/${mine._id}/status`, { auth: adminAuth, body: { status: "Maybe" } }, 400);

  console.log("\n--- doctor, own data only ---");
  const list = await expectStatus("doctor lists appointments", "GET", "/api/doctor/appointments", { auth: doctorAuth }, 200);
  check("doctor sees only their own", list?.data?.length === 1 && String(list.data[0]._id) === String(mine._id));
  await expectStatus("doctor cannot read another doctor's appointment", "GET", `/api/doctor/appointments/${theirs._id}`, { auth: doctorAuth }, 404);
  await expectStatus("doctor cannot change another doctor's appointment", "PATCH", `/api/doctor/appointments/${theirs._id}/status`, { auth: doctorAuth, body: { status: "Approved" } }, 404);
  check("the other doctor's appointment is untouched",
    (await appointmentModel.findById(theirs._id)).status === "Pending");
  await expectStatus("doctor completes their own", "PATCH", `/api/doctor/appointments/${mine._id}/status`, { auth: doctorAuth, body: { status: "Completed" } }, 200);
  const dstats = await expectStatus("doctor stats", "GET", "/api/doctor/stats", { auth: doctorAuth }, 200);
  check("doctor stats count only their own",
    dstats?.data?.completedVisits === 1 && dstats.data.patientsSeen === 1, JSON.stringify(dstats?.data));
  const seen = await expectStatus("doctor reads a patient they have seen", "GET", `/api/doctor/patients/${patient._id}`, { auth: doctorAuth }, 200);
  check("patient details include visits and a predictions list",
    Array.isArray(seen?.data?.appointments) && Array.isArray(seen?.data?.predictions) && !("password" in (seen?.data?.patient || {})));
  await expectStatus("doctor cannot read an unrelated patient", "GET", `/api/doctor/patients/${stranger._id}`, { auth: doctorAuth }, 404);

  console.log("\n--- patient ---");
  const booked = await expectStatus("patient books", "POST", "/api/patient/appointments",
    { auth: patientAuth, body: { doctor: doctor._id, date: futureDay(7), time: "10:00 AM", reason: "Follow up" } }, 201);
  const saved = await appointmentModel.findById(booked.data._id);
  check("booking is attributed to the signed-in patient", String(saved.patient) === String(patient._id));
  check("booking starts Pending", saved.status === "Pending");

  const spoof = await call("POST", "/api/patient/appointments", {
    auth: patientAuth,
    body: { patient: String(stranger._id), doctor: doctor._id, date: futureDay(8), time: "11:00 AM" },
  });
  const spoofed = await appointmentModel.findById(spoof.body?.data?._id);
  check("a patient cannot book on someone else's behalf", String(spoofed?.patient) === String(patient._id));

  await expectStatus("patient cancels their own pending request", "DELETE", `/api/patient/appointments/${booked.data._id}`, { auth: patientAuth }, 200);
  check("cancelled appointment is gone", (await appointmentModel.findById(booked.data._id)) === null);
  await expectStatus("cannot cancel a completed appointment", "DELETE", `/api/patient/appointments/${mine._id}`, { auth: patientAuth }, 400);
  const named = await expectStatus("search finds a doctor by name", "GET", "/api/patient/doctors?search=Alex", { auth: patientAuth }, 200);
  check("name search returns that doctor", named?.data?.length === 1, `${named?.data?.length} returned`);

  console.log("\n--- registration and account ---");
  const badPhone = await expectStatus("a 9-digit phone is a readable 400", "POST", "/api/auth/register",
    { body: { name: "T", email: "t-short@healthnova.test", phone: "123456789", password: "Passw0rd" } }, 400);
  check("the message explains the rule", /10 digits/.test(badPhone?.message || ""), badPhone?.message);
  await expectStatus("a short password is rejected", "POST", "/api/auth/register",
    { body: { email: "t-pw@healthnova.test", phone: "9000000020", password: "abc" } }, 400);
  const registered = await expectStatus("register with a name", "POST", "/api/auth/register",
    { body: { name: "New Patient", email: "T-New.Patient@HealthNova.test", phone: "9000000021", password: "Passw0rd", gender: "Female" } }, 201);
  check("registration always creates a patient", registered?.user?.role === "patient");
  const signedIn = await expectStatus("sign-in ignores email case", "POST", "/api/auth/login",
    { body: { email: "t-new.patient@HEALTHNOVA.test", password: "Passw0rd" } }, 200);
  const meAuth = signedIn?.token;
  const me = await expectStatus("read own account", "GET", "/api/user/me", { auth: meAuth }, 200);
  check("own account has the name and no password", me?.data?.name === "New Patient" && !("password" in (me?.data || {})));
  await expectStatus("update own details", "PUT", "/api/user/me", { auth: meAuth, body: { name: "Renamed", role: "admin" } }, 200);
  const renamed = await userModel.findOne({ email: "t-new.patient@healthnova.test" });
  check("the name changed and the role did not", renamed?.name === "Renamed" && renamed?.role === "patient", renamed?.role);
  await expectStatus("an invalid phone on update is a 400", "PUT", "/api/user/me", { auth: meAuth, body: { phone: "12" } }, 400);
  const lower = await expectStatus("gender is accepted in any casing", "PUT", "/api/user/me", { auth: meAuth, body: { gender: "male", dob: "1990-05-01" } }, 200);
  check("gender is stored as the schema spells it", lower?.data?.gender === "Male", lower?.data?.gender);
  const cleared = await expectStatus("blank values clear optional fields", "PUT", "/api/user/me", { auth: meAuth, body: { gender: "", dob: "" } }, 200);
  check("gender and date of birth were removed", !cleared?.data?.gender && !cleared?.data?.dob, JSON.stringify(cleared?.data));
  await expectStatus("a past appointment date is refused", "POST", "/api/patient/appointments",
    { auth: patientAuth, body: { doctor: doctor._id, date: "2020-01-01", time: "10:00 AM" } }, 400);

  console.log("\n--- prediction (needs ml_service running) ---");
  await expectStatus("prediction rejects an unknown disease", "POST", "/api/patient/predictions",
    { auth: patientAuth, body: { disease: "flu", inputs: {} } }, 400);
  const forms = await call("GET", "/api/patient/prediction-models", { auth: patientAuth });
  if (forms.status === 503) {
    console.log("SKIP  prediction checks: the prediction service is not running (start ml_service to include them)");
  } else {
    check("all six prediction forms are listed", forms.status === 200 && forms.body?.data?.length === 6,
      `${forms.status} ${forms.body?.data?.length}`);
    const predicted = await expectStatus("run a real prediction", "POST", "/api/patient/predictions",
      { auth: patientAuth, body: { disease: "diabetes", inputs: { pregnancies: 2, glucose: 180, bloodPressure: 80, bmi: 35, age: 55 } } }, 201);
    check("the model's verdict is stored", ["Low", "Moderate", "High"].includes(predicted?.data?.riskLevel), predicted?.data?.riskLevel);
    const stored = await predictionModel.findById(predicted?.data?._id);
    check("stored under the patient with the display name", String(stored?.patient) === String(patient._id) && stored?.disease === "Diabetes");
    const invalid = await expectStatus("a missing required value names the field", "POST", "/api/patient/predictions",
      { auth: patientAuth, body: { disease: "diabetes", inputs: { bmi: 30 } } }, 400);
    check("the message names it", /required/.test(invalid?.message || ""), invalid?.message);
  }

  console.log("\n--- cleaning up ---");
  await Promise.all([
    userModel.deleteMany({}),
    doctorModel.deleteMany({}),
    appointmentModel.deleteMany({}),
    predictionModel.deleteMany({}),
  ]);
  console.log(`removed every document this run created from "${TEST_DB}"`);

  server.close();
  await mongoose.disconnect();

  const failed = results.filter((r) => !r.passed);
  console.log(`\n${results.length - failed.length}/${results.length} checks passed`);
  if (failed.length) console.log("failed:", failed.map((f) => f.name).join(", "));
  process.exit(failed.length ? 1 : 0);
}

main().catch(async (error) => {
  console.error("\n" + error.stack);
  if (server) server.close();
  await mongoose.disconnect().catch(() => {});
  process.exit(1);
});
