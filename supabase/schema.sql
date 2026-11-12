-- SalesPilot AI CRM — initial single-owner workspace schema.
-- Run only in the dedicated CRM Supabase project, never in GymOS databases.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workspaces (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'My Sales Workspace',
  default_currency text not null default 'INR',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, name)
);

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  name text not null,
  category text,
  description text,
  price_min numeric(12,2),
  price_max numeric(12,2),
  currency text not null default 'INR',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (price_min is null or price_min >= 0),
  check (price_max is null or price_max >= 0),
  check (price_min is null or price_max is null or price_max >= price_min)
);

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  business_name text not null,
  industry text,
  website text,
  location text,
  source text not null default 'manual',
  source_url text,
  status text not null default 'new'
    check (status in ('new','researched','qualified','contacted','interested','meeting','negotiation','won','lost','do_not_contact')),
  notes text,
  estimated_value numeric(12,2),
  currency text not null default 'INR',
  assigned_service_id uuid references public.services(id) on delete set null,
  next_action_at timestamptz,
  last_contacted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists leads_workspace_status_idx on public.leads(workspace_id, status);
create index if not exists leads_workspace_created_idx on public.leads(workspace_id, created_at desc);
create index if not exists leads_business_name_search_idx on public.leads using gin (to_tsvector('simple', business_name));

create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  full_name text,
  job_title text,
  phone text,
  email text,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists contacts_lead_idx on public.contacts(lead_id);
create index if not exists contacts_phone_idx on public.contacts(workspace_id, phone);

create table if not exists public.lead_scores (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  score integer not null check (score between 0 and 100),
  confidence numeric(4,3) check (confidence between 0 and 1),
  factors jsonb not null default '{}'::jsonb,
  reasoning text,
  buying_intent text,
  scored_at timestamptz not null default now()
);

create index if not exists lead_scores_latest_idx on public.lead_scores(lead_id, scored_at desc);

create table if not exists public.lead_activities (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  activity_type text not null,
  description text,
  metadata jsonb not null default '{}'::jsonb,
  actor_type text not null default 'user' check (actor_type in ('user','ai','system')),
  created_at timestamptz not null default now()
);

create index if not exists lead_activities_timeline_idx on public.lead_activities(lead_id, created_at desc);

