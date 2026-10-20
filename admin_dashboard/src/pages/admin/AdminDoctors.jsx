import { useState } from "react";
import { Pencil, Plus, Trash2 } from "lucide-react";
import PageToolbar from "../../components/PageToolbar";
import DataTable from "../../components/DataTable";
import Modal from "../../components/Modal";
import ConfirmDialog from "../../components/ConfirmDialog";
import LoadingState from "../../components/LoadingState";
import ErrorState from "../../components/ErrorState";
import { useToast } from "../../components/Toast";
import { useResource } from "../../hooks/useResource";
import { createDoctor, deleteDoctor, listDoctors, updateDoctor } from "../../api/adminApi";
import { getErrorMessage } from "../../api/axiosInstance";
import { doctorName, formatFee } from "../../utils/format";

const EMPTY_FORM = {
  name: "",
  email: "",
  phone: "",
  password: "",
  specialization: "",
  qualification: "",
  experience: "",
  hospital: "",
  fee: "",
  availability: "",
};

function formFromDoctor(doctor) {
  return {
    name: doctor.user?.name || "",
    email: doctor.user?.email || "",
    phone: doctor.user?.phone || "",
    password: "",
    specialization: doctor.specialization || "",
    qualification: doctor.qualification || "",
    experience: doctor.experience ?? "",
    hospital: doctor.hospital || "",
    fee: doctor.fee ?? "",
    availability: doctor.availability || "",
  };
}

// Mirrors the backend's rules so most mistakes are caught before the request
function validate(form, isNew) {
  const errors = {};
  if (!form.name.trim()) errors.name = "Enter the doctor's name.";
  if (!/^\S+@\S+\.\S+$/.test(form.email.trim())) errors.email = "Enter a valid email address.";
  if (!/^[0-9]{10}$/.test(form.phone.trim())) errors.phone = "Phone number must be exactly 10 digits.";
  if (isNew && form.password.length < 6) errors.password = "Use at least 6 characters.";
  if (!form.specialization.trim()) errors.specialization = "Enter a specialization.";
  if (!form.qualification.trim()) errors.qualification = "Enter a qualification.";
  if (form.experience !== "" && !(Number(form.experience) >= 0)) errors.experience = "Must be 0 or more.";
  if (form.fee !== "" && !(Number(form.fee) >= 0)) errors.fee = "Must be 0 or more.";
  return errors;
}

function toPayload(form, isNew) {
  const payload = {
    name: form.name.trim(),
    email: form.email.trim(),
    phone: form.phone.trim(),
    specialization: form.specialization.trim(),
    qualification: form.qualification.trim(),
    hospital: form.hospital.trim(),
    availability: form.availability.trim(),
    experience: form.experience === "" ? 0 : Number(form.experience),
    fee: form.fee === "" ? 0 : Number(form.fee),
  };
  if (isNew) payload.password = form.password;
  return payload;
}

function Field({ label, name, form, errors, onChange, type = "text", full = false, hint, ...rest }) {
  const id = `doctor-${name}`;
  return (
    <div className={`field${full ? " field-full" : ""}`}>
      <label className="field-label" htmlFor={id}>
        {label}
      </label>
      <input
        id={id}
        name={name}
        type={type}
        className="field-input"
        value={form[name]}
        onChange={onChange}
        aria-invalid={Boolean(errors[name])}
        {...rest}
      />
      {errors[name] ? <span className="field-error">{errors[name]}</span> : hint && <span className="field-hint">{hint}</span>}
    </div>
  );
}

