// ============================================================
//  auth.js — navbar auth state + per-page guard
// ============================================================

function updateNavbar() {
  const user = getUser();
  const navLinks = document.getElementById('nav-links');
  if (!navLinks) return;

  if (user) {
    navLinks.innerHTML = `
      <span class="text-muted" style="font-size:0.85rem">Hi, ${user.name.split(' ')[0]}</span>
      <a href="/mybookings.html">My Bookings</a>
      ${user.role === 'admin' ? '<a href="/admin.html">Admin</a>' : ''}
      <button class="btn btn-secondary btn-sm" onclick="logout()">Logout</button>
    `;
  } else {
    navLinks.innerHTML = `
      <a href="/auth.html">Login</a>
      <a href="/auth.html?mode=register" class="btn btn-primary btn-sm">Sign Up</a>
    `;
  }
}

function logout() {
  clearAuth();
  window.location.href = '/';
}

function requireAuth() {
  if (!getToken()) {
    window.location.href = '/auth.html?redirect=' + encodeURIComponent(window.location.href);
  }
}

function requireAdmin() {
  const user = getUser();
  if (!user || user.role !== 'admin') {
    window.location.href = '/';
  }
}

document.addEventListener('DOMContentLoaded', updateNavbar);
