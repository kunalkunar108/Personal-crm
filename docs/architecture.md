# Personal CRM architecture

## Current implementation
- Next.js 15 App Router dashboard and server actions.
- Supabase Auth with cookie-backed SSR sessions refreshed in middleware.
- Server-rendered lead and client lists with validated server-side CRUD.
- Supabase Postgres with owner-scoped RLS; server actions derive owner_id from the verified auth user.

## Product decisions
- Single-owner private workspace, not a multi-tenant SaaS.
- All business clients, tagged GymOS, website development, CURAKART, or other.
- Hybrid autonomy: AI may research, classify, summarize, draft, and recommend. External communication and consequential changes require explicit approval.
- Human call tracking and an AI voice adapter are planned. No provider is activated by default.

## Future agent roles
1. Lead Researcher: enriches prospects from permitted public sources and records source and confidence.
2. Sales Copilot: prepares personalized messages and call briefs.
3. Follow-up Manager: recommends due dates and creates tasks; cannot contact people itself.
4. Voice Assistant: places calls only after explicit action approval and channel eligibility checks.
5. Client Manager: tracks onboarding, delivery milestones, invoices, and support tasks.

## Security
- Never expose service-role or secret keys to the browser.
- Verify user identity server-side; do not authorize from user-editable metadata.
- Every exposed table must have RLS and owner-scoped policies.
- Server actions validate inputs and derive owner_id from auth.getUser(), never from submitted form values.
- LLMs must not execute arbitrary SQL or directly trigger sends/calls.

## Next phases
1. Tasks, activity timeline, search, and lead-to-client conversion.
2. AI copilot for lead research, qualification, drafting, and next-best-action recommendations.
3. Zoho/email and WhatsApp integrations with approval and opt-out gates.
4. Human call logging, then AI voice with explicit approval and consent checks.
5. Scheduled follow-ups, idempotent retries, reporting, and audit review.
