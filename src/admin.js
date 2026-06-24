import { createClient } from "@supabase/supabase-js";

const ADMIN_EMAIL = "support@euc2.org";
const boot = document.getElementById("boot");
const login = document.getElementById("login");
const shell = document.getElementById("shell");
const errorBox = document.getElementById("login-error");
const submitButton = document.getElementById("login-submit");

function show(view) {
  boot.classList.toggle("hidden", view !== "boot");
  login.classList.toggle("hidden", view !== "login");
  shell.classList.toggle("hidden", view !== "shell");
}

function showError(message) {
  errorBox.textContent = message;
  errorBox.style.display = "block";
}

function clearError() {
  errorBox.textContent = "";
  errorBox.style.display = "none";
}

function isAdmin(user) {
  return user?.email?.toLowerCase() === ADMIN_EMAIL;
}

function showShell(email) {
  document.getElementById("admin-pill").textContent = email.toUpperCase();
  show("shell");
  selectTab("accounts");
}

function selectTab(tab) {
  ["accounts", "katas", "ranks"].forEach((name) => {
    document.getElementById(`tab-${name}`).classList.toggle("hidden", name !== tab);
    document.querySelector(`[data-tab="${name}"]`).classList.toggle("inactive", name !== tab);
  });
}

document.querySelectorAll("[data-tab]").forEach((button) => {
  button.addEventListener("click", () => selectTab(button.dataset.tab));
});

const url = import.meta.env.VITE_SUPABASE_URL;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
let supabase;

if (!url || !anonKey) {
  show("login");
  showError("Admin configuration is incomplete. Add VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in Vercel, then redeploy.");
  submitButton.disabled = true;
} else {
  supabase = createClient(url, anonKey, { auth: { persistSession: true, autoRefreshToken: true } });
  supabase.auth.getSession()
    .then(({ data, error }) => {
      if (error) throw error;
      if (data.session && isAdmin(data.session.user)) showShell(data.session.user.email);
      else if (data.session) return supabase.auth.signOut().then(() => show("login"));
      else show("login");
    })
    .catch((error) => {
      show("login");
      showError(`Unable to check the admin session: ${error.message || "unknown error"}`);
    });
}

document.getElementById("login-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  if (!supabase) return;
  clearError();
  submitButton.disabled = true;
  submitButton.textContent = "Signing in…";
  try {
    const email = document.getElementById("login-email").value.trim();
    const password = document.getElementById("login-password").value;
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    if (!isAdmin(data.user)) {
      await supabase.auth.signOut();
      throw new Error("This account is not authorized for admin access.");
    }
    showShell(data.user.email);
  } catch (error) {
    showError(error.message || "Sign in failed.");
  } finally {
    submitButton.disabled = false;
    submitButton.textContent = "Sign In";
  }
});

document.getElementById("signout-btn").addEventListener("click", async () => {
  if (supabase) await supabase.auth.signOut();
  document.getElementById("login-form").reset();
  clearError();
  show("login");
});
