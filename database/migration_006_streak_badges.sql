-- Migration 006: Streak and Badge System

-- 1. Update profiles table with streak tracking columns
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS current_streak INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS longest_streak INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_log_date DATE DEFAULT NULL;

-- 2. Create user_achievements table
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    badge_code TEXT NOT NULL, -- e.g., 'STREAK_3', 'EARLY_BIRD'
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}', -- Store extra info if needed (e.g., specific streak count)
    UNIQUE(user_id, badge_code) -- Prevent duplicate badges for same user
);

-- Enable RLS
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- RLS: Users can view their own achievements
CREATE POLICY "Users can view own achievements" ON user_achievements
    FOR SELECT USING (auth.uid() = user_id);

-- 3. Trigger Function to update streaks automatically
CREATE OR REPLACE FUNCTION update_user_streak()
RETURNS TRIGGER AS $$
DECLARE
    log_date DATE;
    last_date DATE;
    current_s INT;
    longest_s INT;
BEGIN
    -- Get the date of the new log (using server time logic or based on input)
    -- We assume created_at is TIMESTAMPTZ. Casting to DATE gives UTC date by default.
    -- For more precise local timezone handling, we might need user's timezone, 
    -- but for MVP we use basic date comparison.
    log_date := NEW.created_at::DATE;
    
    -- Get current user profile data
    SELECT last_log_date, current_streak, longest_streak 
    INTO last_date, current_s, longest_s
    FROM profiles 
    WHERE id = NEW.user_id;
    
    -- Initialize if null
    IF current_s IS NULL THEN current_s := 0; END IF;
    IF longest_s IS NULL THEN longest_s := 0; END IF;

    -- If this is the first log ever
    IF last_date IS NULL THEN
        current_s := 1;
        longest_s := GREATEST(longest_s, 1);
        last_date := log_date;
        
    -- If log is on the same day as last log -> Do nothing to streak
    ELSIF log_date = last_date THEN
        -- No change needed
        RETURN NEW;
        
    -- If log is exactly the next day -> Increment streak
    ELSIF log_date = (last_date + INTERVAL '1 day')::DATE THEN
        current_s := current_s + 1;
        longest_s := GREATEST(longest_s, current_s);
        last_date := log_date;
        
    -- If log is after a gap -> Reset streak to 1
    ELSIF log_date > last_date THEN
        current_s := 1;
        -- longest_s keeps its value
        last_date := log_date;
    END IF;
    -- If log_date < last_date (backfilling), we ignore streak updates for simplicity in MVP
    
    -- Update the profile
    UPDATE profiles 
    SET 
        current_streak = current_s,
        longest_streak = longest_s,
        last_log_date = last_date
    WHERE id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Attach Trigger to mood_logs
DROP TRIGGER IF EXISTS on_mood_log_added_streak ON mood_logs;

CREATE TRIGGER on_mood_log_added_streak
    AFTER INSERT ON mood_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_user_streak();
