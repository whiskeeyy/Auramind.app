-- Migration 004: Create chat_messages table
-- Purpose: Store conversation history for memory and context
-- Security: RLS enabled (private to user)

-- Table: chat_messages
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role VARCHAR(10) NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  avatar_state VARCHAR(50), -- Optional: store emotional state of AI at that moment
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Policy: Select (Users can view their own messages)
CREATE POLICY "Users can view own messages" ON chat_messages
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Insert (Users can insert their own messages)
-- Note: Assistant messages are inserted by the backend which acts with RLS context of the user
CREATE POLICY "Users can insert messages" ON chat_messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Indexes for performance (fetching history sorted by time)
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_created 
ON chat_messages(user_id, created_at DESC);

-- Add comments
COMMENT ON TABLE chat_messages IS 'Stores chat history between user and AI companion';
COMMENT ON COLUMN chat_messages.role IS 'Role of the message sender: user or assistant';
