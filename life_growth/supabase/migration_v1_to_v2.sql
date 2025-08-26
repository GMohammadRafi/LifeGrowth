-- Migration Script: daily_tasks (v1) to normalized structure (v2)
-- This script preserves all existing data while migrating to the new structure

-- Step 1: Create a backup of the original table
create table if not exists public.daily_tasks_backup as 
select * from public.daily_tasks;

-- Step 2: Migration function to transform old data to new structure
create or replace function migrate_daily_tasks_to_v2()
returns void as $$
declare
  old_record record;
  daily_entry_id uuid;
  task_type_id_var uuid;
  user_task_id uuid;
begin
  -- Process each old daily_tasks record
  for old_record in select * from public.daily_tasks where deleted_at is null loop
    
    -- Create daily_entry for this date/user
    insert into public.daily_entries (
      user_id, date, notes, timezone_offset, 
      created_at, updated_at, client_updated_at, schema_version
    ) values (
      old_record.user_id, old_record.date, old_record.notes, old_record.timezone_offset,
      old_record.created_at, old_record.updated_at, old_record.client_updated_at, 2
    ) returning id into daily_entry_id;
    
    -- Migrate Reading Book data
    if old_record.reading_book_pages is not null or old_record.reading_book_time is not null or old_record.reading_book_completed then
      -- Get or create user task for reading_book
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'reading_book' and t.name = 'Reading Book';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'reading_book';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Reading Book', 'Daily book reading')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id, 
        json_build_object(
          'pages', old_record.reading_book_pages,
          'time', old_record.reading_book_time
        )::jsonb,
        old_record.reading_book_completed
      );
    end if;
    
    -- Migrate Stretch/Exercise data
    if old_record.stretch_type is not null or old_record.stretch_minutes is not null or old_record.stretch_completed then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'stretch_exercise' and t.name = 'Stretch/Exercise';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'stretch_exercise';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Stretch/Exercise', 'Daily stretching and exercise')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'type', old_record.stretch_type,
          'minutes', old_record.stretch_minutes
        )::jsonb,
        old_record.stretch_completed
      );
    end if;
    
    -- Migrate Meditation data
    if old_record.meditation_minutes is not null or old_record.meditation_completed then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'meditation' and t.name = 'Meditation';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'meditation';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Meditation', 'Daily meditation practice')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'minutes', old_record.meditation_minutes
        )::jsonb,
        old_record.meditation_completed
      );
    end if;
    
    -- Migrate Reading Docs data
    if old_record.reading_docs_name_link is not null or old_record.reading_docs_pages is not null or 
       old_record.reading_docs_time is not null or old_record.reading_docs_completed then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'reading_docs' and t.name = 'Reading Documentation';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'reading_docs';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Reading Documentation', 'Daily documentation reading')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'name_link', old_record.reading_docs_name_link,
          'pages', old_record.reading_docs_pages,
          'time', old_record.reading_docs_time
        )::jsonb,
        old_record.reading_docs_completed
      );
    end if;
    
    -- Migrate Learning Tech data
    if old_record.learning_tech_name is not null or old_record.learning_tech_source is not null or 
       old_record.learning_tech_url is not null or old_record.learning_tech_time is not null or 
       old_record.learning_tech_completed then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'learning_tech' and t.name = 'Learning Technology';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'learning_tech';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Learning Technology', 'Daily technology learning')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'name', old_record.learning_tech_name,
          'source', old_record.learning_tech_source,
          'url', old_record.learning_tech_url,
          'time', old_record.learning_tech_time
        )::jsonb,
        old_record.learning_tech_completed
      );
    end if;
    
    -- Migrate Walking data
    if old_record.walking_steps is not null or old_record.walking_time is not null or old_record.walking_completed then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'walking' and t.name = 'Walking';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'walking';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Walking', 'Daily walking activity')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'steps', old_record.walking_steps,
          'time', old_record.walking_time
        )::jsonb,
        old_record.walking_completed
      );
    end if;
    
    -- Migrate Avoid Habit data
    if old_record.avoid_habit_label is not null or old_record.avoid_habit_value is not null then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'habit' and t.name = 'Avoid Habit';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'habit';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Avoid Habit', 'Habit avoidance tracking')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'label', old_record.avoid_habit_label,
          'value', old_record.avoid_habit_value
        )::jsonb,
        old_record.avoid_habit_value
      );
    end if;
    
    -- Migrate Avoid Sweets data
    if old_record.avoid_sweets_value is not null then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'habit' and t.name = 'Avoid Sweets';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'habit';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Avoid Sweets', 'Sweet avoidance tracking')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'label', 'Avoid Sweets',
          'value', old_record.avoid_sweets_value
        )::jsonb,
        old_record.avoid_sweets_value
      );
    end if;
    
    -- Migrate Work Done data
    if old_record.work_done_value is not null then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'habit' and t.name = 'Work Done';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'habit';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Work Done', 'Work completion tracking')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'label', 'Work Done',
          'value', old_record.work_done_value
        )::jsonb,
        old_record.work_done_value
      );
    end if;
    
    -- Migrate Movie/Series data
    if old_record.movie_series_name is not null or old_record.movie_series_start_time is not null or 
       old_record.movie_series_end_time is not null or old_record.movie_series_duration is not null or 
       old_record.movie_series_completed then
      select t.id into user_task_id from public.tasks t
      join public.task_types tt on t.task_type_id = tt.id
      where t.user_id = old_record.user_id and tt.name = 'entertainment' and t.name = 'Movies/Series';
      
      if user_task_id is null then
        select id into task_type_id_var from public.task_types where name = 'entertainment';
        insert into public.tasks (user_id, task_type_id, name, description)
        values (old_record.user_id, task_type_id_var, 'Movies/Series', 'Entertainment tracking')
        returning id into user_task_id;
      end if;
      
      insert into public.task_entries (daily_entry_id, task_id, data, completed)
      values (daily_entry_id, user_task_id,
        json_build_object(
          'name', old_record.movie_series_name,
          'start_time', old_record.movie_series_start_time::text,
          'end_time', old_record.movie_series_end_time::text,
          'duration', old_record.movie_series_duration,
          'type', 'Series'
        )::jsonb,
        old_record.movie_series_completed
      );
    end if;
    
  end loop;
  
  raise notice 'Migration completed successfully!';
end;
$$ language plpgsql;

-- Step 3: Execute the migration
select migrate_daily_tasks_to_v2();

-- Step 4: Verification queries (run these to verify migration success)
-- Check daily_entries count
-- select count(*) as daily_entries_count from public.daily_entries;

-- Check task_entries count
-- select count(*) as task_entries_count from public.task_entries;

-- Check tasks created per user
-- select user_id, count(*) as tasks_count from public.tasks group by user_id;

-- Sample data verification
-- select de.date, de.user_id, t.name as task_name, te.data, te.completed
-- from public.daily_entries de
-- join public.task_entries te on de.id = te.daily_entry_id
-- join public.tasks t on te.task_id = t.id
-- order by de.date desc, t.name
-- limit 20;

-- Step 5: Clean up (ONLY run after verifying migration success)
-- drop function migrate_daily_tasks_to_v2();
-- drop table public.daily_tasks_backup; -- Keep this as backup
-- drop table public.daily_tasks; -- Only after thorough verification