/*
 * Demo data, so the dashboards and the app have something to show.
 *
 *   npm run seed             add demo doctors, patients, appointments, predictions
 *   npm run seed -- --remove delete everything the seed created
 *
 * Safe to run more than once: nothing is duplicated. Demo accounts use the
 * @healthnova.demo domain, which is how --remove finds them, so it never
 * touches real accounts.
 *
 * It also fixes one thing in real data: an account whose role was set to
 * "doctor" by hand in Atlas has no doctor profile, so the doctor dashboard has
 * nothing to load. Such accounts get a basic profile they can edit later.
 */
require("dotenv").config();

const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const userModel = require("../src/models/userModel.js");
const doctorModel = require("../src/models/doctorModel.js");
const appointmentModel = require("../src/models/appointmentModel.js");
const predictionModel = require("../src/models/predictionModel.js");
const predictionService = require("../src/services/predictionService.js");

const { DISEASE_KEYS } = predictionModel;
const DEMO_DOMAIN = "@healthnova.demo";
const isDemo = { email: { $regex: "@healthnova\\.demo$" } };

const DOCTORS = [
  { name: "Dr Alex Doe", email: "alex.doe", phone: "9000000101", specialization: "Cardiologist",
    qualification: "MBBS, MD, DM", experience: 12, hospital: "City Care Hospital", fee: 500,
    availability: "Mon–Fri, 10:00–14:00" },
  { name: "Dr John Doe", email: "john.doe", phone: "9000000102", specialization: "Cardiologist",
    qualification: "MBBS, MD", experience: 9, hospital: "City Care Hospital", fee: 450,
    availability: "Mon–Sat, 16:00–19:00" },
  { name: "Dr Sarah Smith", email: "sarah.smith", phone: "9000000103", specialization: "Dermatologist",
    qualification: "MBBS, DDVL", experience: 6, hospital: "Skin & Care Clinic", fee: 400,
    availability: "Tue–Sat, 11:00–15:00" },
  { name: "Dr Meera Shah", email: "meera.shah", phone: "9000000104", specialization: "Endocrinologist",
    qualification: "MBBS, MD, DM", experience: 8, hospital: "Sunrise Diabetes Centre", fee: 600,
    availability: "Mon–Fri, 09:00–13:00" },
];

const PATIENTS = [
  { name: "Ravi Patel", email: "ravi.patel", phone: "9825012345", gender: "Male", dob: "1974-03-12" },
  { name: "Sarah Khan", email: "sarah.khan", phone: "9825067890", gender: "Female", dob: "1990-07-22" },
  { name: "Kevin Smith", email: "kevin.smith", phone: "9714455667", gender: "Male", dob: "1961-11-02" },
  { name: "Ama Watson", email: "ama.watson", phone: "9909887766", gender: "Female", dob: "1985-01-30" },
  { name: "Arjun Mehta", email: "arjun.mehta", phone: "9033221144", gender: "Male", dob: "1998-05-17" },
];

// [patient index, doctor index, days from today, time, reason, status]
const APPOINTMENTS = [
  [0, 0, 0, "12:30 PM", "Chest pain follow-up", "Pending"],
  [1, 0, 0, "01:15 PM", "Routine check-up", "Pending"],
  [2, 0, 2, "10:00 AM", "Blood pressure review", "Approved"],
  [4, 0, -3, "11:00 AM", "ECG report discussion", "Completed"],
  [2, 1, 1, "05:00 PM", "Palpitations", "Approved"],
  [3, 2, -5, "11:30 AM", "Skin allergy", "Completed"],
  [1, 2, 4, "12:00 PM", "Eczema follow-up", "Pending"],
  [0, 3, -1, "09:30 AM", "High sugar readings", "Completed"],
  [3, 3, 3, "10:30 AM", "Thyroid test results", "Pending"],
  [4, 1, -7, "06:00 PM", "Shortness of breath", "Rejected"],
];

// [patient index, disease key, inputs]
const PREDICTIONS = [
  [0, "diabetes", { pregnancies: 0, glucose: 168, bloodPressure: 84, bmi: 31.2, age: 52 }],
  [0, "heart", { age: 52, sex: "male", chestPain: "typical", restingBloodPressure: 150,
    cholesterol: 260, highFastingSugar: "yes" }],
  [1, "diabetes", { pregnancies: 1, glucose: 92, bloodPressure: 70, bmi: 23.5, age: 36 }],
  [2, "hypertension", { sex: "male", age: 64, bmi: 30.5, currentSmoker: "yes", diabetes: "no",
    cigarettesPerDay: 10 }],
  [2, "stroke", { gender: "male", age: 64, hypertension: "yes", heartDisease: "no", avgGlucose: 140,
    bmi: 30.5, smokingStatus: "current" }],
  [3, "liver", { age: 41, gender: "female", totalBilirubin: 0.8, alkalinePhosphatase: 190, alt: 25,
    ast: 30, albumin: 4.0 }],
  [4, "kidney", { age: 28, bloodPressure: 70, serumCreatinine: 0.9, hemoglobin: 15.2,
    hypertension: "no", diabetes: "no" }],
];

