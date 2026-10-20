import { Search } from "lucide-react";
import "./PageToolbar.css";

/*
 * The search box and filter row above each management table. Searching is
 * submitted with Enter rather than on every keystroke, so the list is not
 * refetched for each letter typed.
 */
export default function PageToolbar({ search, onSearch, placeholder = "Search", filters, children }) {
  return (
    <div className="toolbar">
      {onSearch && (
        <form
          className="toolbar-search"
          role="search"
          onSubmit={(event) => {
            event.preventDefault();
            onSearch(new FormData(event.currentTarget).get("q").toString().trim());
          }}
        >
          <Search size={16} aria-hidden="true" />
          <input name="q" type="search" defaultValue={search} placeholder={placeholder} aria-label={placeholder} />
        </form>
      )}

      {filters && <div className="toolbar-filters">{filters}</div>}

      {children && <div className="toolbar-actions">{children}</div>}
    </div>
  );
}

/* A row of status filter chips; "" means all */
export function StatusFilters({ value, onChange, options }) {
  return (
    <>
      {["", ...options].map((option) => (
        <button
          key={option || "all"}
          type="button"
          className={`filter-chip${value === option ? " is-active" : ""}`}
          aria-pressed={value === option}
          onClick={() => onChange(option)}
        >
          {option || "All"}
        </button>
      ))}
    </>
  );
}
