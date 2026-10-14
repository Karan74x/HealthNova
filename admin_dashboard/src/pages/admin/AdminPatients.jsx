import { useState } from "react";
import { Eye, Trash2 } from "lucide-react";
import PageToolbar from "../../components/PageToolbar";
import DataTable from "../../components/DataTable";
import Modal from "../../components/Modal";
import ConfirmDialog from "../../components/ConfirmDialog";
import LoadingState from "../../components/LoadingState";
import ErrorState from "../../components/ErrorState";
import Badge from "../../components/Badge";
import { useToast } from "../../components/Toast";
import { useResource } from "../../hooks/useResource";
import { deletePatient, listPatients, listPredictions } from "../../api/adminApi";
import { formatDate, formatDateTime, personName, RISK_VARIANT } from "../../utils/format";

function age(dob) {
  if (!dob) return null;
  const born = new Date(dob);
  const now = new Date();
  let years = now.getFullYear() - born.getFullYear();
  const beforeBirthday =
    now.getMonth() < born.getMonth() || (now.getMonth() === born.getMonth() && now.getDate() < born.getDate());
  if (beforeBirthday) years -= 1;
  return years >= 0 ? years : null;
}

// Account details plus the patient's prediction history
function PatientDetails({ patient, onClose }) {
  const { data, status, error, reload } = useResource(
    () => listPredictions(patient._id),
    [patient._id],
    "Could not load predictions.",
  );
  const years = age(patient.dob);

  return (
    <Modal title={personName(patient)} onClose={onClose} width={620}>
      <dl className="profile-list detail-list">
        <div className="profile-row">
          <dt>Email</dt>
          <dd>{patient.email}</dd>
        </div>
        <div className="profile-row">
          <dt>Phone</dt>
          <dd>{patient.phone || "—"}</dd>
        </div>
        <div className="profile-row">
          <dt>Gender</dt>
          <dd>{patient.gender || "—"}</dd>
        </div>
        <div className="profile-row">
          <dt>Date of birth</dt>
          <dd>{patient.dob ? `${formatDate(patient.dob)}${years !== null ? ` (${years} yrs)` : ""}` : "—"}</dd>
        </div>
        <div className="profile-row">
          <dt>Registered</dt>
          <dd>{formatDate(patient.createdAt)}</dd>
        </div>
      </dl>

      <h3 className="detail-heading">Prediction history</h3>
      {status === "loading" && <LoadingState message="Loading predictions" />}
      {status === "error" && <ErrorState message={error} onRetry={reload} />}
      {status === "ready" &&
        (data.length === 0 ? (
          <p className="table-muted">This patient has not run any predictions yet.</p>
        ) : (
          <ul className="history-list">
            {data.map((prediction) => (
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
        ))}
    </Modal>
  );
}

export default function AdminPatients() {
  const notify = useToast();
  const [search, setSearch] = useState("");
  const [viewing, setViewing] = useState(null);
  const [deleting, setDeleting] = useState(null);
  const { data, status, error, reload } = useResource(() => listPatients(search), [search], "Could not load patients.");

  const columns = [
    {
      key: "patient",
      label: "Patient",
      render: (patient) => (
        <div>
          <div className="table-primary">{personName(patient)}</div>
          <div className="table-muted">{patient.email}</div>
        </div>
      ),
    },
    { key: "phone", label: "Phone", render: (patient) => patient.phone || "—" },
    { key: "gender", label: "Gender", render: (patient) => patient.gender || "—" },
    {
      key: "age",
      label: "Age",
      render: (patient) => {
        const years = age(patient.dob);
        return years === null ? "—" : `${years} yrs`;
      },
    },
    { key: "createdAt", label: "Registered", render: (patient) => formatDate(patient.createdAt) },
    {
      key: "actions",
      label: "Actions",
      render: (patient) => (
        <div className="table-actions">
          <button type="button" className="btn btn-secondary btn-sm" onClick={() => setViewing(patient)}>
            <Eye size={14} /> View
          </button>
          <button type="button" className="btn btn-danger-outline btn-sm" onClick={() => setDeleting(patient)}>
            <Trash2 size={14} /> Delete
          </button>
        </div>
      ),
    },
  ];

  return (
    <>
      <div className="page-header">
        <h2>Patients</h2>
        <p className="page-subtitle">
          Patients register themselves in the HealthNova mobile app. Here you can look them up and remove accounts.
        </p>
      </div>

      <PageToolbar search={search} onSearch={setSearch} placeholder="Search name, email or phone" />

      {status === "loading" && <LoadingState message="Loading patients" />}
      {status === "error" && <ErrorState title="Could not load patients" message={error} onRetry={reload} />}
      {status === "ready" && (
        <DataTable
          columns={columns}
          rows={data}
          empty={search ? `No patients match “${search}”.` : "No patients have registered yet."}
        />
      )}

      {viewing && <PatientDetails patient={viewing} onClose={() => setViewing(null)} />}

      {deleting && (
        <ConfirmDialog
          title="Delete patient"
          message={`Delete ${personName(deleting)}? Their appointments and prediction history are removed as well. This cannot be undone.`}
          onClose={() => setDeleting(null)}
          onConfirm={async () => {
            await deletePatient(deleting._id);
            notify(`${personName(deleting)} was deleted.`);
            reload({ quiet: true });
          }}
        />
      )}
    </>
  );
}
