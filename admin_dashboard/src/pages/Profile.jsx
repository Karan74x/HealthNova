import { useEffect, useState } from "react";
import LoadingState from "../components/LoadingState";
import ErrorState from "../components/ErrorState";
import Badge from "../components/Badge";
import { useToast } from "../components/Toast";
import { useResource } from "../hooks/useResource";
import { useAuth } from "../hooks/useAuth";
import { getMe, getProfile, updateMe } from "../api/userApi";
import { getMyProfile, updateMyProfile } from "../api/doctorApi";
import { getErrorMessage } from "../api/axiosInstance";
import { formatDate, formatDateTime, initials, toDateInput } from "../utils/format";
import "./Profile.css";

const GENDERS = [
  { value: "", label: "Prefer not to say" },
  { value: "Male", label: "Male" },
  { value: "Female", label: "Female" },
  { value: "other", label: "Other" },
];

function SaveBar({ saving, dirty, onReset }) {
  return (
    <div className="profile-actions">
      <button type="button" className="btn btn-secondary" onClick={onReset} disabled={saving || !dirty}>
        Reset
      </button>
      <button type="submit" className="btn btn-primary" disabled={saving || !dirty}>
        {saving ? "Saving…" : "Save changes"}
      </button>
    </div>
  );
}

// Name, phone, gender and date of birth - the same for every role
function AccountForm({ account, onSaved }) {
  const initial = {
    name: account.name || "",
    phone: account.phone || "",
    gender: account.gender || "",
    dob: toDateInput(account.dob),
  };
  const [form, setForm] = useState(initial);
  const [errors, setErrors] = useState({});
  const [serverError, setServerError] = useState("");
  const [saving, setSaving] = useState(false);
  const dirty = JSON.stringify(form) !== JSON.stringify(initial);

  const onChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
    setErrors((current) => ({ ...current, [name]: undefined }));
  };

  const submit = async (event) => {
    event.preventDefault();
    const found = {};
    if (!form.name.trim()) found.name = "Enter your name.";
    if (!/^[0-9]{10}$/.test(form.phone.trim())) found.phone = "Phone number must be exactly 10 digits.";
    if (form.dob && new Date(form.dob) > new Date()) found.dob = "Date of birth cannot be in the future.";
    setErrors(found);
    if (Object.keys(found).length > 0) return;

    setSaving(true);
    setServerError("");
    try {
      const { data } = await updateMe({
        name: form.name.trim(),
        phone: form.phone.trim(),
        gender: form.gender,
        dob: form.dob,
      });
      onSaved(data.data);
    } catch (requestError) {
      setServerError(getErrorMessage(requestError, "Could not save your details."));
    } finally {
      setSaving(false);
    }
  };

  return (
    <form className="card profile-card" onSubmit={submit} noValidate>
      <div className="card-header">
        <span className="card-title">Personal details</span>
      </div>
      {serverError && <p className="alert alert-danger profile-alert">{serverError}</p>}
      <div className="form-grid">
        <div className="field">
          <label className="field-label" htmlFor="profile-name">
            Full name
          </label>
          <input
            id="profile-name"
            name="name"
            className="field-input"
            value={form.name}
            onChange={onChange}
            aria-invalid={Boolean(errors.name)}
          />
          {errors.name && <span className="field-error">{errors.name}</span>}
        </div>
        <div className="field">
          <label className="field-label" htmlFor="profile-phone">
            Phone
          </label>
          <input
            id="profile-phone"
            name="phone"
            className="field-input"
            inputMode="numeric"
            maxLength={10}
            value={form.phone}
            onChange={onChange}
            aria-invalid={Boolean(errors.phone)}
          />
          {errors.phone && <span className="field-error">{errors.phone}</span>}
        </div>
        <div className="field">
          <label className="field-label" htmlFor="profile-gender">
            Gender
          </label>
          <select id="profile-gender" name="gender" className="field-input" value={form.gender} onChange={onChange}>
            {GENDERS.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>
        <div className="field">
          <label className="field-label" htmlFor="profile-dob">
            Date of birth
          </label>
          <input
            id="profile-dob"
            name="dob"
            type="date"
            className="field-input"
            max={new Date().toISOString().slice(0, 10)}
            value={form.dob}
            onChange={onChange}
            aria-invalid={Boolean(errors.dob)}
          />
          {errors.dob && <span className="field-error">{errors.dob}</span>}
        </div>
      </div>
      <SaveBar saving={saving} dirty={dirty} onReset={() => setForm(initial)} />
    </form>
  );
}

