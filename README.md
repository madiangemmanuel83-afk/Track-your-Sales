# Sales Tracker app (email sign-in, shared shop, works offline)

Files: index.html (the app), config.js (your two Supabase keys), sw.js + manifest.json + icons (installable/offline),
supabase_setup.sql (database, run once). Everything uses free plans.

## Step 1 - Create the free database (10 minutes, once)
1. Go to supabase.com, create a free account and click "New project" (any name, choose a region close to Kenya, set a database password and keep it).
2. When the project is ready, open **SQL Editor -> New query**, paste all of `supabase_setup.sql`, click **Run**. It should say "Success".
3. Open **Project Settings -> API**. Copy the **Project URL** and the **anon public** key.
4. Open `config.js` in Notepad and paste them between the quotes. Save.
5. Optional but easier: **Authentication -> Providers -> Email**, turn OFF "Confirm email" so new accounts can sign in immediately. If you leave it on, people confirm through an email link first.
6. **Authentication -> URL Configuration:** set Site URL to your hosted app address (Step 2). This makes "Forgot password" links come back to your app.

## Step 2 - Put the app online (free)
Upload this whole folder to a free static host: Netlify (drag the folder onto its deploy page), Cloudflare Pages or GitHub Pages. Make sure the address is NOT password protected (that gave the 401 error you saw). You get an https:// link.

## Step 3 - Install on each phone
Open the link in Chrome with internet, wait a few seconds, then menu -> **Install app** / **Add to Home Screen**.

## Step 4 - Sign in and share
- **Owner:** Setup -> Account & sync -> enter email + password -> **Create account** -> sign in -> **Create my shop**. A 6-character **shop code** appears.
- **Person who sells for you:** on their phone, same link, **Create account**, sign in, choose **I work in someone's shop**, type your code. You both now see the same sales; the **By** column shows who recorded each one.
- **Offline:** record sales with no internet; they show a clock icon and upload automatically when the phone is online again.

## Good to know
- Everyone in a shop can add, edit and delete records; only the owner sees "Erase everything".
- Sign-out on a phone clears that phone's copy (your data stays in the cloud). If changes are still waiting to sync, it warns you first.
- If two people edit the same record offline, the last one to sync wins.
- The free Supabase plan pauses projects left unused for about a week; open the app now and then (or unpause in the dashboard).
- Keep the anon key as is; it is meant to be public. Never share your database password or "service role" key.
