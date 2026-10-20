import { useState } from "react";
import { Link } from "react-router-dom";
import { ArrowRight, CalendarCheck, CalendarClock, Check, CheckCircle2, Users, X } from "lucide-react";
import StatCard from "../components/StatCard";
import DataTable from "../components/DataTable";
import LoadingState from "../components/LoadingState";
import ErrorState from "../components/ErrorState";
import Badge from "../components/Badge";
import { useToast } from "../components/Toast";
import { useResource } from "../hooks/useResource";
import { useAuth } from "../hooks/useAuth";
import { getStats, listAppointments, setAppointmentStatus } from "../api/doctorApi";
import { getErrorMessage } from "../api/axiosInstance";
import { STATUS_VARIANT, formatDate, isToday, minutesOf, personName } from "../utils/format";
import "./Dashboard.css";

export default function DoctorDashboard() {
  const { user } = useAuth();
  const notify = useToast();
  const [busyId, setBusyId] = useState(null);

  const stats = useResource(getStats, [], "Could not load your statistics.");
  // One request for both lists below; the backend scopes it to this doctor
  const appointments = useResource(() => listAppointments(), [], "Could not load your appointments.");

  const decide = async (appointment, status) => {
    setBusyId(appointment._id);
    try {
      await setAppointmentStatus(appointment._id, status);
      notify(status === "Approved" ? "Appointment accepted." : "Appointment declined.");
      await Promise.all([appointments.reload({ quiet: true }), stats.reload({ quiet: true })]);
    } catch (requestError) {
      notify(getErrorMessage(requestError, "Could not update the appointment."), "danger");
    } finally {
      setBusyId(null);
    }
  };

  // The stats call fails with 404 when the account has no doctor profile; the
  // backend's message explains how to fix that, so show it on its own.
  if (stats.status === "error") {
    return <ErrorState title="Your dashboard could not load" message={stats.error} onRetry={stats.reload} />;
  }

  const figures = stats.data || {};
  const ready = stats.status === "ready";
  const cards = [
    { label: "Today's Appointments", icon: CalendarClock, value: figures.todaysAppointments },
    { label: "Pending Requests", icon: CalendarCheck, value: figures.pendingRequests },
    { label: "Patients Seen", icon: Users, value: figures.patientsSeen, to: "/doctor/patients" },
    { label: "Completed Visits", icon: CheckCircle2, value: figures.completedVisits },
  ];

  const list = appointments.data || [];
  const requests = list.filter((row) => row.status === "Pending");
  const today = list
    .filter((row) => isToday(row.date) && row.status !== "Rejected")
    .sort((a, b) => minutesOf(a.time) - minutesOf(b.time));

  const requestColumns = [
    {
      key: "patient",
      label: "Patient",
      render: (row) => (
        <div>
          <div className="table-primary">{personName(row.patient)}</div>
          <div className="table-muted">{row.patient?.phone}</div>
        </div>
      ),
    },
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
    { key: "reason", label: "Reason", render: (row) => row.reason || "—" },
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
            <Check size={14} /> Accept
          </button>
          <button
            type="button"
            className="btn btn-secondary btn-sm"
            disabled={busyId === row._id}
            onClick={() => decide(row, "Rejected")}
          >
            <X size={14} /> Decline
          </button>
        </div>
      ),
    },
  ];

  const todayColumns = [
    { key: "time", label: "Time", render: (row) => <span className="table-primary">{row.time}</span> },
    { key: "patient", label: "Patient", render: (row) => personName(row.patient) },
    { key: "reason", label: "Reason", render: (row) => row.reason || "—" },
    {
      key: "status",
      label: "Status",
      render: (row) => <Badge variant={STATUS_VARIANT[row.status]}>{row.status}</Badge>,
    },
  ];

  return (
    <>
      <div className="page-header">
        <h2>Welcome back{user.name ? `, Dr. ${user.name.replace(/^Dr\.?\s*/i, "").split(" ")[0]}` : ""}</h2>
        <p className="page-subtitle">Your appointments and requests at a glance.</p>
      </div>

      <div className="dashboard-stats">
        {cards.map((card) => (
          <StatCard
            key={card.label}
            {...card}
            to={card.to || "/doctor/appointments"}
            value={ready ? card.value : null}
          />
        ))}
      </div>

      {appointments.status === "loading" && <LoadingState message="Loading appointments" />}
      {appointments.status === "error" && (
        <ErrorState message={appointments.error} onRetry={appointments.reload} />
      )}
      {appointments.status === "ready" && (
        <>
          <section className="dashboard-section">
            <div className="dashboard-section-head">
              <h3>Requests to review</h3>
              <Link to="/doctor/appointments" className="dashboard-section-link">
                All appointments <ArrowRight size={16} />
              </Link>
            </div>
            <DataTable
              columns={requestColumns}
              rows={requests}
              empty="No new requests. Bookings patients make in the app appear here for you to accept."
            />
          </section>

          <section className="dashboard-section">
            <div className="dashboard-section-head">
              <h3>Today’s schedule</h3>
            </div>
            <DataTable columns={todayColumns} rows={today} empty="Nothing scheduled for today." />
          </section>
        </>
      )}
    </>
  );
}
