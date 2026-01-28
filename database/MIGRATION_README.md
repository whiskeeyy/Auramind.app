# Database Migration Instructions

## Migration 001: Supabase Auth Integration & Base Custom Schema

This migration establishes the core database structure, integrating with Supabase Auth (`auth.users`) and creating the foundational tables.

### Features
- **Profiles Table**: Linked to `auth.users`, stores user preferences including `avatar_config`.
- **Mood Logs Table**: Stores daily check-ins (score, stress, energy, notes).
- **RLS Policies**: Row Level Security enabled for data privacy (users can only access their own data).
- **Auto-Profile Creation**: Trigger to create a profile automatically when a user signs up.

### How to Run
Run the file `database/migration_001_auth_integration.sql` in the Supabase SQL Editor.

## Migration 002: AI Agent Fields

This migration adds support for the three AI agents by adding new columns to the `mood_logs` table.

### New Columns

- `primary_emotion` (VARCHAR): Primary emotion detected (vui, buồn, giận, lo lắng, bình yên, mệt mỏi)
- `summary` (TEXT): One-sentence summary of emotional state
- `avatar_state` (VARCHAR): Avatar state for UI (STATE_JOYFUL, STATE_NEUTRAL, STATE_SAD, STATE_EXHAUSTED, STATE_ANXIOUS)

### How to Run Migration

#### Option 1: Using Supabase Dashboard (Recommended)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of `migration_002_ai_agents.sql`
4. Paste into the SQL editor
5. Click **Run** to execute the migration

#### Option 2: Using Supabase CLI

```bash
# Make sure you're in the project root
cd d:\AntigravityProjects\Auramind.app

# Run the migration
supabase db push database/migration_002_ai_agents.sql
```

#### Option 3: Using psql (Direct Database Connection)

```bash
# Connect to your Supabase database
psql "postgresql://postgres:[YOUR-PASSWORD]@[YOUR-PROJECT-REF].supabase.co:5432/postgres"

# Run the migration file
\i database/migration_002_ai_agents.sql
```

### Verification

After running the migration, verify the new columns exist:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'mood_logs' 
  AND column_name IN ('primary_emotion', 'summary', 'avatar_state');
```

You should see all three new columns listed.

### Rollback (if needed)

If you need to rollback this migration:

```sql
-- Remove the new columns
ALTER TABLE mood_logs DROP COLUMN IF EXISTS primary_emotion;
ALTER TABLE mood_logs DROP COLUMN IF EXISTS summary;
ALTER TABLE mood_logs DROP COLUMN IF EXISTS avatar_state;

-- Remove the indexes
DROP INDEX IF EXISTS idx_mood_logs_avatar_state;
DROP INDEX IF EXISTS idx_mood_logs_primary_emotion;
```

## Notes

- This migration is **non-destructive** - it only adds new columns
- Existing data will not be affected
- The new columns are nullable, so old records will have NULL values
- New mood logs will automatically populate these fields via the AI agents