function DoctorForm({ doctor, onClose, onSaved }) {
  const isNew = !doctor;
  const [form, setForm] = useState(isNew ? EMPTY_FORM : formFromDoctor(doctor));
  const [errors, setErrors] = useState({});
  const [serverError, setServerError] = useState("");
  const [saving, setSaving] = useState(false);

  const onChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
    setErrors((current) => ({ ...current, [name]: undefined }));
  };

  const submit = async (event) => {
    event.preventDefault();
    const found = validate(form, isNew);
    setErrors(found);
    if (Object.keys(found).length > 0) return;

    setSaving(true);
    setServerError("");
    try {
      const payload = toPayload(form, isNew);
      if (isNew) await createDoctor(payload);
      else await updateDoctor(doctor._id, payload);
      onSaved(isNew ? `${doctorName({ user: payload })} was added.` : "Changes saved.");
    } catch (requestError) {
      setServerError(getErrorMessage(requestError, "Could not save the doctor."));
      setSaving(false);
    }
  };

  const shared = { form, errors, onChange };

  return (
    <Modal
      title={isNew ? "Add doctor" : `Edit ${doctorName(doctor)}`}
      onClose={onClose}
      width={640}
      footer={
        <>
          <button type="button" className="btn btn-secondary" onClick={onClose} disabled={saving}>
            Cancel
          </button>
          <button type="submit" form="doctor-form" className="btn btn-primary" disabled={saving}>
            {saving ? "Saving…" : isNew ? "Add doctor" : "Save changes"}
          </button>
        </>
      }
    >
      {serverError && <p className="alert alert-danger">{serverError}</p>}
      <form id="doctor-form" className="form-grid" onSubmit={submit} noValidate>
        <Field label="Full name" name="name" placeholder="e.g. Meera Shah" autoFocus {...shared} />
        <Field label="Phone" name="phone" inputMode="numeric" maxLength={10} placeholder="10 digits" {...shared} />
        <Field label="Email" name="email" type="email" placeholder="doctor@hospital.com" {...shared} />
        {isNew ? (
          <Field
            label="Temporary password"
            name="password"
            type="password"
            autoComplete="new-password"
            hint="Share it with the doctor; they sign in with this email and password."
            {...shared}
          />
        ) : (
          <div className="field">
            <span className="field-label">Password</span>
            <span className="field-hint">Passwords are not shown or changed here.</span>
          </div>
        )}
        <Field label="Specialization" name="specialization" placeholder="e.g. Cardiologist" {...shared} />
        <Field label="Qualification" name="qualification" placeholder="e.g. MBBS, MD" {...shared} />
        <Field label="Experience (years)" name="experience" type="number" min="0" {...shared} />
        <Field label="Consultation fee (₹)" name="fee" type="number" min="0" {...shared} />
        <Field label="Hospital or clinic" name="hospital" full {...shared} />
        <Field label="Availability" name="availability" full placeholder="e.g. Mon–Fri, 10:00 AM – 2:00 PM" {...shared} />
      </form>
    </Modal>
  );
}

export default function AdminDoctors() {
  const notify = useToast();
  const [search, setSearch] = useState("");
  const [editing, setEditing] = useState(null); // null, "new" or a doctor
  const [deleting, setDeleting] = useState(null);
  const { data, status, error, reload } = useResource(() => listDoctors(search), [search], "Could not load doctors.");

  const columns = [
    {
      key: "doctor",
      label: "Doctor",
      render: (doctor) => (
        <div>
          <div className="table-primary">{doctorName(doctor)}</div>
          <div className="table-muted">{doctor.user?.email}</div>
        </div>
      ),
    },
    {
      key: "specialization",
      label: "Specialization",
      render: (doctor) => (
        <div>
          <div>{doctor.specialization}</div>
          <div className="table-muted">{doctor.qualification}</div>
        </div>
      ),
    },
    { key: "hospital", label: "Hospital", render: (doctor) => doctor.hospital || "—" },
    { key: "experience", label: "Experience", render: (doctor) => `${doctor.experience ?? 0} yrs` },
    { key: "fee", label: "Fee", render: (doctor) => formatFee(doctor.fee) },
    { key: "phone", label: "Phone", render: (doctor) => doctor.user?.phone || "—" },
    {
      key: "actions",
      label: "Actions",
      render: (doctor) => (
        <div className="table-actions">
          <button type="button" className="btn btn-secondary btn-sm" onClick={() => setEditing(doctor)}>
            <Pencil size={14} /> Edit
          </button>
          <button type="button" className="btn btn-danger-outline btn-sm" onClick={() => setDeleting(doctor)}>
            <Trash2 size={14} /> Delete
          </button>
        </div>
      ),
    },
  ];

  return (
    <>
      <div className="page-header">
        <h2>Doctors</h2>
        <p className="page-subtitle">Add doctors, keep their details current, and remove accounts that are no longer needed.</p>
      </div>

      <PageToolbar search={search} onSearch={setSearch} placeholder="Search doctors">
        <button type="button" className="btn btn-primary" onClick={() => setEditing("new")}>
          <Plus size={18} /> Add doctor
        </button>
      </PageToolbar>

      {status === "loading" && <LoadingState message="Loading doctors" />}
      {status === "error" && <ErrorState title="Could not load doctors" message={error} onRetry={reload} />}
      {status === "ready" && (
        <DataTable
          columns={columns}
          rows={data}
          empty={search ? `No doctors match “${search}”.` : "No doctors yet. Use Add doctor to create the first one."}
        />
      )}

      {editing && (
        <DoctorForm
          doctor={editing === "new" ? null : editing}
          onClose={() => setEditing(null)}
          onSaved={(message) => {
            setEditing(null);
            notify(message);
            reload({ quiet: true });
          }}
        />
      )}

      {deleting && (
        <ConfirmDialog
          title="Delete doctor"
          message={`Delete ${doctorName(deleting)}? Their login account and all of their appointments are removed as well. This cannot be undone.`}
          onClose={() => setDeleting(null)}
          onConfirm={async () => {
            await deleteDoctor(deleting._id);
            notify(`${doctorName(deleting)} was deleted.`);
            reload({ quiet: true });
          }}
        />
      )}
    </>
  );
}
