import { useState } from "react";
import { Link } from "react-router-dom";
import { Activity, ArrowRight, CalendarCheck, Check, Stethoscope, Users, X } from "lucide-react";
import StatCard from "../components/StatCard";
import DataTable from "../components/DataTable";
import LoadingState from "../components/LoadingState";
import ErrorState from "../components/ErrorState";
import Badge from "../components/Badge";
import { useToast } from "../components/Toast";
import { useResource } from "../hooks/useResource";
import { useAuth } from "../hooks/useAuth";
import { getStats, listAppointments, listPredictions, setAppointmentStatus } from "../api/adminApi";
import { getErrorMessage } from "../api/axiosInstance";
import { RISK_VARIANT, doctorName, formatDate, formatDateTime, personName } from "../utils/format";
import "./Dashboard.css";

const RECENT_LIMIT = 5;

export default function AdminDashboard() {
  const { user } = useAuth();
  const notify = useToast();
  const [busyId, setBusyId] = useState(null);

  const stats = useResource(getStats, [], "Could not load the statistics.");
  const pending = useResource(() => listAppointments("Pending"), [], "Could not load pending appointments.");
  const predictions = useResource(() => listPredictions(), [], "Could not load recent predictions.");

  const decide = async (appointment, status) => {
    setBusyId(appointment._id);
    try {
      await setAppointmentStatus(appointment._id, status);
      notify(status === "Approved" ? "Appointment approved." : "Appointment rejected.");
      await pending.reload({ quiet: true });
    } catch (requestError) {
      notify(getErrorMessage(requestError, "Could not update the appointment."), "danger");
    } finally {
      setBusyId(null);
    }
  };

  const figures = stats.data || {};
  const cards = [
    { label: "Total Patients", icon: Users, value: figures.patients, to: "/admin/patients" },
    { label: "Total Doctors", icon: Stethoscope, value: figures.doctors, to: "/admin/doctors" },
    { label: "Total Appointments", icon: CalendarCheck, value: figures.appointments, to: "/admin/appointments" },
    { label: "Total Predictions", icon: Activity, value: figures.predictions, to: "/admin/predictions" },
  ];

  const pendingColumns = [
    { key: "patient", label: "Patient", render: (row) => <span className="table-primary">{personName(row.patient)}</span> },
    { key: "doctor", label: "Doctor", render: (row) => doctorName(row.doctor) },
    {
      key: "when",
      label: "Requested for",
      render: (row) => (
        <div>
          <div>{formatDate(row.date)}</div>
          <div className="table-muted">{row.time}</div>
        </div>
      ),
    },
    {
      key: "actions",
      label: "Actions",
      render: (row) => (
        <div className="table-actions">
          <button
            type="button"
            className="btn btn-primary btn-sm"
            disabled={busyId === row._id}
            onClick={() => decide(row, "Approved")}
          >
            <Check size={14} /> Approve
          </button>
          <button
            type="button"
            className="btn btn-secondary btn-sm"
            disabled={busyId === row._id}
            onClick={() => decide(row, "Rejected")}
          >
            <X size={14} /> Reject
          </button>
        </div>
      ),
    },
  ];

  const predictionColumns = [
    { key: "patient", label: "Patient", render: (row) => <span className="table-primary">{personName(row.patient)}</span> },
    { key: "disease", label: "Disease" },
    {
      key: "risk",
      label: "Risk",
      render: (row) => <Badge variant={RISK_VARIANT[row.riskLevel] || "neutral"}>{row.riskLevel || "—"}</Badge>,
    },
    { key: "createdAt", label: "When", render: (row) => formatDateTime(row.createdAt) },
  ];

  return (
    <>
      <div className="page-header">
        <h2>Welcome back{user.name ? `, ${user.name.split(" ")[0]}` : ""}</h2>
        <p className="page-subtitle">An overview of HealthNova today.</p>
      </div>

      {stats.status === "error" ? (
        <ErrorState title="Could not load the statistics" message={stats.error} onRetry={stats.reload} />
      ) : (
        <div className="dashboard-stats">
          {cards.map((card) => (
            <StatCard key={card.label} {...card} value={stats.status === "ready" ? card.value : null} />
          ))}
        </div>
      )}

      <section className="dashboard-section">
        <div className="dashboard-section-head">
          <h3>Awaiting approval</h3>
          <Link to="/admin/appointments" className="dashboard-section-link">
            All appointments <ArrowRight size={16} />
          </Link>
        </div>
        {pending.status === "loading" && <LoadingState message="Loading requests" />}
        {pending.status === "error" && <ErrorState message={pending.error} onRetry={pending.reload} />}
        {pending.status === "ready" && (
          <>
            <DataTable
              columns={pendingColumns}
              rows={pending.data.slice(0, RECENT_LIMIT)}
              empty="No appointment requests are waiting. New bookings from the app appear here."
            />
            {pending.data.length > RECENT_LIMIT && (
              <p className="dashboard-more">
                Showing {RECENT_LIMIT} of {pending.data.length} pending requests.
              </p>
            )}
          </>
        )}
      </section>

      <section className="dashboard-section">
        <div className="dashboard-section-head">
          <h3>Recent predictions</h3>
          <Link to="/admin/predictions" className="dashboard-section-link">
            All predictions <ArrowRight size={16} />
          </Link>
        </div>
        {predictions.status === "loading" && <LoadingState message="Loading predictions" />}
        {predictions.status === "error" && <ErrorState message={predictions.error} onRetry={predictions.reload} />}
        {predictions.status === "ready" && (
          <DataTable
            columns={predictionColumns}
            rows={predictions.data.slice(0, RECENT_LIMIT)}
            empty="No predictions yet. They appear here when patients run a risk check in the app."
          />
        )}
      </section>
    </>
  );
}