// Practice details a doctor manages themselves
function PracticeForm({ onSaved }) {
  const { data, status, error, reload } = useResource(getMyProfile, [], "Could not load your practice details.");
  const [form, setForm] = useState(null);
  const [errors, setErrors] = useState({});
  const [serverError, setServerError] = useState("");
  const [saving, setSaving] = useState(false);

  const fromDoctor = (doctor) => ({
    hospital: doctor.hospital || "",
    experience: String(doctor.experience ?? ""),
    fee: String(doctor.fee ?? ""),
    availability: doctor.availability || "",
  });

  useEffect(() => {
    if (data) setForm(fromDoctor(data));
  }, [data]);

  if (status === "loading" || (status === "ready" && !form)) {
    return (
      <section className="card profile-card">
        <LoadingState message="Loading practice details" />
      </section>
    );
  }

  if (status === "error") {
    return (
      <section className="card profile-card">
        <ErrorState title="Practice details unavailable" message={error} onRetry={reload} />
      </section>
    );
  }

  const initial = fromDoctor(data);
  const dirty = JSON.stringify(form) !== JSON.stringify(initial);

  const onChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
    setErrors((current) => ({ ...current, [name]: undefined }));
  };

  const submit = async (event) => {
    event.preventDefault();
    const found = {};
    if (form.experience !== "" && !(Number(form.experience) >= 0)) found.experience = "Must be 0 or more.";
    if (form.fee !== "" && !(Number(form.fee) >= 0)) found.fee = "Must be 0 or more.";
    setErrors(found);
    if (Object.keys(found).length > 0) return;

    setSaving(true);
    setServerError("");
    try {
      await updateMyProfile({
        hospital: form.hospital.trim(),
        availability: form.availability.trim(),
        experience: form.experience === "" ? 0 : Number(form.experience),
        fee: form.fee === "" ? 0 : Number(form.fee),
      });
      await reload({ quiet: true });
      onSaved();
    } catch (requestError) {
      setServerError(getErrorMessage(requestError, "Could not save your practice details."));
    } finally {
      setSaving(false);
    }
  };

  return (
    <form className="card profile-card" onSubmit={submit} noValidate>
      <div className="card-header">
        <span className="card-title">Practice details</span>
      </div>
      {serverError && <p className="alert alert-danger profile-alert">{serverError}</p>}
      <dl className="profile-list profile-fixed">
        <div className="profile-row">
          <dt>Specialization</dt>
          <dd>{data.specialization}</dd>
        </div>
        <div className="profile-row">
          <dt>Qualification</dt>
          <dd>{data.qualification}</dd>
        </div>
      </dl>
      <p className="field-hint profile-fixed-note">
        Specialization and qualification are set by the administrator.
      </p>
      <div className="form-grid">
        <div className="field field-full">
          <label className="field-label" htmlFor="practice-hospital">
            Hospital or clinic
          </label>
          <input id="practice-hospital" name="hospital" className="field-input" value={form.hospital} onChange={onChange} />
        </div>
        <div className="field">
          <label className="field-label" htmlFor="practice-experience">
            Experience (years)
          </label>
          <input
            id="practice-experience"
            name="experience"
            type="number"
            min="0"
            className="field-input"
            value={form.experience}
            onChange={onChange}
            aria-invalid={Boolean(errors.experience)}
          />
          {errors.experience && <span className="field-error">{errors.experience}</span>}
        </div>
        <div className="field">
          <label className="field-label" htmlFor="practice-fee">
            Consultation fee (₹)
          </label>
          <input
            id="practice-fee"
            name="fee"
            type="number"
            min="0"
            className="field-input"
            value={form.fee}
            onChange={onChange}
            aria-invalid={Boolean(errors.fee)}
          />
          {errors.fee && <span className="field-error">{errors.fee}</span>}
        </div>
        <div className="field field-full">
          <label className="field-label" htmlFor="practice-availability">
            Availability
          </label>
          <input
            id="practice-availability"
            name="availability"
            className="field-input"
            placeholder="e.g. Mon–Fri, 10:00 AM – 2:00 PM"
            value={form.availability}
            onChange={onChange}
          />
          <span className="field-hint">Patients see this in the app when they book you.</span>
        </div>
      </div>
      <SaveBar saving={saving} dirty={dirty} onReset={() => setForm(initial)} />
    </form>
  );
}

export default function Profile() {
  const { user, updateUser } = useAuth();
  const notify = useToast();
  const account = useResource(getMe, [], "Could not load your account.");
  // /user/profile answers { message, user } with the verified token payload,
  // so it is reshaped into the { data } form useResource expects
  const session = useResource(
    () => getProfile().then((response) => ({ data: { data: response.data.user } })),
    [],
    "Could not load the session details.",
  );
  const isDoctor = user.role === "doctor";

  if (account.status === "loading") {
    return <LoadingState message="Loading profile" />;
  }

  if (account.status === "error") {
    return <ErrorState title="Could not load your profile" message={account.error} onRetry={account.reload} />;
  }

  return (
    <>
      <div className="page-header">
        <h2>Profile</h2>
        <p className="page-subtitle">Keep your details up to date.</p>
      </div>

      <section className="card profile-card profile-identity">
        <span className="profile-avatar" aria-hidden="true">
          {initials(account.data)}
        </span>
        <div className="profile-identity-text">
          <p className="card-title">{account.data.name || account.data.email}</p>
          <p className="card-subtitle">{account.data.email}</p>
        </div>
        <Badge variant="info">{account.data.role}</Badge>
      </section>

      <AccountForm
        key={account.data.updatedAt}
        account={account.data}
        onSaved={(saved) => {
          updateUser({ name: saved.name, phone: saved.phone });
          notify("Your details were saved.");
          account.reload({ quiet: true });
        }}
      />

      {isDoctor && <PracticeForm onSaved={() => notify("Practice details saved.")} />}

      <section className="card profile-card">
        <div className="card-header">
          <span className="card-title">Account</span>
        </div>
        <dl className="profile-list">
          <div className="profile-row">
            <dt>Email</dt>
            <dd>{account.data.email}</dd>
          </div>
          <div className="profile-row">
            <dt>Member since</dt>
            <dd>{formatDate(account.data.createdAt)}</dd>
          </div>
          <div className="profile-row">
            <dt>Session expires</dt>
            <dd>{session.data?.exp ? formatDateTime(session.data.exp * 1000) : "—"}</dd>
          </div>
          <div className="profile-row">
            <dt>User ID</dt>
            <dd className="profile-mono">{account.data._id}</dd>
          </div>
        </dl>
        <p className="field-hint">The email address is the sign-in name and cannot be changed here.</p>
      </section>
    </>
  );
}
