import { AlertCircle } from "lucide-react";

export default function ErrorState({ title = "Something went wrong", message, onRetry }) {
  return (
    <div className="state" role="alert">
      <AlertCircle size={32} className="state-icon-danger" aria-hidden="true" />
      <p className="state-title">{title}</p>
      {message && <p className="state-message">{message}</p>}
      {onRetry && (
        <button type="button" className="btn btn-secondary" onClick={onRetry}>
          Try again
        </button>
      )}
    </div>
  );
}
