-- ============================================================================
-- AuraMind Database Migration 001: Supabase Auth Integration
-- ============================================================================
-- Purpose: Integrate with Supabase Auth and enable multi-user support
-- - Create profiles table linked to auth.users
-- - Update mood_logs to reference profiles
-- - Enable Row Level Security (RLS) for data isolation
-- - Auto-create profile on user registration
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- STEP 1: Drop existing tables (if migrating from old schema)
-- ============================================================================
DROP TABLE IF EXISTS mood_logs CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================================
-- STEP 2: Create profiles table (linked to auth.users)
-- ============================================================================
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  avatar_config jsonb DEFAULT '{}'::jsonb 
    CHECK (jsonb_typeof(avatar_config) = 'object'), -- Ensures avatar_config is always a JSON object
  daily_reminder time,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add comment for documentation
COMMENT ON TABLE profiles IS 'User profiles linked to Supabase Auth users';
COMMENT ON COLUMN profiles.avatar_config IS 'JSON configuration for personalized avatar (skin tone, hair style, accessories, etc.). Must be a valid JSON object.';

-- ============================================================================
-- STEP 3: Create mood_logs table
-- ============================================================================
CREATE TABLE mood_logs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  mood_score int2 CHECK (mood_score >= 1 AND mood_score <= 10) NOT NULL,
  stress_level int2 CHECK (stress_level >= 1 AND stress_level <= 10) NOT NULL,
  energy_level int2 CHECK (energy_level >= 1 AND energy_level <= 10) NOT NULL,
  note text,
  activities text[] DEFAULT '{}', -- e.g. ['coding', 'gym', 'meditation']
  ai_feedback text,
  voice_transcript text, -- Captured from voice notes
  created_at timestamptz DEFAULT now()
);

-- Add comments
COMMENT ON TABLE mood_logs IS 'Daily mood check-ins and emotional tracking data';
COMMENT ON COLUMN mood_logs.ai_feedback IS 'AI-generated empathetic feedback and insights';

-- ============================================================================
-- STEP 4: Create indexes for performance
-- ============================================================================
CREATE INDEX idx_mood_logs_user_id ON mood_logs(user_id);
CREATE INDEX idx_mood_logs_created_at ON mood_logs(created_at DESC);
CREATE INDEX idx_mood_logs_user_created ON mood_logs(user_id, created_at DESC);

-- ============================================================================
-- STEP 5: Enable Row Level Security (RLS)
-- ============================================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE mood_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 6: Create RLS Policies for profiles table
-- ============================================================================

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy: Profiles are created via trigger only (no direct INSERT by users)
-- The trigger runs with SECURITY DEFINER, bypassing RLS
CREATE POLICY "Profiles created via trigger only"
  ON profiles
  FOR INSERT
  WITH CHECK (false); -- Block all direct inserts

-- ============================================================================
-- STEP 7: Create RLS Policies for mood_logs table
-- ============================================================================

-- Policy: Users can view their own mood logs
CREATE POLICY "Users can view own mood logs"
  ON mood_logs
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own mood logs
CREATE POLICY "Users can insert own mood logs"
  ON mood_logs
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own mood logs
CREATE POLICY "Users can update own mood logs"
  ON mood_logs
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own mood logs
CREATE POLICY "Users can delete own mood logs"
  ON mood_logs
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- STEP 8: Create function to auto-create profile on user signup
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER -- Run with elevated privileges to bypass RLS
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$;

-- Add comment
COMMENT ON FUNCTION public.handle_new_user() IS 'Automatically creates a profile when a new user signs up via Supabase Auth';

-- ============================================================================
-- STEP 9: Create trigger on auth.users
-- ============================================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- STEP 10: Grant necessary permissions
-- ============================================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant permissions on profiles table
GRANT SELECT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon; -- For public profile viewing (optional)

-- Grant permissions on mood_logs table
GRANT SELECT, INSERT, UPDATE, DELETE ON public.mood_logs TO authenticated;

-- ============================================================================
-- Migration Complete
-- ============================================================================
-- Next steps:
-- 1. Verify tables exist in Supabase Table Editor
-- 2. Check RLS is enabled (should show green shield icon)
-- 3. Verify trigger exists in Database > Triggers
-- 4. Test by creating a new user via Supabase Auth
-- 5. Confirm profile is auto-created in profiles table
-- ============================================================================
