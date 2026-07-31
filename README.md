# RankKeeper website mockup

This folder contains a two-page static website mockup:

- `index.html` — landing page with RankKeeper features and sample T Elite Martial Arts branding.
- `pricing.html` — pricing page with Stripe-hosted checkout links for RankKeeper subscriptions.
- `pricing/` — clean pricing route fallback for static hosts.
- `vercel.json` — Vercel routing support for `/pricing` and `/pricing/`.

The subscription checkout buttons use public Stripe Payment Links. No Stripe secret keys, webhook secrets, Supabase keys, passwords, or private credentials are included.

Sample school identity used in the mockup:

- T Elite Martial Arts
- Sensei Faouzi Touati

Monthly plans are marketed with a 7-day free trial. Annual plans are marketed with a 30-day free trial and annual savings messaging.
