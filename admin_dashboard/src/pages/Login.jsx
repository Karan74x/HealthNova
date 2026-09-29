import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { AlertCircle, Eye, EyeOff } from "lucide-react";
import { useAuth } from "../hooks/useAuth";
import { getErrorMessage } from "../api/axiosInstance";
import { getLandingPath } from "../config/navigation";
import "./Login.css";

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default function Login() {
  const [form, setForm] = useState({ email: "", password: "" });
  const [fieldErrors, setFieldErrors] = useState({});
  const [formError, setFormError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const sessionExpired = searchParams.get("expired") === "1";

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((previous) => ({ ...previous, [name]: value }));
    setFieldErrors((previous) => ({ ...previous, [name]: "" }));
  };

  const validate = () => {
    const errors = {};
    if (!form.email.trim()) {
      errors.email = "Email is required";
    } else if (!EMAIL_PATTERN.test(form.email.trim())) {
      errors.email = "Enter a valid email address";
    }
    // The backend model requires at least 6 characters.
    if (!form.password) {
      errors.password = "Password is required";
    } else if (form.password.length < 6) {
      errors.password = "Password must be at least 6 characters";
    }
    return errors;
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setFormError("");

    const errors = validate();
    if (Object.keys(errors).length > 0) {
      setFieldErrors(errors);
      return;
    }

    setIsSubmitting(true);
    try {
      const user = await login(form.email.trim(), form.password);
      // The role decides the area. A patient authenticates successfully but has
      // no web area, so they land on Access Denied rather than a dashboard.
      navigate(getLandingPath(user.role), { replace: true });
    } catch (error) {
      setFormError(
        getErrorMessage(error, "Unable to sign in. Please try again."),
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="login-page">
      <div className="login-card">
        <div className="login-brand">
          <h1 className="login-title">
            <img
              src="/logo-full.png"
              alt="HealthNova"
              className="login-logo"
              width="260"
              height="69"
            />
          </h1>
          <p className="login-subtitle">Admin &amp; Doctor Dashboard</p>
        </div>

        {sessionExpired && (
          <div className="alert alert-info">
            <AlertCircle size={18} aria-hidden="true" />
            <span>Your session has ended. Please sign in again.</span>
          </div>
        )}

        {formError && (
          <div className="alert alert-danger" role="alert">
            <AlertCircle size={18} aria-hidden="true" />
            <span>{formError}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} noValidate>
          <div className="field">
            <label className="field-label" htmlFor="email">
              Email
            </label>
            <input
              id="email"
              name="email"
              type="email"
              className="field-input"
              placeholder="you@healthnova.com"
              value={form.email}
              onChange={handleChange}
              autoComplete="email"
              aria-invalid={Boolean(fieldErrors.email)}
            />
            {fieldErrors.email && (
              <span className="field-error">{fieldErrors.email}</span>
            )}
          </div>

          <div className="field">
            <label className="field-label" htmlFor="password">
              Password
            </label>
            <div className="login-password">
              <input
                id="password"
                name="password"
                type={showPassword ? "text" : "password"}
                className="field-input"
                placeholder="Enter your password"
                value={form.password}
                onChange={handleChange}
                autoComplete="current-password"
                aria-invalid={Boolean(fieldErrors.password)}
              />
              <button
                type="button"
                className="login-password-toggle"
                onClick={() => setShowPassword((previous) => !previous)}
                aria-label={showPassword ? "Hide password" : "Show password"}
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
            {fieldErrors.password && (
              <span className="field-error">{fieldErrors.password}</span>
            )}
          </div>

          <button
            type="submit"
            className="btn btn-primary btn-block"
            disabled={isSubmitting}
          >
            {isSubmitting ? "Signing in…" : "Sign in"}
          </button>
        </form>

        <p className="login-footnote">
          Administrator and doctor accounts only. Patients use the HealthNova
          mobile app.
        </p>
      </div>
    </div>
  );
}
