-- Life Growth Supabase Schema
-- Run this SQL in your Supabase SQL Editor

-- Enable required extensions (if not already enabled)
create extension if not exists pgcrypto;

-- Create table (illustrative: adjust extensions/defaults to your project)
create table if not exists public.daily_tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,

  reading_book_pages integer,
  reading_book_time integer,
  reading_book_completed boolean not null default false,

  stretch_type text,
  stretch_minutes integer,
  stretch_completed boolean not null default false,

  meditation_minutes integer,
  meditation_completed boolean not null default false,

  reading_docs_name_link text,
  reading_docs_pages integer,
  reading_docs_time integer,
  reading_docs_completed boolean not null default false,

  learning_tech_name text,
  learning_tech_source text,
  learning_tech_url text,
  learning_tech_time integer,
  learning_tech_completed boolean not null default false,

  walking_steps integer,
  walking_time integer,
  walking_completed boolean not null default false,

  avoid_habit_label text,
  avoid_habit_value boolean not null default false,

  avoid_sweets_value boolean not null default false,

  work_done_value boolean not null default false,

  movie_series_name text,
  movie_series_start_time time,
  movie_series_end_time time,
  movie_series_duration integer,
  movie_series_completed boolean not null default false,

  notes text,
  timezone_offset integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  client_updated_at timestamptz,
  deleted_at timestamptz,
  schema_version integer not null default 1,

  constraint chk_nonnegative_values check (
    coalesce(reading_book_time,0) >= 0 and
    coalesce(reading_book_pages,0) >= 0 and
    coalesce(stretch_minutes,0) >= 0 and
    coalesce(meditation_minutes,0) >= 0 and
    coalesce(reading_docs_pages,0) >= 0 and
    coalesce(reading_docs_time,0) >= 0 and
    coalesce(learning_tech_time,0) >= 0 and
    coalesce(walking_steps,0) >= 0 and
    coalesce(walking_time,0) >= 0 and
    coalesce(movie_series_duration,0) >= 0
  ),
  constraint chk_stretch_type check (
    stretch_type in ('Yoga','Home Workout') or stretch_type is null
  ),
  constraint chk_notes_length check (
    notes is null or char_length(notes) <= 500
  )
);

-- Soft-delete friendly uniqueness
create unique index if not exists daily_tasks_user_date_unique_active
on public.daily_tasks (user_id, date)
where deleted_at is null;

-- Fast reads for history and sync
create index if not exists daily_tasks_user_date_idx
  on public.daily_tasks (user_id, date desc);
create index if not exists daily_tasks_user_updated_idx
  on public.daily_tasks (user_id, updated_at desc);

-- Server-managed updated_at
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_set_updated_at on public.daily_tasks;
create trigger trg_set_updated_at
before update on public.daily_tasks
for each row execute function public.set_updated_at();

-- Optional: set user_id automatically from auth context on insert
create or replace function public.set_user_id_from_auth()
returns trigger as $$
begin
  if new.user_id is null then
    new.user_id = auth.uid();
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_set_user_id on public.daily_tasks;
create trigger trg_set_user_id
before insert on public.daily_tasks
for each row execute function public.set_user_id_from_auth();

-- RLS
alter table public.daily_tasks enable row level security;

create policy "select_own" on public.daily_tasks
for select using (auth.uid() = user_id);

create policy "insert_own" on public.daily_tasks
for insert with check (auth.uid() = user_id or user_id is null);

create policy "update_own" on public.daily_tasks
for update using (auth.uid() = user_id);

create policy "delete_own" on public.daily_tasks
for delete using (auth.uid() = user_id);