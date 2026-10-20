import { Link } from "react-router-dom";
import { FileQuestion } from "lucide-react";
import "./Message.css";

export default function NotFound() {
  return (
    <div className="message-page">
      <div className="message-card">
        <span className="message-icon" aria-hidden="true">
          <FileQuestion size={28} />
        </span>
        <h1 className="message-title">Page not found</h1>
        <p className="message-text">
          That page does not exist in the HealthNova admin dashboard.
        </p>
        <Link className="btn btn-primary" to="/admin">
          Back to dashboard
        </Link>
      </div>
    </div>
  );
}
