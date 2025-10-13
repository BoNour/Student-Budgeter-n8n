-- Add AI Savings Tracking Columns to user_profiles Table
-- Run this in your Supabase SQL Editor

-- Add ai_savings_total column
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS ai_savings_total NUMERIC DEFAULT 0;

-- Add ai_savings_recommendations column
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS ai_savings_recommendations JSONB DEFAULT '[]'::jsonb;

-- Add comments for documentation
COMMENT ON COLUMN user_profiles.ai_savings_total IS 'Total amount saved through AI recommendations';
COMMENT ON COLUMN user_profiles.ai_savings_recommendations IS 'Array of savings recommendations and their impact';

-- Verify the columns were added
SELECT 
  column_name, 
  data_type,
  column_default
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
  AND column_name IN ('ai_savings_total', 'ai_savings_recommendations')
ORDER BY column_name;

-- Optional: Initialize existing users with default values (if any exist)
UPDATE user_profiles 
SET 
  ai_savings_total = 0,
  ai_savings_recommendations = '[]'::jsonb
WHERE ai_savings_total IS NULL 
   OR ai_savings_recommendations IS NULL;

-- Verify update
SELECT 
  user_id,
  ai_savings_total,
  ai_savings_recommendations
FROM user_profiles
LIMIT 5;

