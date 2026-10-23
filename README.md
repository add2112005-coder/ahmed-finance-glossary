# Ahmed Finance Accounting Glossary — Full Learning System

Standalone Cloudflare Worker + D1 project, branded using the supplied Ahmed Finance logo and warm off-white/graphite/orange visual identity.

## Included
- Public bilingual search across the glossary.
- Student registration/login, secure HttpOnly session cookie, PBKDF2 password hashing, logout.
- First account created becomes the initial admin; subsequent accounts are students.
- Persistent student flashcard queue and review scheduling (`Again`, `Hard`, `Good`, `Easy`) using a spaced-repetition interval/ease model.
- Topic quizzes, configurable question count, multiple choice and definition-to-term modes, stored scores/history, incorrect answers added to review.
- Admin-only term creation/editing, category creation, Excel/XLSX/CSV import, content quality dashboard and approval status.
- D1 migration uses glossary-prefixed tables to avoid colliding with the existing Ahmed Finance platform tables.

## Important deployment note
This project is wired to the D1 database configured in `wrangler.toml` (`ahmed`, existing database ID). The migration creates only `glossary_*` tables. The migration file is numbered `0020` to follow the existing Ahmed Finance migrations through `0019`. Do not replace your existing Worker project with this folder; deploy this as its own Worker/site first.

## Deploy
1. Install Node.js and Wrangler: `npm install -g wrangler`
2. From this folder, sign in: `wrangler login`
3. Review `wrangler.toml` and confirm the D1 database ID and name.
4. Apply the migration: `wrangler d1 migrations apply ahmed --remote`
5. Deploy: `wrangler deploy`
6. Open the deployed URL and create the first account. That first account receives the admin role. **Create that account yourself first and do not share the site before it exists.**
7. The site seeds the glossary from `public/terms.json` into D1 on first load. You can also use the Admin page to import updated Excel/CSV files.

## Excel columns
Recognized headers include `English`, `English Term`, `Arabic`, `Arabic Term`, `Definition_EN`, `English Definition`, `Definition_AR`, `Arabic Definition`, and `Category`/`Topic`. Unknown/missing translations and definitions are marked as needing review.

## Notes
- Search is public; account is required to save cards, review progress, and persist quiz results.
- D1 stores password hashes, sessions, review schedules, quiz results, categories, and terms. Sessions are stored as token hashes and delivered through an HttpOnly, Secure, SameSite=Lax cookie.
- The first account bootstrap is deliberately simple for this initial private deployment. Keep access restricted until the administrator account is created.
- Excel parsing loads SheetJS from its public CDN; deploy with internet access for XLSX import. CSV import works through the same parser.
- Test a staging deployment before pointing a custom domain at it.


## Installable Web App (PWA)
The site includes a web app manifest, white-background brand icons, and a service worker. Deploy over HTTPS, open the site in Chrome/Edge, then use the install icon in the address bar or browser menu → Install app. On iPhone/iPad, open in Safari → Share → Add to Home Screen. API requests are intentionally not cached.
