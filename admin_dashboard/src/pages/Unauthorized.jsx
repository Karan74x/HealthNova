import { useNavigate } from "react-router-dom";
import { ShieldAlert } from "lucide-react";
import { useAuth } from "../hooks/useAuth";
import "./Message.css";

export default function Unauthorized() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleSignOut = () => {
    logout();
    navigate("/login", { replace: true });
  };

  return (
    <div className="message-page">
      <div className="message-card">
        <span className="message-icon message-icon-danger" aria-hidden="true">
          <ShieldAlert size={28} />
        </span>
        <h1 className="message-title">Access denied</h1>
        <p className="message-text">
          {user
            ? `This dashboard is for administrators. Your account is signed in with the "${user.role}" role.`
            : "This dashboard is restricted to administrator accounts."}
        </p>
        <button type="button" className="btn btn-primary" onClick={handleSignOut}>
          Sign in with another account
        </button>
      </div>
    </div>
  );
}
