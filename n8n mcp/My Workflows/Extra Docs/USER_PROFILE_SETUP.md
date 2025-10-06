# User Profile Storage Setup Guide

This guide will help you set up persistent user storage for your Budget Guardian Telegram bot.

## 🗄️ Database Setup (Supabase)

### Step 1: Create a Supabase Account
1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in
3. Create a new project
4. Note down your project URL and API key

### Step 2: Create the User Profiles Table

Run this SQL in your Supabase SQL Editor:

```sql
-- Create user_profiles table
CREATE TABLE user_profiles (
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
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on user_id for faster lookups
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (adjust based on your security needs)
CREATE POLICY "Enable all operations for service role" ON user_profiles
  FOR ALL
  USING (true)
  WITH CHECK (true);
```

### Step 3: Configure n8n Supabase Credentials

1. In n8n, go to **Credentials** → **New Credential**
2. Search for **Supabase**
3. Fill in:
   - **Host**: Your Supabase project URL (e.g., `https://xxxxx.supabase.co`)
   - **Service Role Secret**: Your Supabase service role key (found in Project Settings → API)
4. Save with a memorable name like "Supabase account"
5. **Copy the credential ID**

### Step 4: Update Workflow Nodes

In your `telegram1.json` workflow, replace `REPLACE_WITH_YOUR_SUPABASE_CREDENTIAL_ID` with your actual credential ID:

Find these two locations:
1. **Fetch User Profile** node (line ~641)
2. **Save User Profile** node (line ~939)

Replace:
```json
"credentials": {
  "supabaseApi": {
    "id": "REPLACE_WITH_YOUR_SUPABASE_CREDENTIAL_ID",
    "name": "Supabase account"
  }
}
```

With:
```json
"credentials": {
  "supabaseApi": {
    "id": "YOUR_ACTUAL_CREDENTIAL_ID_HERE",
    "name": "Supabase account"
  }
}
```

## 📊 What Gets Stored

The system automatically tracks:

### Financial Data
- **Monthly Income**: Extracted from messages like "I earn $3000 per month"
- **Spending Categories**:
  - Groceries
  - Gas/Fuel
  - Dining/Restaurants
  - Entertainment
  - Utilities
  - Other

### Conversation Data
- **Total Conversations**: Count of interactions
- **Last Updated**: Timestamp of last interaction
- **Notes**: Custom notes (can be added manually)

### Budget Management
- **Budget Limits**: Per-category spending limits
- **Spending Goals**: List of financial goals

## 💡 How It Works

### 1. User Message Arrives
```
"I spend $200 on groceries monthly"
```

### 2. Profile Lookup
- Bot extracts user_id from Telegram
- Checks if user exists in database
- Fetches previous financial data

### 3. Context Enhancement
- AI receives user's financial profile
- Provides personalized advice based on history
- Example: "Based on your $200 monthly grocery budget..."

### 4. Automatic Updates
- System parses new financial info from conversation
- Updates relevant categories
- Saves to database for future use

## 🧪 Testing Your Setup

### Test 1: First Message
Send to bot:
```
I earn $3000 per month and spend $300 on groceries
```

Expected: Bot acknowledges and stores this info

### Test 2: Follow-up Message
Send:
```
How much do I spend on groceries?
```

Expected: Bot references your $300 grocery spending

### Test 3: Verify Database
In Supabase SQL Editor:
```sql
SELECT * FROM user_profiles;
```

You should see your Telegram user_id with stored data.

## 🔧 Troubleshooting

### Issue: "Fetch User Profile" node fails
- ✅ Check Supabase credentials are correct
- ✅ Verify table exists: `SELECT * FROM user_profiles LIMIT 1;`
- ✅ Check RLS policies allow access

### Issue: Data not saving
- ✅ Verify "Save User Profile" node has correct credential ID
- ✅ Check the "Extract Profile Updates" node runs successfully
- ✅ Look at n8n execution logs for errors

### Issue: Bot doesn't remember previous conversations
- ✅ Confirm user_id is being extracted correctly
- ✅ Check if data exists in database
- ✅ Verify "Merge User Context" node is receiving profile data

## 📈 Data Example

Here's what a stored profile looks like:

```json
{
  "user_id": "123456789",
  "monthly_income": 3000,
  "categories": {
    "groceries": 300,
    "gas": 150,
    "dining": 200,
    "entertainment": 100,
    "utilities": 150,
    "other": 50
  },
  "budget_limits": {
    "groceries": 350,
    "dining": 180
  },
  "spending_goals": [
    "Save $500 per month",
    "Reduce dining expenses by 20%"
  ],
  "total_conversations": 15,
  "last_updated": "2025-09-30T10:30:00Z"
}
```

## 🚀 Advanced: Adding Custom Fields

To track additional data, add columns to your table:

```sql
ALTER TABLE user_profiles
ADD COLUMN custom_field TEXT;
```

Then update the nodes to store/retrieve this field.

## 🔐 Security Best Practices

1. **Never share** your Supabase service role key
2. **Configure RLS policies** based on your security requirements
3. **Backup regularly** using Supabase's backup features
4. **Monitor usage** to prevent unexpected costs

---

## ✅ Quick Checklist

- [ ] Created Supabase account and project
- [ ] Ran SQL to create `user_profiles` table
- [ ] Created Supabase credentials in n8n
- [ ] Updated credential IDs in workflow nodes
- [ ] Tested with sample messages
- [ ] Verified data in Supabase dashboard

Need help? Check the [n8n Supabase documentation](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.supabase/).
