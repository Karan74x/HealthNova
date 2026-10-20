import {
  Activity,
  CalendarCheck,
  LayoutDashboard,
  Stethoscope,
  UserRound,
  Users,
} from "lucide-react";

/*
 * One place that describes both staff areas.
 *
 * `links` are the screens of each area. `pending` lists modules that are
 * planned but not yet backed by an endpoint; the sidebar shows them as
 * disabled entries. Every module now has its endpoints, so both lists are
 * empty - the mechanism stays for anything added later. Keeping navigation
 * and page titles together stops the two drifting apart when a screen is
 * added.
 */
export const ROLE_AREAS = {
  admin: {
    basePath: "/admin",
    label: "Admin",
    links: [
      { to: "/admin", label: "Dashboard", icon: LayoutDashboard, end: true },
      { to: "/admin/doctors", label: "Doctors", icon: Stethoscope },
      { to: "/admin/patients", label: "Patients", icon: Users },
      { to: "/admin/appointments", label: "Appointments", icon: CalendarCheck },
      { to: "/admin/predictions", label: "Predictions", icon: Activity },
      { to: "/admin/profile", label: "Profile", icon: UserRound },
    ],
    pending: [],
  },
  doctor: {
    basePath: "/doctor",
    label: "Doctor",
    links: [
      { to: "/doctor", label: "Dashboard", icon: LayoutDashboard, end: true },
      { to: "/doctor/appointments", label: "Appointments", icon: CalendarCheck },
      { to: "/doctor/patients", label: "Patients", icon: Users },
      { to: "/doctor/profile", label: "Profile", icon: UserRound },
    ],
    pending: [],
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
  const path = pathname.length > 1 ? pathname.replace(/\/+$/, "") : pathname;
  const match = area.links.find((link) => link.to === path);
  return match ? match.label : area.label;
}
