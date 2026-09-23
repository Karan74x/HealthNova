import { NavLink } from "react-router-dom";
import {
  CalendarCheck,
  Activity,
  LayoutDashboard,
  LogOut,
  Stethoscope,
  UserRound,
  Users,
  X,
} from "lucide-react";

/*
 * Navigation for the admin area.
 *
 * Only Dashboard and Profile are reachable: they are the sole admin screens
 * the backend currently supports. The remaining four are rendered as disabled
 * entries so the intended structure is visible without implying that the
 * features work. They become links once Karan's endpoints land.
 */
const availableLinks = [
  { to: "/admin", label: "Dashboard", icon: LayoutDashboard, end: true },
  { to: "/admin/profile", label: "Profile", icon: UserRound },
];

const pendingLinks = [
  { label: "Doctors", icon: Stethoscope },
  { label: "Patients", icon: Users },
  { label: "Appointments", icon: CalendarCheck },
  { label: "Predictions", icon: Activity },
];

export default function Sidebar({ isOpen, onClose, onLogout }) {
  return (
    <>
      <div
        className={`sidebar-backdrop${isOpen ? " is-visible" : ""}`}
        onClick={onClose}
        aria-hidden="true"
      />

      <aside
        className={`sidebar${isOpen ? " is-open" : ""}`}
        aria-label="Admin navigation"
      >
        <div className="sidebar-brand">
          <span className="sidebar-logo" aria-hidden="true">
            <Activity size={22} />
          </span>
          <span className="sidebar-brand-text">
            <strong>HealthNova</strong>
            <small>Admin</small>
          </span>
          <button
            type="button"
            className="sidebar-close"
            onClick={onClose}
            aria-label="Close navigation"
          >
            <X size={20} />
          </button>
        </div>

        <nav className="sidebar-nav">
          {availableLinks.map(({ to, label, icon: Icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              onClick={onClose}
              className={({ isActive }) =>
                `sidebar-link${isActive ? " is-active" : ""}`
              }
            >
              <Icon size={18} aria-hidden="true" />
              {label}
            </NavLink>
          ))}

          <p className="sidebar-group-label">Awaiting backend</p>

          {pendingLinks.map(({ label, icon: Icon }) => (
            <span
              key={label}
              className="sidebar-link is-disabled"
              aria-disabled="true"
              title={`${label} is not available yet - the backend endpoint does not exist`}
            >
              <Icon size={18} aria-hidden="true" />
              {label}
            </span>
          ))}
        </nav>

        <button type="button" className="sidebar-logout" onClick={onLogout}>
          <LogOut size={18} aria-hidden="true" />
          Logout
        </button>
      </aside>
    </>
  );
}
