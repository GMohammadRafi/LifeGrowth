-- Migration from V1 daily_tasks to V2 normalized schema
-- Run this after applying schema_v2.sql

-- Step 1: Create user tasks from existing v1 data
INSERT INTO public.tasks (user_id, task_type_id, name, description)
SELECT DISTINCT 
  dt.user_id,
  tt.id as task_type_id,
  CASE tt.name
    WHEN 'reading_book' THEN 'Reading Book'
    WHEN 'stretch_exercise' THEN 'Stretch/Exercise'
    WHEN 'meditation' THEN 'Meditation'
    WHEN 'reading_docs' THEN 'Reading Documentation'
    WHEN 'learning_tech' THEN 'Learning Technology'
    WHEN 'walking' THEN 'Walking'
    WHEN 'habit' THEN COALESCE(dt.avoid_habit_label, 'Avoid Habit')
    WHEN 'entertainment' THEN 'Movies/Series'
  END as name,
  'Migrated from v1' as description
FROM public.daily_tasks dt
CROSS JOIN public.task_types tt
WHERE dt.deleted_at IS NULL
  AND tt.name IN ('reading_book', 'stretch_exercise', 'meditation', 'reading_docs', 'learning_tech', 'walking', 'habit', 'entertainment')
ON CONFLICT (user_id, name) WHERE deleted_at IS NULL DO NOTHING;

-- Step 2: Create daily entries from v1 data
INSERT INTO public.daily_entries (user_id, date, notes, timezone_offset, created_at, updated_at, client_updated_at, schema_version)
SELECT 
  user_id,
  date,
  notes,
  timezone_offset,
  created_at,
  updated_at,
  client_updated_at,
  2 as schema_version
FROM public.daily_tasks
WHERE deleted_at IS NULL
ON CONFLICT (user_id, date) WHERE deleted_at IS NULL DO NOTHING;

-- Step 3: Migrate task entries
-- Reading Book entries
INSERT INTO public.task_entries (daily_entry_id, task_id, data, completed)
SELECT 
  de.id as daily_entry_id,
  t.id as task_id,
  jsonb_build_object(
    'pages', dt.reading_book_pages,
    'time', dt.reading_book_time
  ) as data,
  dt.reading_book_completed
FROM public.daily_tasks dt
JOIN public.daily_entries de ON de.user_id = dt.user_id AND de.date = dt.date
JOIN public.tasks t ON t.user_id = dt.user_id AND t.name = 'Reading Book'
WHERE dt.deleted_at IS NULL
  AND (dt.reading_book_pages IS NOT NULL OR dt.reading_book_time IS NOT NULL OR dt.reading_book_completed = true)
ON CONFLICT (daily_entry_id, task_id) WHERE deleted_at IS NULL DO NOTHING;

-- Stretch/Exercise entries
INSERT INTO public.task_entries (daily_entry_id, task_id, data, completed)
SELECT 
  de.id as daily_entry_id,
  t.id as task_id,
  jsonb_build_object(
    'type', dt.stretch_type,
    'minutes', dt.stretch_minutes,
    'intensity', 'Medium'
  ) as data,
  dt.stretch_completed
FROM public.daily_tasks dt
JOIN public.daily_entries de ON de.user_id = dt.user_id AND de.date = dt.date
JOIN public.tasks t ON t.user_id = dt.user_id AND t.name = 'Stretch/Exercise'
WHERE dt.deleted_at IS NULL
  AND (dt.stretch_type IS NOT NULL OR dt.stretch_minutes IS NOT NULL OR dt.stretch_completed = true)
ON CONFLICT (daily_entry_id, task_id) WHERE deleted_at IS NULL DO NOTHING;

-- Meditation entries
INSERT INTO public.task_entries (daily_entry_id, task_id, data, completed)
SELECT 
  de.id as daily_entry_id,
  t.id as task_id,
  jsonb_build_object(
    'minutes', dt.meditation_minutes,
    'type', 'General'
  ) as data,
  dt.meditation_completed
FROM public.daily_tasks dt
JOIN public.daily_entries de ON de.user_id = dt.user_id AND de.date = dt.date
JOIN public.tasks t ON t.user_id = dt.user_id AND t.name = 'Meditation'
WHERE dt.deleted_at IS NULL
  AND (dt.meditation_minutes IS NOT NULL OR dt.meditation_completed = true)
ON CONFLICT (daily_entry_id, task_id) WHERE deleted_at IS NULL DO NOTHING;

-- Reading Documentation entries
INSERT INTO public.task_entries (daily_entry_id, task_id, data, completed)
SELECT 
  de.id as daily_entry_id,
  t.id as task_id,
  jsonb_build_object(
    'pages', dt.reading_docs_pages,
    'time', dt.reading_docs_time,
    'name_link', dt.reading_docs_name_link
  ) as data,
  dt.reading_docs_completed
