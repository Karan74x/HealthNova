import { useMemo, useState } from "react";
import { Eye } from "lucide-react";
import PageToolbar from "../../components/PageToolbar";
import DataTable from "../../components/DataTable";
import Modal from "../../components/Modal";
import LoadingState from "../../components/LoadingState";
import ErrorState from "../../components/ErrorState";
import Badge from "../../components/Badge";
import { useResource } from "../../hooks/useResource";
import { getPatient, listAppointments } from "../../api/doctorApi";
import {
  RISK_VARIANT,
  STATUS_VARIANT,
  formatDate,
  formatDateTime,
  personName,
} from "../../utils/format";

/*
 * A doctor's patients are the people who have booked them, so the list is
 * built from the doctor's own appointments. The details dialog asks the
 * backend for the full record, which it only returns for a patient this
 * doctor has an appointment with.
 */
function groupByPatient(appointments) {
  const byId = new Map();
  for (const appointment of appointments) {
    const patient = appointment.patient;
    if (!patient) continue;
    const entry = byId.get(patient._id) || { _id: patient._id, patient, visits: 0, completed: 0, last: null };
    entry.visits += 1;
    if (appointment.status === "Completed") entry.completed += 1;
    if (!entry.last || new Date(appointment.date) > new Date(entry.last.date)) entry.last = appointment;
    byId.set(patient._id, entry);
  }
  return [...byId.values()].sort((a, b) => new Date(b.last.date) - new Date(a.last.date));
}

function PatientDetails({ patientId, onClose }) {
  const { data, status, error, reload } = useResource(
    () => getPatient(patientId),
    [patientId],
    "Could not load this patient.",
  );

  const patient = data?.patient;

  return (
    <Modal title={patient ? personName(patient) : "Patient"} onClose={onClose} width={640}>
      {status === "loading" && <LoadingState message="Loading patient" />}
      {status === "error" && <ErrorState message={error} onRetry={reload} />}
      {status === "ready" && (
        <>
          <dl className="profile-list detail-list">
            <div className="profile-row">
              <dt>Phone</dt>
              <dd>{patient.phone || "—"}</dd>
            </div>
            <div className="profile-row">
              <dt>Email</dt>
              <dd>{patient.email}</dd>
            </div>
            <div className="profile-row">
              <dt>Gender</dt>
              <dd>{patient.gender || "—"}</dd>
            </div>
            <div className="profile-row">
              <dt>Date of birth</dt>
              <dd>{formatDate(patient.dob)}</dd>
            </div>
          </dl>

          <h3 className="detail-heading">Visits with you</h3>
          <ul className="history-list">
            {data.appointments.map((appointment) => (
              <li key={appointment._id} className="history-item">
                <div>
                  <div className="table-primary">
                    {formatDate(appointment.date)} · {appointment.time}
                  </div>
                  <div className="table-muted">{appointment.reason || "No reason given"}</div>
                </div>
                <Badge variant={STATUS_VARIANT[appointment.status]}>{appointment.status}</Badge>
              </li>
            ))}
          </ul>

          <h3 className="detail-heading">Risk checks from the app</h3>
          {data.predictions?.length ? (
            <ul className="history-list">
              {data.predictions.map((prediction) => (
                <li key={prediction._id} className="history-item">
                  <div>
                    <div className="table-primary">{prediction.disease}</div>
                    <div className="table-muted">{formatDateTime(prediction.createdAt)}</div>
                  </div>
                  <div className="history-meta">
                    <Badge variant={RISK_VARIANT[prediction.riskLevel] || "neutral"}>
                      {prediction.riskLevel || "—"} risk
                    </Badge>
                    {prediction.confidence !== undefined && (
                      <span className="table-muted">{prediction.confidence}%</span>
                    )}
                  </div>
                </li>
              ))}
            </ul>
          ) : (
            <p className="table-muted">This patient has not run any risk checks.</p>
          )}
          <p className="field-hint detail-footnote">
            Risk checks are machine-learning screening estimates, not diagnoses.
          </p>
        </>
      )}
    </Modal>
  );
}

export default function DoctorPatients() {
  const [search, setSearch] = useState("");
  const [viewing, setViewing] = useState(null);
  const { data, status, error, reload } = useResource(() => listAppointments(), [], "Could not load your patients.");

  const rows = useMemo(() => {
    if (!data) return data;
    const all = groupByPatient(data);
    if (!search) return all;
    const term = search.toLowerCase();
    return all.filter((row) =>
      [personName(row.patient), row.patient.phone, row.patient.email]
        .filter(Boolean)
        .some((value) => value.toLowerCase().includes(term)),
    );
  }, [data, search]);

  const columns = [
    {
      key: "patient",
      label: "Patient",
      render: (row) => (
        <div>
          <div className="table-primary">{personName(row.patient)}</div>
          <div className="table-muted">{row.patient.email}</div>
        </div>
      ),
    },
    { key: "phone", label: "Phone", render: (row) => row.patient.phone || "—" },
    { key: "gender", label: "Gender", render: (row) => row.patient.gender || "—" },
    {
      key: "visits",
      label: "Visits",
      render: (row) => `${row.visits} booked · ${row.completed} completed`,
    },
    {
      key: "last",
      label: "Latest appointment",
      render: (row) => (
        <div>
          <div>{formatDate(row.last.date)}</div>
          <Badge variant={STATUS_VARIANT[row.last.status]}>{row.last.status}</Badge>
        </div>
      ),
    },
    {
      key: "actions",
      label: "Details",
      render: (row) => (
        <button type="button" className="btn btn-secondary btn-sm" onClick={() => setViewing(row._id)}>
          <Eye size={14} /> View
        </button>
      ),
    },
  ];

  return (
    <>
      <div className="page-header">
        <h2>Patients</h2>
        <p className="page-subtitle">Everyone who has booked an appointment with you, with their visit history.</p>
      </div>

      <PageToolbar search={search} onSearch={setSearch} placeholder="Search name, phone or email" />

      {status === "loading" && <LoadingState message="Loading patients" />}
      {status === "error" && <ErrorState title="Could not load your patients" message={error} onRetry={reload} />}
      {status === "ready" && (
        <DataTable
          columns={columns}
          rows={rows}
          empty={search ? `No patients match “${search}”.` : "No patients yet. They appear here once they book you."}
        />
      )}

      {viewing && <PatientDetails patientId={viewing} onClose={() => setViewing(null)} />}
    </>
  );
}
