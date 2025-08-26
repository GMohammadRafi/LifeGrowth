-- Life Growth Supabase Schema V2 - Normalized Structure
-- Run this SQL in your Supabase SQL Editor

-- Enable required extensions
create extension if not exists pgcrypto;

-- Task Types Table - Defines available task categories
create table if not exists public.task_types (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  schema_definition jsonb not null, -- JSON schema for validation
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- User Custom Tasks Table - User-defined task instances
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  task_type_id uuid not null references public.task_types(id) on delete restrict,
  name text not null,
  description text,
  custom_schema jsonb, -- Optional custom fields beyond base type
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Daily Entries Table - One record per user per day
create table if not exists public.daily_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  notes text,
  timezone_offset integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  client_updated_at timestamptz,
  deleted_at timestamptz,
  schema_version integer not null default 2
);

-- Task Entries Table - Individual task completions for each day
create table if not exists public.task_entries (
  id uuid primary key default gen_random_uuid(),
  daily_entry_id uuid not null references public.daily_entries(id) on delete cascade,
  task_id uuid not null references public.tasks(id) on delete restrict,
  data jsonb not null, -- Flexible data storage based on task type
  completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Constraints and Validations
alter table public.task_types add constraint chk_task_types_name_length 
  check (char_length(name) between 1 and 100);

alter table public.tasks add constraint chk_tasks_name_length 
  check (char_length(name) between 1 and 200);

alter table public.daily_entries add constraint chk_notes_length 
  check (notes is null or char_length(notes) <= 500);

-- Unique constraints
create unique index if not exists daily_entries_user_date_unique_active
  on public.daily_entries (user_id, date) where deleted_at is null;

create unique index if not exists tasks_user_name_unique_active
  on public.tasks (user_id, name) where deleted_at is null;

create unique index if not exists task_entries_daily_task_unique_active
  on public.task_entries (daily_entry_id, task_id) where deleted_at is null;

-- Performance indexes
create index if not exists daily_entries_user_date_idx 
  on public.daily_entries (user_id, date desc);
create index if not exists daily_entries_user_updated_idx 
  on public.daily_entries (user_id, updated_at desc);
create index if not exists task_entries_daily_entry_idx 
  on public.task_entries (daily_entry_id);
create index if not exists task_entries_task_idx 
  on public.task_entries (task_id);
create index if not exists tasks_user_type_idx 
  on public.tasks (user_id, task_type_id);

-- Triggers for updated_at
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply triggers to all tables
drop trigger if exists trg_set_updated_at_task_types on public.task_types;
create trigger trg_set_updated_at_task_types
  before update on public.task_types
  for each row execute function public.set_updated_at();

drop trigger if exists trg_set_updated_at_tasks on public.tasks;
create trigger trg_set_updated_at_tasks
  before update on public.tasks
  for each row execute function public.set_updated_at();

drop trigger if exists trg_set_updated_at_daily_entries on public.daily_entries;
create trigger trg_set_updated_at_daily_entries
  before update on public.daily_entries
  for each row execute function public.set_updated_at();

drop trigger if exists trg_set_updated_at_task_entries on public.task_entries;
create trigger trg_set_updated_at_task_entries
  before update on public.task_entries
  for each row execute function public.set_updated_at();

-- Auto-set user_id function
create or replace function public.set_user_id_from_auth()
returns trigger as $$
begin
  if new.user_id is null then
    new.user_id = auth.uid();
  end if;
  return new;
end;
$$ language plpgsql;

-- Apply user_id triggers
drop trigger if exists trg_set_user_id_tasks on public.tasks;
create trigger trg_set_user_id_tasks
  before insert on public.tasks
  for each row execute function public.set_user_id_from_auth();

drop trigger if exists trg_set_user_id_daily_entries on public.daily_entries;
create trigger trg_set_user_id_daily_entries
  before insert on public.daily_entries
  for each row execute function public.set_user_id_from_auth();

-- Row Level Security
alter table public.task_types enable row level security;
alter table public.tasks enable row level security;
alter table public.daily_entries enable row level security;
alter table public.task_entries enable row level security;

-- RLS Policies for task_types (readable by all authenticated users)
create policy "task_types_select_authenticated" on public.task_types
  for select using (auth.role() = 'authenticated');

create policy "task_types_admin_only" on public.task_types
  for all using (auth.jwt() ->> 'role' = 'admin');

-- RLS Policies for tasks
create policy "tasks_select_own" on public.tasks
  for select using (auth.uid() = user_id);

create policy "tasks_insert_own" on public.tasks
  for insert with check (auth.uid() = user_id or user_id is null);

create policy "tasks_update_own" on public.tasks
  for update using (auth.uid() = user_id);

create policy "tasks_delete_own" on public.tasks
  for delete using (auth.uid() = user_id);

-- RLS Policies for daily_entries
create policy "daily_entries_select_own" on public.daily_entries
  for select using (auth.uid() = user_id);

create policy "daily_entries_insert_own" on public.daily_entries
  for insert with check (auth.uid() = user_id or user_id is null);

create policy "daily_entries_update_own" on public.daily_entries
  for update using (auth.uid() = user_id);

create policy "daily_entries_delete_own" on public.daily_entries
  for delete using (auth.uid() = user_id);

-- RLS Policies for task_entries
create policy "task_entries_select_own" on public.task_entries
  for select using (
    exists (
      select 1 from public.daily_entries de 
      where de.id = daily_entry_id and de.user_id = auth.uid()
    )
  );

create policy "task_entries_insert_own" on public.task_entries
  for insert with check (
    exists (
      select 1 from public.daily_entries de 
      where de.id = daily_entry_id and de.user_id = auth.uid()
    )
  );

create policy "task_entries_update_own" on public.task_entries
  for update using (
    exists (
      select 1 from public.daily_entries de 
      where de.id = daily_entry_id and de.user_id = auth.uid()
    )
  );

create policy "task_entries_delete_own" on public.task_entries
  for delete using (
    exists (
      select 1 from public.daily_entries de 
      where de.id = daily_entry_id and de.user_id = auth.uid()
    )
  );

-- Insert default task types
insert into public.task_types (name, description, schema_definition) values
('reading_book', 'Reading Book Activity', '{
  "type": "object",
  "properties": {
    "pages": {"type": "integer", "minimum": 0},
    "time": {"type": "integer", "minimum": 0},
    "book_title": {"type": "string", "maxLength": 200}
  },
  "required": []
}'),
('stretch_exercise', 'Stretch/Exercise Activity', '{
  "type": "object",
  "properties": {
    "type": {"type": "string", "enum": ["Yoga", "Home Workout", "Other"]},
    "minutes": {"type": "integer", "minimum": 0},
    "intensity": {"type": "string", "enum": ["Low", "Medium", "High"]}
  },
  "required": []
}'),
('meditation', 'Meditation Activity', '{
  "type": "object",
  "properties": {
    "minutes": {"type": "integer", "minimum": 0},
    "type": {"type": "string", "maxLength": 100}
  },
  "required": []
}'),
('reading_docs', 'Reading Documentation', '{
  "type": "object",
  "properties": {
    "pages": {"type": "integer", "minimum": 0},
    "time": {"type": "integer", "minimum": 0},
    "name_link": {"type": "string", "maxLength": 500}
  },
  "required": []
}'),
('learning_tech', 'Learning Technology', '{
  "type": "object",
  "properties": {
    "name": {"type": "string", "maxLength": 200},
    "source": {"type": "string", "maxLength": 200},
    "url": {"type": "string", "maxLength": 500},
    "time": {"type": "integer", "minimum": 0}
  },
  "required": []
}'),
('walking', 'Walking Activity', '{
  "type": "object",
  "properties": {
    "steps": {"type": "integer", "minimum": 0},
    "time": {"type": "integer", "minimum": 0},
    "distance": {"type": "number", "minimum": 0}
  },
  "required": []
}'),
('habit', 'General Habit Tracking', '{
  "type": "object",
  "properties": {
    "value": {"type": "boolean"}
  },
  "required": []
}'),
('entertainment', 'Movies/Series/Entertainment', '{
  "type": "object",
  "properties": {
    "name": {"type": "string", "maxLength": 200},
    "start_time": {"type": "string", "format": "time"},
    "end_time": {"type": "string", "format": "time"},
    "duration": {"type": "integer", "minimum": 0},
    "type": {"type": "string", "enum": ["Movie", "Series", "Documentary", "Other"]}
  },
  "required": []
}');