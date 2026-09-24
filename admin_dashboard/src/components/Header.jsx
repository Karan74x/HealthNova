import { Menu } from "lucide-react";
import Badge from "./Badge";

export default function Header({ title, user, onOpenSidebar }) {
  return (
    <header className="app-header">
      <button
        type="button"
        className="app-header-menu"
        onClick={onOpenSidebar}
        aria-label="Open navigation"
      >
        <Menu size={22} />
      </button>

      <h1 className="app-header-title">{title}</h1>

      <div className="app-header-user">
        <span className="app-header-email">{user.email}</span>
        <Badge variant="info">{user.role}</Badge>
      </div>
    </header>
  );
}
