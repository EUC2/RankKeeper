# UPLOAD THIS RANKKEEPER PACKAGE

Upload or deploy the contents of this folder as the RankKeeper project root.

## Routes

- `/` or `index.html` is the public RankKeeper marketing/pricing page.
- `/app` or `app.html` is the secure RankKeeper app login.
- `/login` also opens the secure RankKeeper app login.
- `/tournament360`, `/tournament360/`, or `/t360` opens the logged-in RankKeeper app shell and then shows the Phase 1 Tournament360 system module.
- `/tournament360-app.html` is an internal Phase 1 module file used by the authenticated app shell, not a public marketing page.
- `/tournament360-overview` opens the older visual overview/mockup page if you still need it for reference.
- `/admin` opens the admin/Dojo Wall page.

## Tournament360 Phase 1

Phase 1 is a local/in-browser system prototype. It includes the admin command
center, tournament setup, editable entry-fee ladder, division-combine workflow,
long division checkbox table, source-labeled CSV import preview, QR check-in
explanation and sample records, staging, ring bracket review, scoring timer
explanation, staging, ring bracket review, scoring timer states, and audience
bracket/scoreboard displays. It ships with empty local state only — no test
athletes, fake registrations, sample divisions, or demo tournament records.
Supabase persistence, Stripe checkout for tournament registrations, SMS
delivery, and live QR token validation are Phase 2+ backend work.

Pricing is built into the main page at `index.html#pricing`; the `pricing.html`
and `pricing/` files only redirect there so hosted routes do not 404.

## Favicon / app icon

The package includes explicit favicon links on the marketing, app, pricing, and
admin entry pages. It also includes both `/favicon.ico` and `/favicon.png`
fallbacks so browser tabs do not show the generic missing-icon state.

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