create table if not exists public.communication_permissions (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  contact_id uuid not null references public.contacts(id) on delete cascade,
  channel text not null check (channel in ('whatsapp','email','phone','sms')),
  purpose text not null default 'marketing',
  permission_status text not null default 'unknown'
    check (permission_status in ('unknown','opted_in','opted_out','restricted')),
  consent_basis text,
  evidence text,
  consented_at timestamptz,
  opted_out_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (contact_id, channel, purpose)
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  contact_id uuid references public.contacts(id) on delete set null,
  channel text not null check (channel in ('whatsapp','email','phone','web')),
  status text not null default 'open' check (status in ('open','waiting','closed','human_takeover')),
  provider_thread_id text,
  last_message_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  direction text not null check (direction in ('inbound','outbound')),
  content text not null,
  content_type text not null default 'text',
  delivery_status text not null default 'logged'
    check (delivery_status in ('draft','pending_approval','queued','sent','delivered','read','failed','received','logged')),
  provider_message_id text,
  sent_by text not null default 'user' check (sent_by in ('user','ai','system')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create unique index if not exists messages_provider_id_unique
  on public.messages(provider_message_id) where provider_message_id is not null;

create table if not exists public.deals (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  service_id uuid references public.services(id) on delete set null,
  title text not null,
  stage text not null default 'qualification'
    check (stage in ('qualification','discovery','proposal','negotiation','won','lost')),
  amount numeric(12,2),
  currency text not null default 'INR',
  expected_close_date date,
  closed_at timestamptz,
  lost_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.followups (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete set null,
  title text not null,
  instructions text,
  due_at timestamptz not null,
  status text not null default 'scheduled'
    check (status in ('scheduled','due','completed','cancelled','suppressed','failed')),
  automation_allowed boolean not null default false,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists followups_due_idx on public.followups(workspace_id, due_at) where status = 'scheduled';

create table if not exists public.meetings (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  title text not null,
  starts_at timestamptz not null,
  ends_at timestamptz,
  meeting_url text,
  status text not null default 'scheduled' check (status in ('scheduled','completed','cancelled','no_show')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.call_logs (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  contact_id uuid references public.contacts(id) on delete set null,
  provider text,
  provider_call_id text,
  direction text not null check (direction in ('inbound','outbound')),
  status text not null default 'queued',
  duration_seconds integer,
  transcript text,
  summary text,
  recording_reference text,
  created_at timestamptz not null default now(),
  unique (provider, provider_call_id)
);

create table if not exists public.ai_tasks (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  agent_name text not null,
  task_type text not null,
  status text not null default 'queued' check (status in ('queued','running','completed','failed','cancelled')),
  input jsonb not null default '{}'::jsonb,
  output jsonb,
  error_message text,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.approvals (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  requested_by text not null default 'ai',
  action_type text not null,
  action_payload jsonb not null,
  payload_hash text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected','expired','executed','failed')),
  expires_at timestamptz not null,
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  execution_result jsonb,
  created_at timestamptz not null default now()
);

create index if not exists approvals_pending_idx on public.approvals(workspace_id, expires_at) where status = 'pending';

create table if not exists public.knowledge_documents (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  title text not null,
  document_type text not null default 'sales_knowledge',
  content text not null,
  metadata jsonb not null default '{}'::jsonb,
  version integer not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  actor_type text not null check (actor_type in ('user','ai','system','provider')),
  actor_id text,
  action text not null,
  entity_type text,
  entity_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.webhook_events (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  provider_event_id text not null,
  event_type text,
  payload jsonb not null,
  processing_status text not null default 'received'
    check (processing_status in ('received','processing','processed','failed','ignored')),
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  unique (provider, provider_event_id)
);

-- Updated-at maintenance.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles','workspaces','services','leads','contacts',
    'communication_permissions','conversations','deals','followups',
    'meetings','knowledge_documents'
  ]
  loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()', t);
  end loop;
end $$;

-- RLS on every public table.
alter table public.profiles enable row level security;
alter table public.workspaces enable row level security;
alter table public.services enable row level security;
alter table public.leads enable row level security;
alter table public.contacts enable row level security;
alter table public.lead_scores enable row level security;
alter table public.lead_activities enable row level security;
alter table public.communication_permissions enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.deals enable row level security;
alter table public.followups enable row level security;
alter table public.meetings enable row level security;
alter table public.call_logs enable row level security;
alter table public.ai_tasks enable row level security;
alter table public.approvals enable row level security;
alter table public.knowledge_documents enable row level security;
alter table public.audit_logs enable row level security;
alter table public.webhook_events enable row level security;

create policy "profile_owner_select" on public.profiles for select to authenticated using (id = (select auth.uid()));
create policy "profile_owner_insert" on public.profiles for insert to authenticated with check (id = (select auth.uid()));
create policy "profile_owner_update" on public.profiles for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "workspace_owner_all" on public.workspaces for all to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

-- Workspace-scoped access policies. Each policy verifies ownership through workspaces.
create policy "services_workspace_all" on public.services for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "leads_workspace_all" on public.leads for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "contacts_workspace_all" on public.contacts for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "lead_scores_workspace_all" on public.lead_scores for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "lead_activities_workspace_all" on public.lead_activities for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "communication_permissions_workspace_all" on public.communication_permissions for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "conversations_workspace_all" on public.conversations for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "messages_workspace_all" on public.messages for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "deals_workspace_all" on public.deals for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "followups_workspace_all" on public.followups for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "meetings_workspace_all" on public.meetings for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "call_logs_workspace_all" on public.call_logs for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "ai_tasks_workspace_all" on public.ai_tasks for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "approvals_workspace_all" on public.approvals for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "knowledge_documents_workspace_all" on public.knowledge_documents for all to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "audit_logs_workspace_select" on public.audit_logs for select to authenticated
  using (exists (select 1 from public.workspaces w where w.id = workspace_id and w.owner_id = (select auth.uid())));
create policy "webhook_events_deny_client_access" on public.webhook_events for all to authenticated using (false) with check (false);

-- Public API roles can only access records through authenticated RLS policies.
grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
