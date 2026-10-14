/*
 * Small display helpers shared by the management screens, so a date or a
 * status looks the same on every page.
 */

// Badge colour for each appointment status
export const STATUS_VARIANT = {
  Pending: "warning",
  Approved: "info",
  Completed: "success",
  Rejected: "danger",
};

export const APPOINTMENT_STATUSES = Object.keys(STATUS_VARIANT);

// Badge colour for each prediction risk band
export const RISK_VARIANT = {
  High: "danger",
  Moderate: "warning",
  Low: "success",
};

export function formatDate(value) {
  if (!value) return "—";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "—";
  return date.toLocaleDateString(undefined, { day: "numeric", month: "short", year: "numeric" });
}

export function formatDateTime(value) {
  if (!value) return "—";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "—";
  return date.toLocaleString(undefined, {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "numeric",
    minute: "2-digit",
  });
}

// "2026-10-21" for an <input type="date">
export function toDateInput(value) {
  if (!value) return "";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  return date.toISOString().slice(0, 10);
}

export function isToday(value) {
  if (!value) return false;
  return new Date(value).toDateString() === new Date().toDateString();
}

// Accounts created before names existed have none, so fall back to the email
export function personName(user) {
  if (!user) return "Deleted account";
  return user.name || user.email || "Unnamed";
}

export function doctorName(doctor) {
  if (!doctor) return "Deleted doctor";
  const name = personName(doctor.user);
  return name.startsWith("Dr") ? name : `Dr. ${name}`;
}

export function formatFee(fee) {
  if (fee === undefined || fee === null || fee === "") return "—";
  return `₹${Number(fee).toLocaleString("en-IN")}`;
}

export function initials(user) {
  const source = (user?.name || user?.email || "?").trim();
  const parts = source.split(/\s+/).filter(Boolean);
  if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
  return source.slice(0, 2).toUpperCase();
}

// Minutes since midnight for "10:30 AM" or "14:30", so a day's times sort
// correctly; anything unreadable goes last
export function minutesOf(time) {
  const match = /^(\d{1,2}):(\d{2})\s*(AM|PM)?$/i.exec(String(time || "").trim());
  if (!match) return 24 * 60;
  const meridiem = match[3]?.toUpperCase();
  let hours = Number(match[1]);
  if (meridiem) hours = (hours % 12) + (meridiem === "PM" ? 12 : 0);
  return hours * 60 + Number(match[2]);
}
