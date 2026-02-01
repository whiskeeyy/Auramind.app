-- ============================================================================
-- AuraMind Database Migration 005: Holistic Calendar
-- ============================================================================
-- Purpose: Add health_metrics column to mood_logs for unified mood + health tracking
-- Philosophy: "Calendar là nơi kể lại câu chuyện của người dùng"
-- Mood and health are cause-and-effect of each other.
-- ============================================================================

-- ============================================================================
-- STEP 1: Add health_metrics JSONB column to mood_logs
-- ============================================================================
-- Structure example: {"steps": 5000, "sleep_hours": 7.5, "meditation_min": 15}
-- Nullable by default - users can log mood without health data

ALTER TABLE mood_logs 
ADD COLUMN IF NOT EXISTS health_metrics JSONB DEFAULT NULL;

-- Add comment for documentation
COMMENT ON COLUMN mood_logs.health_metrics IS 'Optional health metrics stored as JSON: {"steps": number, "sleep_hours": number, "meditation_min": number, "water_glasses": number, "exercise_min": number}';

-- ============================================================================
-- STEP 2: Add GIN index for efficient JSONB queries
-- ============================================================================
-- This enables efficient filtering like: WHERE health_metrics @> '{"steps": 10000}'

CREATE INDEX IF NOT EXISTS idx_mood_logs_health_metrics 
ON mood_logs USING GIN (health_metrics) 
WHERE health_metrics IS NOT NULL;

-- ============================================================================
-- STEP 3: Add index for calendar date range queries (if not exists)
-- ============================================================================
-- Optimize queries that filter by user + date range + health data presence

CREATE INDEX IF NOT EXISTS idx_mood_logs_user_date_health 
ON mood_logs (user_id, created_at DESC) 
WHERE health_metrics IS NOT NULL;

-- ============================================================================
-- Migration Complete
-- ============================================================================
-- Next steps:
-- 1. Run this migration in Supabase SQL Editor
-- 2. Verify column exists: SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'mood_logs';
-- 3. Test insert: INSERT INTO mood_logs (..., health_metrics) VALUES (..., '{"steps": 5000}'::jsonb);
-- ============================================================================
