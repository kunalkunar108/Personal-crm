# Personal CRM architecture

## Product decisions
- Single-owner CRM for one operator, not a multi-tenant SaaS.
- Target market: all business clients. Tag each lead/client as GymOS, website development, CURAKART, or other.
- Hybrid autonomy: AI researches, classifies, summarizes, drafts, and recommends. External communication and consequential changes require approval by default.
- Calling: support human call tracking and an AI voice provider adapter. No provider is activated by default.

## System shape
- Next.js App Router: dashboard and server-side API routes.
- Supabase Auth + Postgres: identity, CRM records, RLS, activity history, and durable agent action queue.
- Vercel AI SDK + AI Gateway: model abstraction for research, drafting, qualification, and next-best-action recommendations.
- Later integrations: permitted lead sources, Zoho Mail, WhatsApp Business Platform, and a compliant voice provider.
- Vercel deployment and scheduled jobs only after idempotency, approvals, and retry handling are implemented.

## Agent roles
1. Lead Researcher: enriches leads from public/permitted sources and records source and confidence.
2. Sales Copilot: prepares personalized email/WhatsApp drafts and call briefs.
3. Follow-up Manager: recommends due dates and creates tasks; cannot contact people itself.
4. Voice Assistant: places calls only after explicit action approval and channel eligibility checks.
5. Client Manager: tracks onboarding, delivery milestones, invoices, and support tasks.

## Action lifecycle
Draft, pending approval, approved, then sent/executed. Rejected or cancelled actions are terminal. Store the exact payload, approval, execution timestamp, and result. Editing a payload invalidates prior approval.

## Data flow
1. A lead is entered manually or imported from an allowed source.
2. AI research produces sourced enrichment with confidence.
3. AI recommends a next action and drafts a message/call brief.
4. A policy gate checks channel preference, opt-out, consent evidence, and user approval.
5. The approved integration executes and writes an activity/call log.
6. Replies and outcomes update the pipeline; owner can override every recommendation.

## Security
- Never expose Supabase service-role credentials or AI Gateway secrets to the browser.
- Enable RLS on every exposed table; policies scope rows to auth.uid().
- Validate AI tool inputs server-side and treat imported content as untrusted.
- Do not let an LLM execute arbitrary SQL, send messages, or place calls directly.
- Store minimal contact data; protect recordings and retention.

## Delivery phases
1. Foundation: UI shell, schema, owner-only RLS, configuration.
2. CRM operations: auth, CRUD, search, pipeline, activity timeline, tasks.
3. AI copilot: chat, lead research, qualification, message drafting, next-action recommendations.
4. Outreach: Zoho/email and WhatsApp adapters with approvals and opt-outs.
5. Voice: human call logging, then AI voice with explicit approval and compliance gates.
6. Automation: scheduled follow-ups, retries, reporting, and audit review.

## Current status
Foundation scaffold is committed on feat/crm-foundation. Migration is prepared but not applied; credentials and provider integrations are not configured.