import { Navigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import LoadingState from "../components/LoadingState";
import { getLandingPath } from "../config/navigation";

/*
 * Entry point for "/". The role on the session decides which staff area the
 * visitor belongs in, so the same URL works for an administrator and a doctor
 * without either of them needing to know their own path.
 */
export default function RoleLanding() {
  const { isAuthenticated, isRestoring, user } = useAuth();

  if (isRestoring) {
    return <LoadingState message="Restoring your session" />;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <Navigate to={getLandingPath(user.role)} replace />;
}
