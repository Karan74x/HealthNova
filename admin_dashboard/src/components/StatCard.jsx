import "./StatCard.css";

/*
 * A dashboard statistic. When `pending` is set the card shows a dash and a
 * "Pending backend" note instead of a number: the counting endpoints do not
 * exist yet, and a placeholder figure would misrepresent the system.
 */
export default function StatCard({ icon: Icon, label, value, pending = false }) {
  return (
    <article className={`stat-card${pending ? " stat-card-pending" : ""}`}>
      <span className="stat-card-icon" aria-hidden="true">
        {Icon && <Icon size={20} />}
      </span>
      <div className="stat-card-body">
        <p className="stat-card-label">{label}</p>
        <p className="stat-card-value">{pending ? "—" : value}</p>
        {pending && <p className="stat-card-note">Pending backend</p>}
      </div>
    </article>
  );
}
