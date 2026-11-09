# Personal CRM — AI Sales Desk

A private, single-owner CRM for managing leads, sales conversations, follow-ups, and clients across all business lines.

## Decisions configured
- **Autonomy:** Hybrid. AI may research, summarize, draft, and recommend; external actions require approval.
- **Target clients:** All business types, tagged by business line (GymOS, website development, CURAKART, other).
- **Calling:** Human call logging plus an AI voice calling integration, disabled until consent and approval controls are configured.

## Stack
- Next.js App Router + TypeScript
- Supabase Auth + Postgres + Row Level Security
- Vercel AI SDK + AI Gateway (AI runtime to be implemented)
- Vercel deployment (after local verification)

## Start locally
1. Install Node.js 20.9+.
2. Copy .env.example to .env.local and fill the Supabase URL and publishable/anon key.
3. Install dependencies with npm install.
4. Start with npm run dev.

The current dashboard is a UI foundation; live data, authentication, and AI actions are not connected yet.

## Database
Review supabase/migrations/0001_initial_schema.sql, then run it in the Supabase SQL Editor for the CRM's initial tables and owner-scoped RLS. Do not run it until you have selected the intended Supabase project and reviewed the SQL. Never put a service-role key in a NEXT_PUBLIC_ variable.

## Architecture and safety
- See docs/architecture.md for system design and delivery phases.
- See docs/agent-policy.md for autonomy, approvals, voice, and outreach restrictions.
- Unknown consent is not consent. AI-generated messages and AI calls must not be sent/placed without the required checks and explicit approval.

## Current status
Foundation branch: feat/crm-foundation. Next: local build verification, Supabase auth/client integration, and lead/client CRUD.
