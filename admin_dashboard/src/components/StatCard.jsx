import { Link } from "react-router-dom";
import "./StatCard.css";

/*
 * A dashboard statistic. With `to` the whole card links to the screen that
 * lists those records. `value` may be null while the figure is loading, and
 * `pending` marks a statistic that has no endpoint yet, so the card shows a
 * dash rather than an invented number.
 */
export default function StatCard({ icon: Icon, label, value, to, note, pending = false }) {
  const body = (
    <>
      <span className="stat-card-icon" aria-hidden="true">
        {Icon && <Icon size={20} />}
      </span>
      <div className="stat-card-body">
        <p className="stat-card-label">{label}</p>
        <p className="stat-card-value">{pending || value === null || value === undefined ? "—" : value}</p>
        {pending && <p className="stat-card-note">Pending backend</p>}
        {!pending && note && <p className="stat-card-note">{note}</p>}
      </div>
    </>
  );

  const className = `stat-card${pending ? " stat-card-pending" : ""}`;

  if (to && !pending) {
    return (
      <Link to={to} className={`${className} stat-link`}>
        {body}
      </Link>
    );
  }

  return <article className={className}>{body}</article>;
}
