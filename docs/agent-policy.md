# AI agent policy and approval gates

## Allowed without approval
- Summarize CRM records visible to the owner.
- Research a lead using permitted public sources and save sourced findings.
- Suggest lead score, business category, pipeline stage, and next step.
- Draft messages, proposals, and call scripts without sending them.
- Create internal tasks and reminders.
- Prepare a call brief and log a user-reported human call outcome.

## Approval required
- Sending an email or WhatsApp message.
- Starting an AI voice call.
- Sharing a quotation, discount, contract term, or delivery promise.
- Changing a deal to Won/Lost if it triggers downstream work.
- Exporting or sharing contact data.
- Any action with financial, legal, or external consequences.

## Mandatory channel gate
Before external communication, check that a valid destination exists, the person has not opted out or been marked do-not-contact, required permission evidence exists, the exact message/purpose is shown to the owner, and the owner approves that exact action. Unknown consent is not consent. If eligibility is uncertain, block the action and request manual review. Follow applicable Indian telecom, privacy, and platform rules; obtain qualified compliance advice before enabling automated outreach.

## Voice safety
- Identify the caller as an AI assistant when applicable; never impersonate the owner or a human.
- No deceptive urgency, fabricated claims, or misleading caller identity.
- No unsolicited promotional calls.
- Respect do-not-call/opt-out immediately and stop retries.
- Do not record calls unless relevant notice/permission and applicable law allow it.
- Do not negotiate prices, commit to terms, or accept payments autonomously.

## Reliability
- Use idempotency keys for sends/calls.
- Record provider response IDs, status, timestamps, and failures.
- Retry only transient failures and never retry an opted-out contact.
- Owner can pause agents and revoke queued actions.