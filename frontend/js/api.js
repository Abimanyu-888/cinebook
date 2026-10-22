// ============================================================
//  api.js — centralised fetch() helpers
// ============================================================

const API_BASE = '/api';

function getToken() {
  return localStorage.getItem('token');
}

function getUser() {
  const u = localStorage.getItem('user');
  return u ? JSON.parse(u) : null;
}

function setAuth(token, user) {
  localStorage.setItem('token', token);
  localStorage.setItem('user', JSON.stringify(user));
}

function clearAuth() {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
}

async function request(method, path, body = null, auth = false) {
  const headers = { 'Content-Type': 'application/json' };
  if (auth) {
    const token = getToken();
    if (!token) { window.location.href = '/auth.html'; return; }
    headers['Authorization'] = `Bearer ${token}`;
  }

  const opts = { method, headers };
  if (body) opts.body = JSON.stringify(body);

  const res = await fetch(API_BASE + path, opts);
  const data = await res.json();

  if (!res.ok) throw new Error(data.error || 'Request failed');
  return data;
}

const api = {
  get:    (path, auth = false)         => request('GET',    path, null, auth),
  post:   (path, body, auth = false)   => request('POST',   path, body, auth),
  put:    (path, body, auth = false)   => request('PUT',    path, body, auth),
  delete: (path, auth = false)         => request('DELETE', path, null, auth),
};
