import { useState } from "react";
import Modal from "./Modal";
import { getErrorMessage } from "../api/axiosInstance";

/*
 * "Are you sure?" for destructive actions. `onConfirm` returns a promise;
 * the dialog stays open and shows the error if it fails, and closes itself
 * when it succeeds.
 */
export default function ConfirmDialog({
  title,
  message,
  confirmLabel = "Delete",
  variant = "danger",
  onConfirm,
  onClose,
}) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");

  const confirm = async () => {
    setBusy(true);
    setError("");
    try {
      await onConfirm();
      onClose();
    } catch (requestError) {
      setError(getErrorMessage(requestError, "That did not work. Please try again."));
      setBusy(false);
    }
  };

  return (
    <Modal
      title={title}
      onClose={busy ? () => {} : onClose}
      width={440}
      footer={
        <>
          <button type="button" className="btn btn-secondary" onClick={onClose} disabled={busy}>
            Cancel
          </button>
          <button type="button" className={`btn btn-${variant}`} onClick={confirm} disabled={busy}>
            {busy ? "Working…" : confirmLabel}
          </button>
        </>
      }
    >
      {error && <p className="alert alert-danger">{error}</p>}
      <p>{message}</p>
    </Modal>
  );
}
