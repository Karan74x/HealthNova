import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import LoadingState from "../components/LoadingState";

/*
 * Guards a group of routes. Without a session the visitor is sent to /login.
 * With a session whose role does not match requiredRole, they are sent to
 * /unauthorized rather than to the login page - they are signed in, just not
 * permitted, which mirrors the backend's 403 from roleMiddleware.
 */
export default function ProtectedRoute({ requiredRole }) {
  const { isAuthenticated, isRestoring, user } = useAuth();
  const location = useLocation();

  if (isRestoring) {
    return <LoadingState message="Restoring your session" />;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  }

  if (requiredRole && user.role !== requiredRole) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <Outlet />;
}