FROM public.daily_tasks dt
JOIN public.daily_entries de ON de.user_id = dt.user_id AND de.date = dt.date
JOIN public.tasks t ON t.user_id = dt.user_id AND t.name = 'Reading Documentation'
WHERE dt.deleted_at IS NULL
  AND (dt.reading_docs_pages IS NOT NULL OR dt.reading_docs_time IS NOT NULL OR dt.reading_docs_name_link IS NOT NULL OR dt.reading_docs_completed = true)
ON CONFLICT (daily_entry_id, task_id) WHERE deleted_at IS NULL DO NOTHING;

-- Learning Technology entries
INSERT INTO public.task_entries (daily_entry_id, task_id, data, completed)
SELECT 
  de.id as daily_entry_id,
  t.id as task_id,
  jsonb_build_object(
    'name', dt.learning_tech_name,
    'source', dt.learning_tech_source,
    'url', dt.learning_tech_url,
    'time', dt.learning_tech_time
  ) as data,
  dt.learning_tech_completed
FROM public.daily_tasks dt
JOIN public.daily_entries de ON de.user_id = dt.user_id AND de.date = dt.date
JOIN public.tasks t ON t.user_id = dt.user_id AND t.name = 'Learning Technology'
WHERE dt.deleted_at IS NULL
  AND (dt.learning_tech_name IS NOT NULL OR dt.learning_tech_source IS NOT NULL OR dt.learning_tech_url IS NOT NULL OR dt.learning_tech_time IS NOT NULL OR dt.learning_tech_completed = true)
ON CONFLICT (daily_entry_id, task_id) WHERE deleted_at IS NULL DO NOTHING;

-- Walking entries
INSERT INTO public.task_entries (daily_entry_id, task_id, data, completed)
SELECT 
  de.id as daily_entry_id,
  t.id as task_id,
  jsonb_build_object(
    'steps', dt.walking_steps,
    'time', dt.walking_time,
    'distance', 0
  ) as data,
  dt.walking_completed
FROM public.daily_tasks dt
JOIN public.daily_entries de ON de.user_id = dt.user_id AND de.date = dt.date
JOIN public.tasks t ON t.user_id = dt.user_id AND t.name = 'Walking'
WHERE dt.deleted_at IS NULL
  AND (dt.walking_steps IS NOT NULL OR dt.walking_time IS NOT NULL OR dt.walking_completed = true)
ON CONFLICT (daily_entry_id, task_id) WHERE deleted_at IS NULL DO NOTHING;

-- Habit entries (avoid habit)
INSERT INTO public.task_entries (daily_entry_id, task_id, data, completed)
SELECT 
  de.id as daily_entry_id,
  t.id as task_id,
  jsonb_build_object(
    'label', COALESCE(dt.avoid_habit_label, 'Avoid Habit'),
    'notes', ''
  ) as data,
  dt.avoid_habit_value
FROM public.daily_tasks dt
JOIN public.daily_entries de ON de.user_id = dt.user_id AND de.date = dt.date
JOIN public.tasks t ON t.user_id = dt.user_id AND t.name LIKE '%Avoid%'
WHERE dt.deleted_at IS NULL
  AND (dt.avoid_habit_label IS NOT NULL OR dt.avoid_habit_value = true)
ON CONFLICT (daily_entry_id, task_id) WHERE deleted_at IS NULL DO NOTHING;

-- Entertainment entries
INSERT INTO public.task_entries (daily_entry_id, task_id, data, completed)
SELECT 
  de.id as daily_entry_id,
  t.id as task_id,
  jsonb_build_object(
    'name', dt.movie_series_name,
    'start_time', dt.movie_series_start_time,
    'end_time', dt.movie_series_end_time,
    'duration', dt.movie_series_duration,
    'type', 'Other'
  ) as data,
  dt.movie_series_completed
FROM public.daily_tasks dt
JOIN public.daily_entries de ON de.user_id = dt.user_id AND de.date = dt.date
JOIN public.tasks t ON t.user_id = dt.user_id AND t.name = 'Movies/Series'
WHERE dt.deleted_at IS NULL
  AND (dt.movie_series_name IS NOT NULL OR dt.movie_series_duration IS NOT NULL OR dt.movie_series_completed = true)
ON CONFLICT (daily_entry_id, task_id) WHERE deleted_at IS NULL DO NOTHING;

-- Optional: Backup v1 table (rename instead of drop)
-- ALTER TABLE public.daily_tasks RENAME TO daily_tasks_v1_backup;