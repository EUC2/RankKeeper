import { createClient } from "@supabase/supabase-js";

const url = import.meta.env.VITE_SUPABASE_URL;
const anon = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabaseConfigError =
  !url || !anon
    ? "RankKeeper is missing its Supabase login settings. Check VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in Vercel."
    : null;

if (supabaseConfigError) {
  // Helps diagnose a missing/misnamed Vercel environment variable.
  console.error(supabaseConfigError);
}

export const supabase = supabaseConfigError
  ? null
  : createClient(url, anon, {
      auth: { persistSession: true, autoRefreshToken: true },
    });
