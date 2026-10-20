import { NavLink } from "react-router-dom";
import { LogOut, X } from "lucide-react";
import { getArea } from "../config/navigation";

/*
 * Navigation for whichever staff area the signed-in role belongs to.
 *
 * Every screen the backend can serve is a link. Anything listed as pending in
 * config/navigation.js is rendered as a disabled entry, so a planned module is
 * visible without implying that it works.
 */
export default function Sidebar({ role, isOpen, onClose, onLogout }) {
  const area = getArea(role);
  if (!area) return null;

  return (
    <>
      <div
        className={`sidebar-backdrop${isOpen ? " is-visible" : ""}`}
        onClick={onClose}
        aria-hidden="true"
      />

      <aside
        className={`sidebar${isOpen ? " is-open" : ""}`}
        aria-label={`${area.label} navigation`}
      >
        <div className="sidebar-brand">
          <img
            src="/logo-icon.png"
            alt=""
            className="sidebar-logo"
            width="38"
            height="38"
          />
          <span className="sidebar-brand-text">
            <strong>HealthNova</strong>
            <small>{area.label}</small>
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
          {area.links.map(({ to, label, icon: Icon, end }) => (
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

          {area.pending.length > 0 && (
            <p className="sidebar-group-label">Awaiting backend</p>
          )}

          {area.pending.map(({ label, icon: Icon }) => (
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
