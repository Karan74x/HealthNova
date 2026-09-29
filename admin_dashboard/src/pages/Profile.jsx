import { useCallback, useEffect, useState } from "react";
import LoadingState from "../components/LoadingState";
import ErrorState from "../components/ErrorState";
import Badge from "../components/Badge";
import { getProfile } from "../api/userApi";
import { getErrorMessage } from "../api/axiosInstance";
import { useAuth } from "../hooks/useAuth";
import "./Profile.css";

function formatTimestamp(seconds) {
  if (!seconds) return "—";
  return new Date(seconds * 1000).toLocaleString();
}

export default function Profile() {
  const { user } = useAuth();
  const roleLabel = user.role === "doctor" ? "doctor" : "administrator";
  const [tokenDetails, setTokenDetails] = useState(null);
  const [status, setStatus] = useState("loading");
  const [error, setError] = useState("");

  const loadProfile = useCallback(async () => {
    setStatus("loading");
    setError("");
    try {
      const { data } = await getProfile();
      setTokenDetails(data.user);
      setStatus("ready");
    } catch (requestError) {
      setError(getErrorMessage(requestError, "Could not load your profile."));
      setStatus("error");
    }
  }, []);

  useEffect(() => {
    loadProfile();
  }, [loadProfile]);

  if (status === "loading") {
    return <LoadingState message="Loading profile" />;
  }

  if (status === "error") {
    return (
      <ErrorState
        title="Could not load your profile"
        message={error}
        onRetry={loadProfile}
      />
    );
  }

  return (
    <>
      <div className="page-header">
        <h2>Profile</h2>
        <p className="page-subtitle">
          Account details for the signed-in {roleLabel}.
        </p>
      </div>

      <section className="card profile-card">
        <div className="card-header">
          <span className="card-title">Account</span>
          <Badge variant="info">{user.role}</Badge>
        </div>
        <dl className="profile-list">
          <div className="profile-row">
            <dt>Email</dt>
            <dd>{user.email}</dd>
          </div>
          <div className="profile-row">
            <dt>Phone</dt>
            <dd>{user.phone || "—"}</dd>
          </div>
          <div className="profile-row">
            <dt>User ID</dt>
            <dd className="profile-mono">{user._id}</dd>
          </div>
        </dl>
      </section>

      <section className="card profile-card">
        <div className="card-header">
          <span className="card-title">Session</span>
        </div>
        <dl className="profile-list">
          <div className="profile-row">
            <dt>Verified ID</dt>
            <dd className="profile-mono">{tokenDetails?.userId || "—"}</dd>
          </div>
          <div className="profile-row">
            <dt>Signed in at</dt>
            <dd>{formatTimestamp(tokenDetails?.iat)}</dd>
          </div>
          <div className="profile-row">
            <dt>Session expires</dt>
            <dd>{formatTimestamp(tokenDetails?.exp)}</dd>
          </div>
        </dl>
      </section>

      <section className="card profile-note">
        <p className="card-title">Editing is not available yet</p>
        <p className="card-subtitle">
          The backend has no endpoint for updating a user, so this page is
          read-only. Email, phone and ID come from the login response; the
          session details come from GET /api/user/profile, which returns the
          verified token payload rather than the stored user record.
        </p>
      </section>
    </>
  );
}
