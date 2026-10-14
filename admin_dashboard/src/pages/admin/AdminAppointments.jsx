import { useMemo, useState } from "react";
import { Check, CheckCheck, Trash2, X } from "lucide-react";
import PageToolbar, { StatusFilters } from "../../components/PageToolbar";
import DataTable from "../../components/DataTable";
import ConfirmDialog from "../../components/ConfirmDialog";
import LoadingState from "../../components/LoadingState";
import ErrorState from "../../components/ErrorState";
import Badge from "../../components/Badge";
import { useToast } from "../../components/Toast";
import { useResource } from "../../hooks/useResource";
import { deleteAppointment, listAppointments, setAppointmentStatus } from "../../api/adminApi";
import { getErrorMessage } from "../../api/axiosInstance";
import {
  APPOINTMENT_STATUSES,
  STATUS_VARIANT,
  doctorName,
  formatDate,
  personName,
} from "../../utils/format";

const ACTION_MESSAGES = {
  Approved: "Appointment approved.",
  Rejected: "Appointment rejected.",
  Completed: "Appointment marked as completed.",
};

export default function AdminAppointments() {
  const notify = useToast();
  const [statusFilter, setStatusFilter] = useState("");
  const [search, setSearch] = useState("");
  const [busyId, setBusyId] = useState(null);
  const [deleting, setDeleting] = useState(null);
  const { data, status, error, reload } = useResource(
    () => listAppointments(statusFilter),
    [statusFilter],
    "Could not load appointments.",
  );

  // The API filters by status; the name search is done here on the loaded list
  const rows = useMemo(() => {
    if (!data || !search) return data;
    const term = search.toLowerCase();
    return data.filter((appointment) =>
      [
        personName(appointment.patient),
        appointment.patient?.email,
        doctorName(appointment.doctor),
        appointment.doctor?.specialization,
        appointment.reason,
      ]
        .filter(Boolean)
        .some((value) => value.toLowerCase().includes(term)),
    );
  }, [data, search]);

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
      key: "doctor",
      label: "Doctor",
      render: (appointment) => (
        <div>
          <div>{doctorName(appointment.doctor)}</div>
          <div className="table-muted">{appointment.doctor?.specialization}</div>
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
      render: (appointment) => {
        const busy = busyId === appointment._id;
        return (
          <div className="table-actions">
            {appointment.status === "Pending" && (
              <>
                <button
                  type="button"
                  className="btn btn-primary btn-sm"
                  disabled={busy}
                  onClick={() => changeStatus(appointment, "Approved")}
                >
                  <Check size={14} /> Approve
                </button>
                <button
                  type="button"
                  className="btn btn-secondary btn-sm"
                  disabled={busy}
                  onClick={() => changeStatus(appointment, "Rejected")}
                >
                  <X size={14} /> Reject
                </button>
              </>
            )}
            {appointment.status === "Approved" && (
              <button
                type="button"
                className="btn btn-primary btn-sm"
                disabled={busy}
                onClick={() => changeStatus(appointment, "Completed")}
              >
                <CheckCheck size={14} /> Complete
              </button>
            )}
            <button
              type="button"
              className="btn btn-danger-outline btn-sm"
              disabled={busy}
              onClick={() => setDeleting(appointment)}
              aria-label="Delete appointment"
            >
              <Trash2 size={14} />
            </button>
          </div>
        );
      },
    },
  ];

  return (
    <>
      <div className="page-header">
        <h2>Appointments</h2>
        <p className="page-subtitle">Every appointment booked through the patient app, across all doctors.</p>
      </div>

      <PageToolbar
        search={search}
        onSearch={setSearch}
        placeholder="Search patient, doctor or reason"
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
                : "No appointments have been booked yet."
          }
        />
      )}

      {deleting && (
        <ConfirmDialog
          title="Delete appointment"
          message={`Delete the appointment between ${personName(deleting.patient)} and ${doctorName(deleting.doctor)} on ${formatDate(deleting.date)}? This cannot be undone.`}
          onClose={() => setDeleting(null)}
          onConfirm={async () => {
            await deleteAppointment(deleting._id);
            notify("Appointment deleted.");
            reload({ quiet: true });
          }}
        />
      )}
    </>
  );
}
