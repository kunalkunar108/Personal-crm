# Curakart AI CRM

A private, single-user sales workspace for Curakart Technologies.

## Product scope
- One CRM for all Curakart service lines: websites, GymOS, custom software, mobile apps and digital solutions.
- Lead capture, qualification, pipeline, activity history and follow-up management.
- AI sales copilot for prospect research, lead scoring, outreach drafting and call summaries.
- Integrations for telephony, WhatsApp Business and email will be added behind explicit user approval.

## Current status
Phase 1 UI prototype. Dashboard metrics and sample lead rows are illustrative. The add-lead form and lead search use temporary browser state; no production database, AI API, lead discovery, or outbound calling is connected yet.

## Stack
Next.js, TypeScript, Tailwind CSS, Supabase, OpenAI SDK.

## Local development
```bash
npm install
npm run dev
```

## Required environment variables (later phases)
- NEXT_PUBLIC_SUPABASE_URL
- NEXT_PUBLIC_SUPABASE_ANON_KEY
- OPENAI_API_KEY (server-side only; never expose to browser code)

## Safety
Outbound calls and messages must be initiated only through compliant providers, with lawful basis/consent, opt-out handling, and human approval controls. Do not collect private personal contact data without authorization.