const atDay = (offset) => {
  const date = new Date();
  date.setHours(12, 0, 0, 0);
  date.setDate(date.getDate() + offset);
  return date;
};

async function ensureUser(details, role, password) {
  const email = details.email + DEMO_DOMAIN;
  const existing = await userModel.findOne({ email });
  if (existing) return { user: existing, created: false };
  const user = await userModel.create({
    name: details.name,
    email,
    phone: details.phone,
    gender: details.gender,
    dob: details.dob,
    password: await bcrypt.hash(password, 10),
    role,
  });
  return { user, created: true };
}

async function seed() {
  const report = [];

  // 1. An administrator, only if the database has none
  if (!(await userModel.exists({ role: "admin" }))) {
    await userModel.create({
      name: "Admin",
      email: "admin@healthnova.com",
      phone: "9000000001",
      password: await bcrypt.hash("Admin@123", 10),
      role: "admin",
    });
    report.push("created administrator admin@healthnova.com / Admin@123");
  }

  // 2. Demo doctors, each with a login account and a profile
  const doctors = [];
  for (const details of DOCTORS) {
    const { user, created } = await ensureUser(details, "doctor", "Doctor@123");
    let profile = await doctorModel.findOne({ user: user._id });
    if (!profile) {
      const { name, email, phone, ...professional } = details; // eslint-disable-line no-unused-vars
      profile = await doctorModel.create({ user: user._id, ...professional });
    }
    doctors.push(profile);
    if (created) report.push(`created doctor ${user.email}`);
  }

  // 3. Real doctor accounts that never got a profile
  const withProfile = (await doctorModel.find().select("user")).map((d) => String(d.user));
  const orphans = await userModel.find({ role: "doctor", _id: { $nin: withProfile } });
  for (const user of orphans) {
    await doctorModel.create({
      user: user._id,
      specialization: "General Physician",
      qualification: "MBBS",
      experience: 0,
      availability: "Set your availability in Profile",
    });
    report.push(`added a doctor profile to ${user.email} (edit it under Profile)`);
  }

  // 4. Demo patients
  const patients = [];
  for (const details of PATIENTS) {
    const { user, created } = await ensureUser(details, "patient", "Patient@123");
    patients.push(user);
    if (created) report.push(`created patient ${user.email}`);
  }

  // 5. Appointments, once
  const patientIds = patients.map((p) => p._id);
  if (!(await appointmentModel.exists({ patient: { $in: patientIds } }))) {
    for (const [p, d, day, time, reason, status] of APPOINTMENTS) {
      await appointmentModel.create({
        patient: patients[p]._id, doctor: doctors[d]._id, date: atDay(day), time, reason, status,
      });
    }
    report.push(`created ${APPOINTMENTS.length} appointments`);
  }

  // 6. Predictions, produced by the real models, once
  if (!(await predictionModel.exists({ patient: { $in: patientIds } }))) {
    let made = 0;
    try {
      for (const [p, key, inputs] of PREDICTIONS) {
        const outcome = await predictionService.predict(key, inputs);
        await predictionModel.create({
          patient: patients[p]._id, disease: DISEASE_KEYS[key], inputs,
          result: outcome.result, riskLevel: outcome.riskLevel, confidence: outcome.confidence,
        });
        made += 1;
      }
      report.push(`created ${made} predictions using the prediction service`);
    } catch (error) {
      report.push(`skipped predictions: ${error.message}`);
    }
  }

  return report;
}

async function remove() {
  const demoUsers = await userModel.find(isDemo).select("_id");
  const ids = demoUsers.map((u) => u._id);
  const demoDoctors = (await doctorModel.find({ user: { $in: ids } }).select("_id")).map((d) => d._id);

  const appointments = await appointmentModel.deleteMany({
    $or: [{ patient: { $in: ids } }, { doctor: { $in: demoDoctors } }],
  });
  const predictions = await predictionModel.deleteMany({ patient: { $in: ids } });
  const profiles = await doctorModel.deleteMany({ user: { $in: ids } });
  const users = await userModel.deleteMany(isDemo);

  return [
    `removed ${users.deletedCount} demo accounts, ${profiles.deletedCount} doctor profiles,`,
    `${appointments.deletedCount} appointments and ${predictions.deletedCount} predictions`,
  ];
}

async function main() {
  if (!process.env.MONGO_URI) {
    console.error("MONGO_URI is not set in backend/.env");
    process.exit(1);
  }
  await mongoose.connect(process.env.MONGO_URI);

  const removing = process.argv.includes("--remove");
  const report = removing ? await remove() : await seed();

  console.log(report.length ? report.map((line) => "  " + line).join("\n") : "  nothing to do, demo data already present");
  if (!removing) {
    console.log("\nSign in with:");
    console.log("  admin    admin@healthnova.com      Admin@123  (if the seed created it)");
    console.log(`  doctor   alex.doe${DEMO_DOMAIN}     Doctor@123`);
    console.log(`  patient  ravi.patel${DEMO_DOMAIN}   Patient@123  (mobile app)`);
  }
  await mongoose.disconnect();
}

main().catch(async (error) => {
  console.error(error.message);
  await mongoose.disconnect().catch(() => {});
  process.exit(1);
});
