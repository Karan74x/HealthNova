import { useCallback, useEffect, useRef, useState } from "react";
import { getErrorMessage } from "../api/axiosInstance";

/*
 * Loads something from the API and tracks the three states every screen
 * needs: loading, error (with a retry) and ready.
 *
 *   const { data, status, error, reload } = useResource(() => api.list(search), [search]);
 *
 * The request re-runs whenever a value in `deps` changes. `reload()` runs it
 * again on demand; `reload({ quiet: true })` refreshes in the background
 * without flashing the loading state, which is what a screen wants after it
 * has changed something.
 */
export function useResource(fetcher, deps = [], fallbackMessage = "Could not load this data.") {
  const [data, setData] = useState(null);
  const [status, setStatus] = useState("loading");
  const [error, setError] = useState("");

  // Always call the latest fetcher without making it a dependency
  const fetcherRef = useRef(fetcher);
  fetcherRef.current = fetcher;
  // Ignore responses that arrive after a newer request was started
  const requestId = useRef(0);

  const load = useCallback(
    async ({ quiet = false } = {}) => {
      const id = ++requestId.current;
      if (!quiet) setStatus("loading");
      setError("");
      try {
        const response = await fetcherRef.current();
        if (id !== requestId.current) return;
        setData(response.data.data);
        setStatus("ready");
      } catch (requestError) {
        if (id !== requestId.current) return;
        setError(getErrorMessage(requestError, fallbackMessage));
        setStatus("error");
      }
    },
    [fallbackMessage],
  );

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  return { data, status, error, reload: load };
}
