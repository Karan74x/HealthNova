import { useCallback, useEffect, useState } from "react";
import {
  CalendarCheck,
  CalendarClock,
  CheckCircle2,
  ShieldCheck,
  Users,
} from "lucide-react";
import StatCard from "../components/StatCard";
import LoadingState from "../components/LoadingState";
import ErrorState from "../components/ErrorState";
import Badge from "../components/Badge";
import { getDoctorDashboard } from "../api/userApi";
import { getErrorMessage } from "../api/axiosInstance";
import { useAuth } from "../hooks/useAuth";
import "./Dashboard.css";

/*
 * There is no Appointment model and no counting endpoint yet, so every figure
 * is marked pending rather than filled with an invented number.
 */
const PENDING_STATS = [
  { label: "Today's Appointments", icon: CalendarClock },
  { label: "Pending Requests", icon: CalendarCheck },
  { label: "Patients Seen", icon: Users },
  { label: "Completed Visits", icon: CheckCircle2 },
];

export default function DoctorDashboard() {
  const { user } = useAuth();
  const [status, setStatus] = useState("loading");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const loadDashboard = useCallback(async () => {
    setStatus("loading");
    setError("");
    try {
      const { data } = await getDoctorDashboard();
      setMessage(data.message);
      setStatus("ready");
    } catch (requestError) {
      setError(getErrorMessage(requestError, "Could not load the dashboard."));
      setStatus("error");
    }
  }, []);

  useEffect(() => {
    loadDashboard();
  }, [loadDashboard]);

  if (status === "loading") {
    return <LoadingState message="Loading dashboard" />;
  }

  if (status === "error") {
    return (
      <ErrorState
        title="Could not load the dashboard"
        message={error}
        onRetry={loadDashboard}
      />
    );
  }

  return (
    <>
      <div className="page-header">
        <h2>Welcome back</h2>
        <p className="page-subtitle">
          Signed in as {user.email} with doctor access.
        </p>
      </div>

      <section className="card dashboard-status">
        <span className="dashboard-status-icon" aria-hidden="true">
          <ShieldCheck size={22} />
        </span>
        <div>
          <p className="card-title">Backend connection verified</p>
          <p className="card-subtitle">
            GET /api/doctor/dashboard responded “{message}”, confirming the
            token is valid and the doctor role gate accepts this account. An
            administrator account calling the same route is refused with 403.
          </p>
        </div>
        <Badge variant="success">Connected</Badge>
      </section>

      <h3 className="dashboard-section-title">Overview</h3>
      <div className="dashboard-stats">
        {PENDING_STATS.map(({ label, icon }) => (
          <StatCard key={label} label={label} icon={icon} pending />
        ))}
      </div>

      <section className="card dashboard-note">
        <p className="card-title">What this area will hold</p>
        <p className="card-subtitle">
          The doctor workflow documented for HealthNova is: view assigned
          appointments, open an appointment to see its details and the
          patient’s information, accept or reject a request, and mark a
          completed consultation. None of it can be built yet, because the
          backend has no Doctor or Appointment model and no endpoint that
          returns appointments for the signed-in doctor. Authentication, the
          role gate and the profile screen are live; the four cards above and
          the disabled sidebar items stay empty until those endpoints exist.
        </p>
      </section>
    </>
  );
}
