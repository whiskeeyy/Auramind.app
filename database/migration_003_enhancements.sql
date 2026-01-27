-- Migration 003: Avatar State Enhancements
-- This migration adds avatar_state to profiles table for fast dashboard loading
-- and handles the new STATE_OVERWHELMED state

-- Add avatar_state to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS avatar_state VARCHAR(50) DEFAULT 'STATE_NEUTRAL';

-- Add index for quick lookups
CREATE INDEX IF NOT EXISTS idx_profiles_avatar_state 
ON profiles(avatar_state);

-- Add comment for documentation
COMMENT ON COLUMN profiles.avatar_state IS 'Current avatar state for quick dashboard loading (STATE_JOYFUL, STATE_NEUTRAL, STATE_SAD, STATE_EXHAUSTED, STATE_ANXIOUS, STATE_OVERWHELMED)';

-- Update existing profiles to have default state
UPDATE profiles 
SET avatar_state = 'STATE_NEUTRAL' 
WHERE avatar_state IS NULL;

-- Optional: Create a function to automatically update profile avatar_state
-- This can be used as a trigger if needed
CREATE OR REPLACE FUNCTION update_profile_avatar_state()
RETURNS TRIGGER AS $$
BEGIN
  -- Update the profile's avatar_state when a new mood log is created
  UPDATE profiles 
  SET avatar_state = NEW.avatar_state
  WHERE user_id = NEW.user_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Optional: Create trigger to auto-update profile (commented out by default)
-- Uncomment if you want automatic profile updates via database trigger
-- DROP TRIGGER IF EXISTS trigger_update_profile_avatar_state ON mood_logs;
-- CREATE TRIGGER trigger_update_profile_avatar_state
--   AFTER INSERT ON mood_logs
--   FOR EACH ROW
--   EXECUTE FUNCTION update_profile_avatar_state();

-- Note: The trigger is optional because we're updating the profile 
-- directly in the application code for better control and error handling
