/*
 * Exercises the real routes, middleware and controllers over HTTP, with the
 * Mongoose models swapped for an in-memory double.
 *
 * What this proves: every route is registered with the right method, the auth
 * and role gates behave, ownership is enforced, validation rejects bad input,
 * and the status codes and response shapes are what the dashboard expects.
 *
 * What it cannot prove: that the Mongoose queries themselves are right. That
 * needs a real database - see test/live.test.js.
 */
const path = require("path");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { buildRegistry, ObjectId } = require("./fakeModels");

// A calendar day a few days ahead, so booking tests never fall in the past
const futureDay = (days) => {
  const day = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
  return day.toISOString().slice(0, 10);
};

process.env.JWT_SECRET = "test-secret";

const registry = buildRegistry();

// Swap the models before the controllers require them
const modelPath = (file) => require.resolve(path.join(__dirname, "..", "src", "models", file));
require.cache[modelPath("userModel.js")] = { exports: registry.models.User };

const appointmentStub = registry.models.Appointment;
appointmentStub.APPOINTMENT_STATUSES = ["Pending", "Approved", "Rejected", "Completed"];
const predictionStub = registry.models.Prediction;
predictionStub.DISEASE_KEYS = {
  diabetes: "Diabetes",
  heart: "Heart Disease",
  liver: "Liver Disease",
  kidney: "Kidney Disease",
  stroke: "Stroke",
  hypertension: "Hypertension",
};
predictionStub.DISEASES = Object.values(predictionStub.DISEASE_KEYS);

require.cache[modelPath("doctorModel.js")] = { exports: registry.models.Doctor };
require.cache[modelPath("appointmentModel.js")] = { exports: appointmentStub };
require.cache[modelPath("predictionModel.js")] = { exports: predictionStub };

const http = require("http");
const app = require("../src/app.js");

// ------------------------------------------------------------------ helpers
let server;
let base;
let mlServer;
const mlCalls = [];

/*
 * Stand-in for ml_service: answers like the real one, and records what the
 * backend sent so the tests can check it was forwarded faithfully.
 */
function startFakePredictionService() {
  mlServer = http.createServer((req, res) => {
    let raw = "";
    req.on("data", (chunk) => { raw += chunk; });
    req.on("end", () => {
      const send = (status, body) => {
        res.writeHead(status, { "Content-Type": "application/json" });
        res.end(JSON.stringify(body));
      };
      if (req.method === "GET" && req.url === "/models") {
        return send(200, { data: [{ key: "diabetes", name: "Diabetes", features: [] }] });
      }
      const match = req.url.match(/^\/predict\/(\w+)$/);
      if (req.method === "POST" && match) {
        const { inputs } = JSON.parse(raw || "{}");
        mlCalls.push({ key: match[1], inputs });
        if (inputs.glucose === undefined) return send(422, { message: "Glucose (2-hour test) is required." });
        return send(200, {
          key: match[1], disease: "Diabetes", result: "High risk of diabetes", riskLevel: "High",
          probability: 0.81, confidence: 81, disclaimer: "not a diagnosis",
        });
      }
      send(404, { message: "not found" });
    });
  });
  return new Promise((resolve) => mlServer.listen(0, "127.0.0.1", () => {
    process.env.ML_SERVICE_URL = `http://127.0.0.1:${mlServer.address().port}`;
    resolve();
  }));
}

const token = (userId, role) => jwt.sign({ userId, role }, process.env.JWT_SECRET);

