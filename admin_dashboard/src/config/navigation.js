import {
  Activity,
  CalendarCheck,
  ClipboardList,
  History,
  LayoutDashboard,
  Stethoscope,
  UserRound,
  Users,
} from "lucide-react";

/*
 * One place that describes both staff areas.
 *
 * `links` are the screens that actually work; `pending` are the modules the
 * backend cannot support yet. They are rendered as disabled entries so the
 * intended structure is visible without implying the features exist. Keeping
 * the navigation and the page titles together stops the two drifting apart
 * when a screen is added.
 */
export const ROLE_AREAS = {
  admin: {
    basePath: "/admin",
    label: "Admin",
    links: [
      { to: "/admin", label: "Dashboard", icon: LayoutDashboard, end: true },
      { to: "/admin/profile", label: "Profile", icon: UserRound },
    ],
    pending: [
      { label: "Doctors", icon: Stethoscope },
      { label: "Patients", icon: Users },
      { label: "Appointments", icon: CalendarCheck },
      { label: "Predictions", icon: Activity },
    ],
  },
  doctor: {
    basePath: "/doctor",
    label: "Doctor",
    links: [
      { to: "/doctor", label: "Dashboard", icon: LayoutDashboard, end: true },
      { to: "/doctor/profile", label: "Profile", icon: UserRound },
    ],
    pending: [
      { label: "Appointments", icon: CalendarCheck },
      { label: "Patients", icon: Users },
      { label: "Consultation History", icon: History },
      { label: "Availability", icon: ClipboardList },
    ],
  },
};

export const STAFF_ROLES = Object.keys(ROLE_AREAS);

export function getArea(role) {
  return ROLE_AREAS[role] || null;
}

/*
 * Landing path for a signed-in account. Patients have no web area: they use
 * the Flutter application, so they are sent to the Access Denied screen.
 */
export function getLandingPath(role) {
  return getArea(role)?.basePath || "/unauthorized";
}

export function getPageTitle(pathname, role) {
  const area = getArea(role);
  if (!area) return "HealthNova";
  const match = area.links.find((link) => link.to === pathname);
  return match ? match.label : area.label;
}
