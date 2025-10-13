-- User Profiles Table Schema for Budget Guardian
-- Run this in your Supabase SQL Editor

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id BIGSERIAL PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  monthly_income NUMERIC,
  categories JSONB DEFAULT '{
    "groceries": 0,
    "gas": 0,
    "dining": 0,
    "entertainment": 0,
    "utilities": 0,
    "other": 0
  }'::jsonb,
  budget_limits JSONB DEFAULT '{}'::jsonb,
  spending_goals JSONB DEFAULT '[]'::jsonb,
  monthly_spending JSONB DEFAULT '{}'::jsonb,
  notes TEXT DEFAULT '',
  total_conversations INTEGER DEFAULT 0,
  total_budget NUMERIC,
  remaining_budget NUMERIC,
  ai_savings_total NUMERIC DEFAULT 0,
  ai_savings_recommendations JSONB DEFAULT '[]'::jsonb,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);

-- Add helpful comment
COMMENT ON TABLE user_profiles IS 'Stores financial profile data for each Telegram user';
COMMENT ON COLUMN user_profiles.user_id IS 'Telegram user ID (unique identifier)';
COMMENT ON COLUMN user_profiles.monthly_income IS 'User''s monthly income in dollars';
COMMENT ON COLUMN user_profiles.categories IS 'JSON object tracking spending by category';
COMMENT ON COLUMN user_profiles.budget_limits IS 'JSON object with budget limits per category';
COMMENT ON COLUMN user_profiles.spending_goals IS 'Array of user''s financial goals';
COMMENT ON COLUMN user_profiles.total_conversations IS 'Count of bot interactions';
COMMENT ON COLUMN user_profiles.total_budget IS 'User''s total budget amount';
COMMENT ON COLUMN user_profiles.remaining_budget IS 'Remaining budget after expenses';
COMMENT ON COLUMN user_profiles.ai_savings_total IS 'Total amount saved through AI recommendations';
COMMENT ON COLUMN user_profiles.ai_savings_recommendations IS 'Array of savings recommendations and their impact';

-- If the table already exists, add the new columns with:
-- ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS total_budget NUMERIC;
-- ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS remaining_budget NUMERIC;
-- ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS ai_savings_total NUMERIC DEFAULT 0;
-- ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS ai_savings_recommendations JSONB DEFAULT '[]'::jsonb;

-- Enable Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for service role
-- Note: Adjust this policy based on your security requirements
CREATE POLICY "Enable all operations for service role" ON user_profiles
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Optional: Create a function to auto-update last_updated timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Optional: Create trigger to automatically update last_updated
CREATE TRIGGER update_user_profiles_updated_at 
  BEFORE UPDATE ON user_profiles 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Verify table creation
SELECT 
  table_name, 
  column_name, 
  data_type 
FROM information_schema.columns 
WHERE table_name = 'user_profiles'
ORDER BY ordinal_position;
