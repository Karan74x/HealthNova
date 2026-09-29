import { useState } from "react";
import { Outlet, useLocation, useNavigate } from "react-router-dom";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import { useAuth } from "../hooks/useAuth";
import { getPageTitle } from "../config/navigation";
import "./DashboardLayout.css";

/*
 * Shell shared by both staff areas. The signed-in role decides which links the
 * sidebar shows and which title the header carries, so the administrator and
 * the doctor see the same chrome with their own navigation inside it.
 */
export default function DashboardLayout() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const { pathname } = useLocation();

  const handleLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  return (
    <div className="app-layout">
      <Sidebar
        role={user.role}
        isOpen={isSidebarOpen}
        onClose={() => setIsSidebarOpen(false)}
        onLogout={handleLogout}
      />

      <div className="app-main">
        <Header
          title={getPageTitle(pathname, user.role)}
          user={user}
          onOpenSidebar={() => setIsSidebarOpen(true)}
        />
        <main className="app-content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
