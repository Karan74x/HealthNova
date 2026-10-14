import { useMemo, useState } from "react";
import { Check, CheckCheck, Eye, X } from "lucide-react";
import PageToolbar, { StatusFilters } from "../../components/PageToolbar";
import DataTable from "../../components/DataTable";
import Modal from "../../components/Modal";
import LoadingState from "../../components/LoadingState";
import ErrorState from "../../components/ErrorState";
import Badge from "../../components/Badge";
import { useToast } from "../../components/Toast";
import { useResource } from "../../hooks/useResource";
import { listAppointments, setAppointmentStatus } from "../../api/doctorApi";
import { getErrorMessage } from "../../api/axiosInstance";
import { APPOINTMENT_STATUSES, STATUS_VARIANT, formatDate, formatDateTime, personName } from "../../utils/format";

const ACTION_MESSAGES = {
  Approved: "Appointment accepted.",
  Rejected: "Appointment declined.",
  Completed: "Visit marked as completed.",
};

// The buttons a doctor gets for an appointment in each state
function StatusActions({ appointment, busy, onChange, size = "btn-sm" }) {
  if (appointment.status === "Pending") {
    return (
      <>
        <button
          type="button"
          className={`btn btn-primary ${size}`}
          disabled={busy}
          onClick={() => onChange(appointment, "Approved")}
        >
          <Check size={14} /> Accept
        </button>
        <button
          type="button"
          className={`btn btn-secondary ${size}`}
          disabled={busy}
          onClick={() => onChange(appointment, "Rejected")}
        >
          <X size={14} /> Decline
        </button>
      </>
    );
  }
  if (appointment.status === "Approved") {
    return (
      <button
        type="button"
        className={`btn btn-primary ${size}`}
        disabled={busy}
        onClick={() => onChange(appointment, "Completed")}
      >
        <CheckCheck size={14} /> Mark completed
      </button>
    );
  }
  return null;
}

function AppointmentDetails({ appointment, busy, onChange, onClose }) {
  const patient = appointment.patient;
  const actions = StatusActions({ appointment, busy, onChange, size: "" });
  return (
    <Modal title="Appointment" onClose={onClose} width={520} footer={actions}>
      <div className="prediction-summary">
        <Badge variant={STATUS_VARIANT[appointment.status]}>{appointment.status}</Badge>
        <span className="table-primary">
          {formatDate(appointment.date)} · {appointment.time}
        </span>
      </div>
      <dl className="profile-list detail-list">
        <div className="profile-row">
          <dt>Patient</dt>
          <dd>{personName(patient)}</dd>
        </div>
        <div className="profile-row">
          <dt>Phone</dt>
          <dd>{patient?.phone || "—"}</dd>
        </div>
        <div className="profile-row">
          <dt>Email</dt>
          <dd>{patient?.email || "—"}</dd>
        </div>
        <div className="profile-row">
          <dt>Gender</dt>
          <dd>{patient?.gender || "—"}</dd>
        </div>
        <div className="profile-row">
          <dt>Reason</dt>
          <dd>{appointment.reason || "—"}</dd>
        </div>
        <div className="profile-row">
          <dt>Booked</dt>
          <dd>{formatDateTime(appointment.createdAt)}</dd>
        </div>
      </dl>
    </Modal>
  );
}

export default function DoctorAppointments() {
  const notify = useToast();
  const [statusFilter, setStatusFilter] = useState("");
  const [search, setSearch] = useState("");
  const [busyId, setBusyId] = useState(null);
  const [viewingId, setViewingId] = useState(null);
  const { data, status, error, reload } = useResource(
    () => listAppointments(statusFilter),
    [statusFilter],
    "Could not load your appointments.",
  );

  const rows = useMemo(() => {
    if (!data || !search) return data;
    const term = search.toLowerCase();
    return data.filter((appointment) =>
      [personName(appointment.patient), appointment.patient?.phone, appointment.reason]
        .filter(Boolean)
        .some((value) => value.toLowerCase().includes(term)),
    );
  }, [data, search]);

  // Looked up from the loaded list so the dialog shows the latest status
  const viewing = data?.find((appointment) => appointment._id === viewingId);

  const changeStatus = async (appointment, next) => {
    setBusyId(appointment._id);
    try {
      await setAppointmentStatus(appointment._id, next);
      notify(ACTION_MESSAGES[next]);
      await reload({ quiet: true });
    } catch (requestError) {
      notify(getErrorMessage(requestError, "Could not update the appointment."), "danger");
    } finally {
      setBusyId(null);
    }
  };

  const columns = [
    {
      key: "patient",
      label: "Patient",
      render: (appointment) => (
        <div>
          <div className="table-primary">{personName(appointment.patient)}</div>
          <div className="table-muted">{appointment.patient?.phone}</div>
        </div>
      ),
    },
    {
      key: "when",
      label: "Date & time",
      render: (appointment) => (
        <div>
          <div>{formatDate(appointment.date)}</div>
          <div className="table-muted">{appointment.time}</div>
        </div>
      ),
    },
    { key: "reason", label: "Reason", render: (appointment) => appointment.reason || "—" },
    {
      key: "status",
      label: "Status",
      render: (appointment) => <Badge variant={STATUS_VARIANT[appointment.status]}>{appointment.status}</Badge>,
    },
    {
      key: "actions",
      label: "Actions",
      render: (appointment) => (
        <div className="table-actions">
          <StatusActions appointment={appointment} busy={busyId === appointment._id} onChange={changeStatus} />
          <button type="button" className="btn btn-secondary btn-sm" onClick={() => setViewingId(appointment._id)}>
            <Eye size={14} /> View
          </button>
        </div>
      ),
    },
  ];

  return (
    <>
      <div className="page-header">
        <h2>Appointments</h2>
        <p className="page-subtitle">Accept or decline new requests and mark visits as completed.</p>
      </div>

      <PageToolbar
        search={search}
        onSearch={setSearch}
        placeholder="Search patient, phone or reason"
        filters={<StatusFilters value={statusFilter} onChange={setStatusFilter} options={APPOINTMENT_STATUSES} />}
      />

      {status === "loading" && <LoadingState message="Loading appointments" />}
      {status === "error" && <ErrorState title="Could not load appointments" message={error} onRetry={reload} />}
      {status === "ready" && (
        <DataTable
          columns={columns}
          rows={rows}
          empty={
            search
              ? `No appointments match “${search}”.`
              : statusFilter
                ? `No ${statusFilter.toLowerCase()} appointments.`
                : "No appointments yet. Patients book you from the HealthNova app."
          }
        />
      )}

      {viewing && (
        <AppointmentDetails
          appointment={viewing}
          busy={busyId === viewing._id}
          onChange={changeStatus}
          onClose={() => setViewingId(null)}
        />
      )}
    </>
  );
}
