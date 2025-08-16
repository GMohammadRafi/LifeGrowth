-- Life Growth Database Schema
-- This file contains the complete database schema for the Life Growth app

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Create the daily_tasks table
CREATE TABLE IF NOT EXISTS daily_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- Reading Book fields
    reading_book_pages INTEGER CHECK (reading_book_pages >= 0),
    reading_book_time INTEGER CHECK (reading_book_time >= 0), -- minutes
    reading_book_completed BOOLEAN DEFAULT FALSE,
    
    -- Stretch fields
    stretch_type TEXT CHECK (stretch_type IN ('Yoga', 'Home Workout')),
    stretch_minutes INTEGER CHECK (stretch_minutes >= 0),
    stretch_completed BOOLEAN DEFAULT FALSE,
    
    -- Meditation fields
    meditation_minutes INTEGER CHECK (meditation_minutes >= 0),
    meditation_completed BOOLEAN DEFAULT FALSE,
    
    -- Reading Docs fields
    reading_docs_name_link TEXT,
    reading_docs_pages INTEGER CHECK (reading_docs_pages >= 0),
    reading_docs_time INTEGER CHECK (reading_docs_time >= 0), -- minutes
    reading_docs_completed BOOLEAN DEFAULT FALSE,
    
    -- Learning Technology fields
    learning_tech_name TEXT,
    learning_tech_source TEXT,
    learning_tech_url TEXT,
    learning_tech_time INTEGER CHECK (learning_tech_time >= 0), -- minutes
    learning_tech_completed BOOLEAN DEFAULT FALSE,
    
    -- Walking fields
    walking_steps INTEGER CHECK (walking_steps >= 0),
    walking_time INTEGER CHECK (walking_time >= 0), -- minutes
    walking_completed BOOLEAN DEFAULT FALSE,
    
    -- Avoid Habit fields
    avoid_habit_label TEXT DEFAULT 'Avoid X',
    avoid_habit_value BOOLEAN DEFAULT FALSE,
    
    -- Avoid Sweets field
    avoid_sweets_value BOOLEAN DEFAULT FALSE,
    
    -- Work Done field
    work_done_value BOOLEAN DEFAULT FALSE,
    
    -- Movie/Series fields
    movie_series_name TEXT,
    movie_series_start_time TIME,
    movie_series_end_time TIME,
    movie_series_duration INTEGER CHECK (movie_series_duration >= 0), -- minutes
    movie_series_completed BOOLEAN DEFAULT FALSE,
    
    -- General fields
    notes TEXT CHECK (LENGTH(notes) <= 500),
    timezone_offset INTEGER NOT NULL, -- minutes from UTC
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    client_updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    
    -- Schema versioning
    schema_version INTEGER DEFAULT 1
);

-- Create partial unique index to enforce one active row per user per date
CREATE UNIQUE INDEX IF NOT EXISTS daily_tasks_user_date_unique 
ON daily_tasks (user_id, date) 
WHERE deleted_at IS NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS daily_tasks_user_id_idx ON daily_tasks (user_id);
CREATE INDEX IF NOT EXISTS daily_tasks_date_idx ON daily_tasks (date);
CREATE INDEX IF NOT EXISTS daily_tasks_updated_at_idx ON daily_tasks (updated_at);
CREATE INDEX IF NOT EXISTS daily_tasks_deleted_at_idx ON daily_tasks (deleted_at);

-- Function to automatically set user_id from auth context
CREATE OR REPLACE FUNCTION set_user_id_from_auth()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NULL THEN
        NEW.user_id := auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER set_user_id_trigger
    BEFORE INSERT ON daily_tasks
    FOR EACH ROW
    EXECUTE FUNCTION set_user_id_from_auth();

CREATE TRIGGER update_daily_tasks_updated_at
    BEFORE UPDATE ON daily_tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE daily_tasks ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Allow users to select their own data
CREATE POLICY "Users can view their own daily tasks" ON daily_tasks
    FOR SELECT USING (auth.uid() = user_id);

-- Allow users to insert their own data (user_id can be null, will be set by trigger)
CREATE POLICY "Users can insert their own daily tasks" ON daily_tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Allow users to update their own data
CREATE POLICY "Users can update their own daily tasks" ON daily_tasks
    FOR UPDATE USING (auth.uid() = user_id);

-- Allow users to delete their own data
CREATE POLICY "Users can delete their own daily tasks" ON daily_tasks
    FOR DELETE USING (auth.uid() = user_id);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON daily_tasks TO authenticated;
GRANT SELECT ON daily_tasks TO anon;