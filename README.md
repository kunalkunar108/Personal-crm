# Personal CRM — AI Sales Desk

Private single-owner CRM for managing prospects, sales conversations, follow-ups, and clients across GymOS, website development, CURAKART, and other business lines.

## Configured decisions
- **Autonomy:** Hybrid. AI research, summaries, drafts, and recommendations may run independently; external actions remain approval-gated.
- **Target clients:** All business client types, tagged by business line.
- **Calling:** Both human call logging and future AI voice calling. AI calls remain disabled pending provider setup, channel eligibility, consent checks, and explicit approval.

## Stack
- Next.js 15 App Router + TypeScript
- Supabase Auth with cookie-based SSR sessions
- Supabase Postgres with owner-scoped Row Level Security

## Local setup
1. Install Node.js 22 or newer.
2. Copy .env.example to .env.local.
3. In Supabase Dashboard → Project Settings → API, copy the Project URL and publishable key into .env.local.
4. In Supabase Dashboard → Authentication → Users, create your owner account. Public signup is intentionally not exposed.
5. In Supabase SQL Editor, review and run supabase/migrations/0001_initial_schema.sql against the intended project. This code change does not apply SQL to your project.
6. Run npm install, then npm run dev.
7. Open /login and sign in with the owner account.

## Current features
- Password sign-in and sign-out using Supabase Auth.
- Protected dashboard and cookie session refresh middleware.
- Lead CRUD: create, list, edit, delete; business line, pipeline stage, estimated value, and contact fields.
- Client CRUD: create, list, edit, delete; business line, lifecycle, contract value, and payment status.
- Dashboard counts and pipeline stage totals from Supabase.
- Server-side validation and owner_id assignment; database RLS remains the final access boundary.

## Security and AI boundaries
- No service-role key is used or needed by the browser.
- Signup is not exposed publicly; create the single owner account in Supabase Auth.
- Mutations validate input server-side and derive owner_id from the verified auth user.
- AI agents, external messages, and AI voice calls are not enabled in this phase. Later external actions must check channel eligibility, permission/consent, opt-out status, and explicit approval of the exact action.
- See docs/architecture.md and docs/agent-policy.md.

## Verification
Run npm run typecheck, npm run lint, and npm run build after installing dependencies. This change has not been deployed and does not apply the SQL migration automatically.
