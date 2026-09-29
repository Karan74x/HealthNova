import { useCallback, useEffect, useState } from "react";
import {
  Activity,
  CalendarCheck,
  ShieldCheck,
  Stethoscope,
  Users,
} from "lucide-react";
import StatCard from "../components/StatCard";
import LoadingState from "../components/LoadingState";
import ErrorState from "../components/ErrorState";
import Badge from "../components/Badge";
import { getAdminDashboard } from "../api/userApi";
import { getErrorMessage } from "../api/axiosInstance";
import { useAuth } from "../hooks/useAuth";
import "./Dashboard.css";

/*
 * The backend exposes no counting endpoints yet, so each statistic is marked
 * pending rather than filled with an invented number.
 */
const PENDING_STATS = [
  { label: "Total Patients", icon: Users },
  { label: "Total Doctors", icon: Stethoscope },
  { label: "Total Appointments", icon: CalendarCheck },
  { label: "Total Predictions", icon: Activity },
];

export default function AdminDashboard() {
  const { user } = useAuth();
  const [status, setStatus] = useState("loading");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const loadDashboard = useCallback(async () => {
    setStatus("loading");
    setError("");
    try {
      const { data } = await getAdminDashboard();
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
          Signed in as {user.email} with administrator access.
        </p>
      </div>

      <section className="card dashboard-status">
        <span className="dashboard-status-icon" aria-hidden="true">
          <ShieldCheck size={22} />
        </span>
        <div>
          <p className="card-title">Backend connection verified</p>
          <p className="card-subtitle">
            GET /api/admin/dashboard responded “{message}”, confirming the token
            is valid and the admin role gate accepts this account.
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
        <p className="card-title">Why these figures are empty</p>
        <p className="card-subtitle">
          The backend currently provides authentication and role-protected
          routes only. There are no Doctor, Appointment or Prediction models and
          no endpoints that return counts or records, so these cards, and the
          disabled items in the sidebar, stay empty until those endpoints exist.
        </p>
      </section>
    </>
  );
}
