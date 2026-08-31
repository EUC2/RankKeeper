# UPLOAD THIS RANKKEEPER PACKAGE

Upload or deploy the contents of this folder as the RankKeeper project root.

## Routes

- `/` or `index.html` is the public RankKeeper marketing/pricing page.
- `/app` or `app.html` is the secure RankKeeper app login.
- `/login` also opens the secure RankKeeper app login.
- `/admin` opens the admin/Dojo Wall page.

Pricing is built into the main page at `index.html#pricing`; the `pricing.html`
and `pricing/` files only redirect there so hosted routes do not 404.

## Login fix in this package

The landing-page header has a single `Login` button that opens the real app
login at `/app`. The marketing page no longer has a dropdown/mini-login form,
so customers do not see two login screens and passwords are never entered into
the public marketing page.

The React app now shows a clear configuration message if these Vercel variables
are missing or misnamed:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

## Build

After unzipping or cloning:

```bash
npm install
npm run build
```

The local Codex environment could not complete `npm install` because network
access to the npm registry was blocked, so run the final build check in your
normal deployment environment.

This package includes public Stripe Payment Links only. It does not include
Stripe secret keys, Supabase keys, passwords, or webhook secrets.