async function call(method, url, { auth, body } = {}) {
  const headers = { "Content-Type": "application/json" };
  if (auth) headers.Authorization = auth; // bare token, no Bearer prefix
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

const results = [];
function check(name, passed, detail = "") {
  results.push({ name, passed });
  // detail is only useful when something went wrong
  console.log(`${passed ? "PASS" : "FAIL"}  ${name}${!passed && detail ? "  — " + detail : ""}`);
}

async function expectStatus(name, method, url, options, expected) {
  const { status, body } = await call(method, url, options);
  check(name, status === expected, `expected ${expected}, got ${status} ${JSON.stringify(body)}`);
  return body;
}

// -------------------------------------------------------------------- seed
const adminId = new ObjectId();
const doctorUserId = new ObjectId();
const otherDoctorUserId = new ObjectId();
const patientId = new ObjectId();
const strangerId = new ObjectId();

async function seed() {
  const hashed = await bcrypt.hash("Passw0rd", 10);
  registry.models.User.rows.push(
    { _id: adminId, name: "Admin", email: "admin@healthnova.com", phone: "9000000001", password: hashed, role: "admin" },
    { _id: doctorUserId, name: "Dr Alex Doe", email: "doctor@healthnova.com", phone: "9000000003", password: hashed, role: "doctor" },
    { _id: otherDoctorUserId, name: "Dr John Doe", email: "doctor2@healthnova.com", phone: "9000000004", password: hashed, role: "doctor" },
    { _id: patientId, name: "Ravi Patel", email: "patient@healthnova.com", phone: "9000000002", password: hashed, role: "patient" },
    { _id: strangerId, name: "Other Patient", email: "other@healthnova.com", phone: "9000000005", password: hashed, role: "patient" },
  );

  const doctorId = new ObjectId();
  const otherDoctorId = new ObjectId();
  registry.models.Doctor.rows.push(
    { _id: doctorId, user: doctorUserId, specialization: "Cardiologist", qualification: "MD", experience: 12, hospital: "City Care", fee: 500 },
    { _id: otherDoctorId, user: otherDoctorUserId, specialization: "Dentist", qualification: "BDS", experience: 5, hospital: "Smile Clinic", fee: 300 },
  );

  const mineId = new ObjectId();
  const theirsId = new ObjectId();
  registry.models.Appointment.rows.push(
    { _id: mineId, patient: patientId, doctor: doctorId, date: new Date(), time: "12:30 PM", reason: "Checkup", status: "Pending" },
    { _id: theirsId, patient: strangerId, doctor: otherDoctorId, date: new Date(), time: "10:00 AM", reason: "Cleaning", status: "Pending" },
  );

  registry.models.Prediction.rows.push({
    _id: new ObjectId(), patient: patientId, disease: "Diabetes",
    inputs: { glucose: 140 }, result: "High risk", riskLevel: "High", confidence: 82,
    createdAt: new Date(),
  });

  return { doctorId, otherDoctorId, mineId, theirsId };
}

// -------------------------------------------------------------------- tests
async function main() {
  const ids = await seed();
  await startFakePredictionService();

  server = app.listen(0);
  await new Promise((resolve) => server.once("listening", resolve));
  base = `http://127.0.0.1:${server.address().port}`;

  const adminAuth = token(adminId, "admin");
  const doctorAuth = token(ids ? doctorUserId : null, "doctor");
  const otherDoctorAuth = token(otherDoctorUserId, "doctor");
  const patientAuth = token(patientId, "patient");

  console.log("\n--- authentication and role gates ---");
  await expectStatus("no token is refused", "GET", "/api/admin/stats", {}, 401);
  await expectStatus("bad token is refused", "GET", "/api/admin/stats", { auth: "not-a-token" }, 401);
  await expectStatus("patient cannot reach admin routes", "GET", "/api/admin/stats", { auth: patientAuth }, 403);
  await expectStatus("doctor cannot reach admin routes", "GET", "/api/admin/stats", { auth: doctorAuth }, 403);
  await expectStatus("admin cannot reach doctor routes", "GET", "/api/doctor/appointments", { auth: adminAuth }, 403);
  await expectStatus("doctor cannot reach patient routes", "GET", "/api/patient/appointments", { auth: doctorAuth }, 403);

  console.log("\n--- admin ---");
  const stats = await expectStatus("stats", "GET", "/api/admin/stats", { auth: adminAuth }, 200);
  check("stats counts are right",
    stats?.data?.patients === 2 && stats.data.doctors === 2 && stats.data.appointments === 2 && stats.data.predictions === 1,
    JSON.stringify(stats?.data));

  const doctors = await expectStatus("list doctors", "GET", "/api/admin/doctors", { auth: adminAuth }, 200);
  check("doctors populate their user account", doctors?.data?.[0]?.user?.email !== undefined);
  check("password never leaves the server", !JSON.stringify(doctors).includes("$2"), "hash found in response");

  await expectStatus("doctor 404 on unknown id", "GET", `/api/admin/doctors/${new ObjectId()}`, { auth: adminAuth }, 404);
  await expectStatus("doctor 404 on malformed id", "GET", "/api/admin/doctors/not-an-id", { auth: adminAuth }, 404);

  await expectStatus("create doctor needs credentials", "POST", "/api/admin/doctors", { auth: adminAuth, body: { email: "x@y.com" } }, 400);
  await expectStatus("create doctor rejects duplicate email", "POST", "/api/admin/doctors",
    { auth: adminAuth, body: { email: "doctor@healthnova.com", phone: "9000000009", password: "Passw0rd", specialization: "ENT", qualification: "MS" } }, 400);

  const created = await expectStatus("create doctor", "POST", "/api/admin/doctors",
    { auth: adminAuth, body: { name: "Dr New", email: "new@healthnova.com", phone: "9000000010", password: "Passw0rd", specialization: "ENT", qualification: "MS" } }, 201);
  const newDoctorUser = registry.models.User.rows.find((u) => u.email === "new@healthnova.com");
  check("created doctor gets the doctor role", newDoctorUser?.role === "doctor", newDoctorUser?.role);
  check("created doctor password is hashed", newDoctorUser?.password?.startsWith("$2"));

  await expectStatus("update doctor", "PUT", `/api/admin/doctors/${created.data._id}`, { auth: adminAuth, body: { fee: 750 } }, 200);
  await expectStatus("delete doctor", "DELETE", `/api/admin/doctors/${created.data._id}`, { auth: adminAuth }, 200);
  check("deleting a doctor removes its login account",
    !registry.models.User.rows.some((u) => u.email === "new@healthnova.com"));

  await expectStatus("list patients", "GET", "/api/admin/patients", { auth: adminAuth }, 200);
  await expectStatus("appointments reject an unknown status filter", "GET", "/api/admin/appointments?status=Nope", { auth: adminAuth }, 400);
  await expectStatus("list appointments", "GET", "/api/admin/appointments", { auth: adminAuth }, 200);
  await expectStatus("status must be in the enum", "PATCH", `/api/admin/appointments/${ids.mineId}/status`, { auth: adminAuth, body: { status: "Maybe" } }, 400);
  await expectStatus("admin approves an appointment", "PATCH", `/api/admin/appointments/${ids.mineId}/status`, { auth: adminAuth, body: { status: "Approved" } }, 200);
  check("approval persisted",
    registry.models.Appointment.rows.find((a) => String(a._id) === String(ids.mineId)).status === "Approved");
  await expectStatus("list predictions", "GET", "/api/admin/predictions", { auth: adminAuth }, 200);

  console.log("\n--- doctor, own data only ---");
  const mine = await expectStatus("doctor lists appointments", "GET", "/api/doctor/appointments", { auth: doctorAuth }, 200);
  check("doctor sees only their own", mine?.data?.length === 1 && String(mine.data[0]._id) === String(ids.mineId),
    `${mine?.data?.length} returned`);
  await expectStatus("doctor reads their own appointment", "GET", `/api/doctor/appointments/${ids.mineId}`, { auth: doctorAuth }, 200);
  await expectStatus("doctor cannot read another doctor's appointment", "GET", `/api/doctor/appointments/${ids.theirsId}`, { auth: doctorAuth }, 404);
  await expectStatus("doctor cannot change another doctor's appointment", "PATCH", `/api/doctor/appointments/${ids.theirsId}/status`, { auth: doctorAuth, body: { status: "Approved" } }, 404);
  check("the other doctor's appointment is untouched",
    registry.models.Appointment.rows.find((a) => String(a._id) === String(ids.theirsId)).status === "Pending");
  await expectStatus("doctor cannot set Pending", "PATCH", `/api/doctor/appointments/${ids.mineId}/status`, { auth: doctorAuth, body: { status: "Pending" } }, 400);
  await expectStatus("doctor completes their own", "PATCH", `/api/doctor/appointments/${ids.mineId}/status`, { auth: doctorAuth, body: { status: "Completed" } }, 200);
  const seen = await expectStatus("doctor reads a patient they have seen", "GET", `/api/doctor/patients/${patientId}`, { auth: doctorAuth }, 200);
  check("patient details include visits and risk checks",
    seen?.data?.appointments?.length === 1 && seen?.data?.predictions?.length === 1 && !seen?.data?.patient?.password);
  await expectStatus("doctor cannot read an unrelated patient", "GET", `/api/doctor/patients/${strangerId}`, { auth: doctorAuth }, 404);
  const dstats = await expectStatus("doctor stats", "GET", "/api/doctor/stats", { auth: doctorAuth }, 200);
  check("doctor stats count only their own", dstats?.data?.completedVisits === 1 && dstats.data.patientsSeen === 1,
    JSON.stringify(dstats?.data));
  await expectStatus("doctor profile", "GET", "/api/doctor/profile", { auth: doctorAuth }, 200);
  await expectStatus("doctor updates own profile", "PUT", "/api/doctor/profile", { auth: doctorAuth, body: { fee: 600 } }, 200);
  const other = await expectStatus("second doctor sees only theirs", "GET", "/api/doctor/appointments", { auth: otherDoctorAuth }, 200);
  check("second doctor's list is separate", other?.data?.length === 1 && String(other.data[0]._id) === String(ids.theirsId));

  console.log("\n--- patient ---");
  await expectStatus("patient browses doctors", "GET", "/api/patient/doctors", { auth: patientAuth }, 200);
  await expectStatus("booking needs a doctor and time", "POST", "/api/patient/appointments", { auth: patientAuth, body: { reason: "x" } }, 400);
  await expectStatus("booking rejects unknown doctor", "POST", "/api/patient/appointments", { auth: patientAuth, body: { doctor: new ObjectId(), date: futureDay(7), time: "10:00" } }, 404);
  const booked = await expectStatus("patient books", "POST", "/api/patient/appointments",
    { auth: patientAuth, body: { doctor: ids.doctorId, date: futureDay(7), time: "10:00 AM", reason: "Follow up" } }, 201);
  check("booking is attributed to the signed-in patient",
    String(registry.models.Appointment.rows.find((a) => String(a._id) === String(booked.data._id)).patient) === String(patientId));
  check("booking starts Pending", booked?.data?.status === "Pending");
  check("a calendar day is stored at midday UTC",
    new Date(booked?.data?.date).toISOString() === `${futureDay(7)}T12:00:00.000Z`, booked?.data?.date);
  await expectStatus("booking rejects a past date", "POST", "/api/patient/appointments",
    { auth: patientAuth, body: { doctor: ids.doctorId, date: "2020-01-01", time: "10:00 AM" } }, 400);

  const spoof = await call("POST", "/api/patient/appointments", {
    auth: patientAuth,
    body: { patient: String(strangerId), doctor: ids.doctorId, date: futureDay(8), time: "11:00 AM" },
  });
  const spoofed = registry.models.Appointment.rows.find((a) => String(a._id) === String(spoof.body?.data?._id));
  check("a patient cannot book on someone else's behalf", String(spoofed?.patient) === String(patientId),
    `booked for ${spoofed?.patient}`);

  const named = await expectStatus("search matches a doctor's name", "GET", "/api/patient/doctors?search=Alex", { auth: patientAuth }, 200);
  check("name search finds only that doctor", named?.data?.length === 1, `${named?.data?.length} returned`);
  await expectStatus("search text is not treated as a regex", "GET", "/api/patient/doctors?search=(", { auth: patientAuth }, 200);
  await expectStatus("admin search text is not treated as a regex", "GET", "/api/admin/patients?search=*", { auth: adminAuth }, 200);

  console.log("\n--- cancelling ---");
  await expectStatus("patient cancels their own pending request", "DELETE", `/api/patient/appointments/${booked.data._id}`, { auth: patientAuth }, 200);
  check("cancelled appointment is gone",
    !registry.models.Appointment.rows.some((a) => String(a._id) === String(booked.data._id)));
  await expectStatus("cannot cancel a completed appointment", "DELETE", `/api/patient/appointments/${ids.mineId}`, { auth: patientAuth }, 400);
  await expectStatus("cannot cancel another patient's appointment", "DELETE", `/api/patient/appointments/${ids.theirsId}`, { auth: patientAuth }, 404);

  console.log("\n--- prediction, via the prediction service ---");
  await expectStatus("prediction forms come from the service", "GET", "/api/patient/prediction-models", { auth: patientAuth }, 200);
  await expectStatus("prediction rejects an unknown disease", "POST", "/api/patient/predictions", { auth: patientAuth, body: { disease: "flu", inputs: {} } }, 400);
  await expectStatus("prediction needs inputs", "POST", "/api/patient/predictions", { auth: patientAuth, body: { disease: "diabetes" } }, 400);
  const predicted = await expectStatus("patient runs a prediction", "POST", "/api/patient/predictions",
    { auth: patientAuth, body: { disease: "diabetes", inputs: { glucose: 130, result: "Low risk" } } }, 201);
  check("inputs are forwarded to the service unchanged", mlCalls.at(-1)?.inputs?.glucose === 130);
  check("the stored result is the service's, not the client's", predicted?.data?.result === "High risk of diabetes",
    predicted?.data?.result);
  check("stored disease is the display name", predicted?.data?.disease === "Diabetes");
  check("the disclaimer is passed on", predicted?.disclaimer === "not a diagnosis");
  const invalid = await expectStatus("a value the service rejects is a 400 naming the field", "POST", "/api/patient/predictions",
    { auth: patientAuth, body: { disease: "diabetes", inputs: { bmi: 30 } } }, 400);
  check("the field is named", invalid?.message?.includes("Glucose"), invalid?.message);
  await expectStatus("patient reads own predictions", "GET", "/api/patient/predictions", { auth: patientAuth }, 200);

  const realUrl = process.env.ML_SERVICE_URL;
  process.env.ML_SERVICE_URL = "http://127.0.0.1:9";
  const down = await expectStatus("a stopped prediction service is a clear 503", "POST", "/api/patient/predictions",
    { auth: patientAuth, body: { disease: "diabetes", inputs: { glucose: 120 } } }, 503);
  check("503 explains what to start", down?.message?.includes("ml_service"), down?.message);
  process.env.ML_SERVICE_URL = realUrl;

  console.log("\n--- own account ---");
  const me = await expectStatus("patient reads own account", "GET", "/api/user/me", { auth: patientAuth }, 200);
  check("own account has the name and no password", me?.data?.name === "Ravi Patel" && !("password" in (me?.data || {})));
  await expectStatus("patient updates own details", "PUT", "/api/user/me", { auth: patientAuth, body: { name: "Ravi K Patel", role: "admin" } }, 200);
  const updatedUser = registry.models.User.rows.find((u) => String(u._id) === String(patientId));
  check("the name changed", updatedUser?.name === "Ravi K Patel");
  check("the role cannot be self-assigned", updatedUser?.role === "patient", updatedUser?.role);
  await expectStatus("gender is accepted in any casing", "PUT", "/api/user/me", { auth: patientAuth, body: { gender: "OTHER", dob: "1990-05-01" } }, 200);
  check("gender is stored as the schema spells it", updatedUser?.gender === "other", updatedUser?.gender);
  await expectStatus("blank values clear optional fields", "PUT", "/api/user/me", { auth: patientAuth, body: { gender: "", dob: "" } }, 200);
  check("gender and date of birth were cleared", !("gender" in updatedUser) && !("dob" in updatedUser), JSON.stringify(updatedUser));
  await expectStatus("own account needs a token", "GET", "/api/user/me", {}, 401);

  console.log("\n--- error responses ---");
  const missing = await expectStatus("unknown route is a JSON 404", "GET", "/api/nope", {}, 404);
  check("404 body is JSON", typeof missing?.message === "string");
  const badJson = await fetch(base + "/api/auth/login", {
    method: "POST", headers: { "Content-Type": "application/json" }, body: "{not json",
  });
  check("malformed JSON is a JSON 400", badJson.status === 400 && (await badJson.json()).message.includes("JSON"));
  const preflight = await fetch(base + "/api/auth/login", {
    method: "OPTIONS",
    headers: { Origin: "http://localhost:51234", "Access-Control-Request-Method": "POST",
      "Access-Control-Request-Headers": "content-type,authorization" },
  });
  check("browser preflight is allowed (Flutter web)", preflight.status === 204 &&
    preflight.headers.get("access-control-allow-origin") !== null &&
    /authorization/i.test(preflight.headers.get("access-control-allow-headers") || ""));

  console.log("\n--- endpoints that already existed ---");
  await expectStatus("admin dashboard", "GET", "/api/admin/dashboard", { auth: adminAuth }, 200);
  await expectStatus("doctor dashboard", "GET", "/api/doctor/dashboard", { auth: doctorAuth }, 200);
  await expectStatus("patient dashboard", "GET", "/api/patient/dashboard", { auth: patientAuth }, 200);
  await expectStatus("user profile", "GET", "/api/user/profile", { auth: adminAuth }, 200);

  server.close();
  mlServer.close();

  const failed = results.filter((r) => !r.passed);
  console.log(`\n${results.length - failed.length}/${results.length} checks passed`);
  if (failed.length) {
    console.log("failed:", failed.map((f) => f.name).join(", "));
  }
  process.exit(failed.length ? 1 : 0);
}

main().catch((error) => {
  console.error(error);
  if (server) server.close();
  process.exit(1);
});
