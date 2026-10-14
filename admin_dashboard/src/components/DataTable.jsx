import "./DataTable.css";

/*
 * A plain table for the management screens.
 *
 * `columns` is [{ key, label, render?, width? }]. On narrow screens each row
 * becomes a stacked card, with the column label shown beside the value, so the
 * same markup works on a phone without a second layout.
 */
export default function DataTable({ columns, rows, keyField = "_id", empty = "Nothing to show yet." }) {
  if (!rows || rows.length === 0) {
    return <p className="table-empty">{empty}</p>;
  }

  return (
    <div className="table-wrap">
      <table className="data-table">
        <thead>
          <tr>
            {columns.map((column) => (
              <th key={column.key} style={column.width ? { width: column.width } : undefined}>
                {column.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row[keyField]}>
              {columns.map((column) => (
                <td key={column.key} data-label={column.label}>
                  {column.render ? column.render(row) : (row[column.key] ?? "—")}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
