import { createContext, useCallback, useEffect, useMemo, useState } from "react";
import { login as loginRequest } from "../api/authApi";
import {
  clearSession,
  getStoredUser,
  getToken,
  isTokenExpired,
  saveSession,
} from "./authStorage";

export const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [isRestoring, setIsRestoring] = useState(true);

  // Restore a previous session on reload, discarding an expired token.
  useEffect(() => {
    const token = getToken();
    const storedUser = getStoredUser();

    if (token && storedUser && !isTokenExpired(token)) {
      setUser(storedUser);
    } else if (token) {
      clearSession();
    }

    setIsRestoring(false);
  }, []);

  const login = useCallback(async (email, password) => {
    const { data } = await loginRequest(email, password);
    saveSession(data.token, data.user);
    setUser(data.user);
    return data.user;
  }, []);

  const logout = useCallback(() => {
    clearSession();
    setUser(null);
  }, []);

  const value = useMemo(
    () => ({
      user,
      isAuthenticated: Boolean(user),
      isRestoring,
      login,
      logout,
    }),
    [user, isRestoring, login, logout],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
