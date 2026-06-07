# RankKeeper

Belt-grading app for karate senseis. Built with React + Vite.

## Put it online (no Terminal needed)

1. Make two free accounts: github.com and vercel.com (sign in to Vercel with "Continue with GitHub").
2. On GitHub: New repository (name it "rankkeeper", Public is fine) > then on the repo page,
   "Add file" > "Upload files" > drag in EVERYTHING from this folder (package.json, index.html,
   vite.config.js, .gitignore, README.md, and the whole src folder) > "Commit changes".
3. On Vercel: "Add New..." > "Project" > Import the rankkeeper repo > click "Deploy".
   Vercel installs and builds it in the cloud (about a minute) and gives you a live link.

You do NOT need Node.js or Terminal for this. Vercel does the building for you.

## Notes
- Data is saved in the browser on each device (localStorage). Great for testing and single-sensei use.
- For multi-device sync + selling, swap localStorage for a cloud database (e.g. Supabase) later.
