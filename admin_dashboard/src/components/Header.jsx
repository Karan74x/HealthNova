import { Menu } from "lucide-react";
import Badge from "./Badge";

export default function Header({ title, user, onOpenSidebar }) {
  return (
    <header className="admin-header">
      <button
        type="button"
        className="admin-header-menu"
        onClick={onOpenSidebar}
        aria-label="Open navigation"
      >
        <Menu size={22} />
      </button>

      <h1 className="admin-header-title">{title}</h1>

      <div className="admin-header-user">
        <span className="admin-header-email">{user.email}</span>
        <Badge variant="info">{user.role}</Badge>
      </div>
    </header>
  );
}
