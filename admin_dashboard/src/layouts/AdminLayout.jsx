import { useState } from "react";
import { Outlet, useLocation, useNavigate } from "react-router-dom";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import { useAuth } from "../hooks/useAuth";
import "./AdminLayout.css";

const PAGE_TITLES = {
  "/admin": "Dashboard",
  "/admin/profile": "Profile",
};

export default function AdminLayout() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const { pathname } = useLocation();

  const handleLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  return (
    <div className="admin-layout">
      <Sidebar
        isOpen={isSidebarOpen}
        onClose={() => setIsSidebarOpen(false)}
        onLogout={handleLogout}
      />

      <div className="admin-main">
        <Header
          title={PAGE_TITLES[pathname] || "Admin"}
          user={user}
          onOpenSidebar={() => setIsSidebarOpen(true)}
        />
        <main className="admin-content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
