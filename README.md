# SalesPilot AI CRM

A private, single-owner AI sales workspace for discovering prospects, managing leads, preparing outreach, handling conversations and tracking follow-ups across industries.

## Product direction
- One workspace for multiple industries and service lines.
- Lead discovery, CSV import, research, qualification and pipeline management.
- AI sales copilot for prospect research, lead scoring, outreach drafting and conversation assistance.
- Web dashboard plus WhatsApp command center.
- Semi-autonomous execution: AI can research and prepare; first-touch outreach and high-impact actions require owner approval; routine follow-ups run only within explicit permission and opt-out rules.

## Stack
- Next.js 15, React 19, TypeScript and Tailwind CSS
- Supabase PostgreSQL and Auth using `@supabase/ssr`
- OpenAI API for agent orchestration and tool calling
- Meta WhatsApp Business Platform for messaging
- Vercel for hosting

## Current status
- Existing dashboard prototype is being upgraded on branch `feature/crm-foundation`.
- Initial workspace-scoped database schema and RLS policies are in `supabase/schema.sql`.
- Supabase browser/server client helpers are included.
- The live database is not connected yet. Do not reuse either GymOS Supabase project for this CRM; provision a dedicated project.
- Dashboard metrics and existing lead rows are demo data until database integration is complete.

## Setup
1. Create a dedicated Supabase project for SalesPilot AI CRM.
2. Run `supabase/schema.sql` in that project's SQL Editor.
3. Copy `.env.example` to `.env.local` and fill in the project URL and publishable key.
4. Install dependencies with `npm install`.
5. Run `npm run dev`.

## Environment variables
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
- `OPENAI_API_KEY` (server-side only)
- Google Places and WhatsApp credentials are added only when those integrations are implemented.

## Safety
- Keep all provider secrets server-side.
- Never send first-touch outreach or initiate outbound calls without required owner approval and valid channel permissions.
- Store consent evidence and opt-outs separately from lead status.
- Enforce RLS on every exposed table and keep an audit record of AI actions.
- Do not scrape private personal contact data or use unofficial WhatsApp automation.
