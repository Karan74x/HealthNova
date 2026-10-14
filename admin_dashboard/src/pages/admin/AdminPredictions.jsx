import { useMemo, useState } from "react";
import { Eye } from "lucide-react";
import PageToolbar, { StatusFilters } from "../../components/PageToolbar";
import DataTable from "../../components/DataTable";
import Modal from "../../components/Modal";
import LoadingState from "../../components/LoadingState";
import ErrorState from "../../components/ErrorState";
import Badge from "../../components/Badge";
import { useResource } from "../../hooks/useResource";
import { listPredictions } from "../../api/adminApi";
import { formatDateTime, personName, RISK_VARIANT } from "../../utils/format";

const DISEASES = ["Diabetes", "Heart Disease", "Liver Disease", "Kidney Disease", "Stroke", "Hypertension"];

// camelCase input keys from the app ("restingBloodPressure") as readable labels
function readable(key) {
  return key
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replace(/^./, (first) => first.toUpperCase());
}

function PredictionDetails({ prediction, onClose }) {
  const inputs = Object.entries(prediction.inputs || {});
  return (
    <Modal title={`${prediction.disease} prediction`} onClose={onClose} width={560}>
      <div className="prediction-summary">
        <Badge variant={RISK_VARIANT[prediction.riskLevel] || "neutral"}>{prediction.riskLevel || "—"} risk</Badge>
        <span className="table-primary">{prediction.result}</span>
      </div>
      <dl className="profile-list detail-list">
        <div className="profile-row">
          <dt>Patient</dt>
          <dd>{personName(prediction.patient)}</dd>
        </div>
        <div className="profile-row">
          <dt>Probability</dt>
          <dd>{prediction.confidence !== undefined ? `${prediction.confidence}%` : "—"}</dd>
        </div>
        <div className="profile-row">
          <dt>Run at</dt>
          <dd>{formatDateTime(prediction.createdAt)}</dd>
        </div>
      </dl>

      <h3 className="detail-heading">Values entered</h3>
      {inputs.length === 0 ? (
        <p className="table-muted">No input values were stored.</p>
      ) : (
        <dl className="profile-list detail-list">
          {inputs.map(([key, value]) => (
            <div className="profile-row" key={key}>
              <dt>{readable(key)}</dt>
              <dd>{value === "" || value === null ? "—" : String(value).replace(/^./, (first) => first.toUpperCase())}</dd>
            </div>
          ))}
        </dl>
      )}
      <p className="field-hint detail-footnote">
        Screening estimate from a machine-learning model, not a diagnosis.
      </p>
    </Modal>
  );
}

/*
 * Read-only: predictions are created by patients in the mobile app and
 * scored by the ML service. Administrators can review them but not change
 * a result.
 */
export default function AdminPredictions() {
  const [disease, setDisease] = useState("");
  const [search, setSearch] = useState("");
  const [viewing, setViewing] = useState(null);
  const { data, status, error, reload } = useResource(() => listPredictions(), [], "Could not load predictions.");

  const rows = useMemo(() => {
    if (!data) return data;
    const term = search.toLowerCase();
    return data.filter(
      (prediction) =>
        (!disease || prediction.disease === disease) &&
        (!term ||
          [personName(prediction.patient), prediction.patient?.email]
            .filter(Boolean)
            .some((value) => value.toLowerCase().includes(term))),
    );
  }, [data, disease, search]);

  const columns = [
    {
      key: "patient",
      label: "Patient",
      render: (prediction) => (
        <div>
          <div className="table-primary">{personName(prediction.patient)}</div>
          <div className="table-muted">{prediction.patient?.email}</div>
        </div>
      ),
    },
    { key: "disease", label: "Disease" },
    {
      key: "risk",
      label: "Risk",
      render: (prediction) => (
        <Badge variant={RISK_VARIANT[prediction.riskLevel] || "neutral"}>{prediction.riskLevel || "—"}</Badge>
      ),
    },
    {
      key: "confidence",
      label: "Probability",
      render: (prediction) => (prediction.confidence !== undefined ? `${prediction.confidence}%` : "—"),
    },
    { key: "createdAt", label: "Date", render: (prediction) => formatDateTime(prediction.createdAt) },
    {
      key: "actions",
      label: "Details",
      render: (prediction) => (
        <button type="button" className="btn btn-secondary btn-sm" onClick={() => setViewing(prediction)}>
          <Eye size={14} /> View
        </button>
      ),
    },
  ];

  return (
    <>
      <div className="page-header">
        <h2>Predictions</h2>
        <p className="page-subtitle">
          Disease-risk checks patients have run in the mobile app. Results come from the trained models in ml_service.
        </p>
      </div>

      <PageToolbar
        search={search}
        onSearch={setSearch}
        placeholder="Search patient name or email"
        filters={<StatusFilters value={disease} onChange={setDisease} options={DISEASES} />}
      />

      {status === "loading" && <LoadingState message="Loading predictions" />}
      {status === "error" && <ErrorState title="Could not load predictions" message={error} onRetry={reload} />}
      {status === "ready" && (
        <DataTable
          columns={columns}
          rows={rows}
          empty={
            search || disease ? "No predictions match these filters." : "No predictions have been run yet."
          }
        />
      )}

      {viewing && <PredictionDetails prediction={viewing} onClose={() => setViewing(null)} />}
    </>
  );
}
