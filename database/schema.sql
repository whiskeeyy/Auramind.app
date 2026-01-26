-- Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION IF NOT EXISTS "pg_jsonschema"; -- Enable if available on the platform

-- Table: users (Profile & Avatar Config)
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  display_name text,
  avatar_config jsonb DEFAULT '{}'::jsonb, -- Stores skin, hair, style, model_url
  daily_reminder time,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add JSONB validation constraint if pg_jsonschema is not available, 
-- we can use a simple check or rely on application logic. 
-- detailed validation often done in app or via trigger.

-- Table: mood_logs (Daily Check-ins)
CREATE TABLE mood_logs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  mood_score int2 CHECK (mood_score >= 1 AND mood_score <= 10),
  stress_level int2 CHECK (stress_level >= 1 AND stress_level <= 10),
  energy_level int2 CHECK (energy_level >= 1 AND energy_level <= 10),
  note text,
  activities text[], -- e.g. ['coding', 'gym']
  ai_feedback text,
  voice_transcript text, -- Captured from voice notes
  created_at timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX idx_mood_logs_user_id ON mood_logs(user_id);
CREATE INDEX idx_mood_logs_created_at ON mood_logs(created_at);
