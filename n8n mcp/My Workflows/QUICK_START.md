# 🚀 Quick Start: User Profile Storage

## What Was Added

Your workflow now includes **6 new nodes** that enable persistent user memory:

### New Nodes:
1. **Fetch User Profile** - Gets user data from Supabase
2. **Merge User Context** - Combines profile with current message
3. **Extract Profile Updates** - Parses financial info from conversation
4. **Save User Profile** - Saves updates to database

### Enhanced Nodes:
- **AI Agent - Analyst** - Now includes user financial profile
- **AI Agent - Direct Response** - Uses profile for personalized advice

## 🎯 What You Need to Do

### 1. Set Up Supabase (5 minutes)

1. Go to [supabase.com](https://supabase.com) → Create account
2. Create a new project
3. Go to SQL Editor → Run this:

```sql
CREATE TABLE user_profiles (
  id BIGSERIAL PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  monthly_income NUMERIC,
  categories JSONB DEFAULT '{"groceries": 0, "gas": 0, "dining": 0, "entertainment": 0, "utilities": 0, "other": 0}'::jsonb,
  budget_limits JSONB DEFAULT '{}'::jsonb,
  spending_goals JSONB DEFAULT '[]'::jsonb,
  monthly_spending JSONB DEFAULT '{}'::jsonb,
  notes TEXT DEFAULT '',
  total_conversations INTEGER DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable all operations for service role" ON user_profiles
  FOR ALL USING (true) WITH CHECK (true);
```

### 2. Configure n8n Credentials (2 minutes)

1. In n8n → **Credentials** → **New**
2. Search **Supabase**
3. Enter:
   - Host: `https://your-project.supabase.co`
   - Service Role Key: From Supabase → Project Settings → API
4. Save as "Supabase account"
5. **Copy the credential ID**

### 3. Update Workflow (1 minute)

In `telegram1.json`, find and replace `REPLACE_WITH_YOUR_SUPABASE_CREDENTIAL_ID` with your actual ID:

**Two places to update:**
- Line ~641: Fetch User Profile node
- Line ~939: Save User Profile node

Replace:
```json
"id": "REPLACE_WITH_YOUR_SUPABASE_CREDENTIAL_ID"
```

With:
```json
"id": "abc123xyz"  ← Your actual credential ID
```

## ✅ Test It

### Test 1: Set Your Profile
Message your bot:
```
I earn $3000 per month and spend $200 on groceries
```

### Test 2: Check Memory
Later, message:
```
How much do I spend on groceries?
```

Bot should reference your $200!

### Test 3: Verify Database
In Supabase → Table Editor → user_profiles
You should see your data!

## 📊 What Gets Tracked Automatically

The bot extracts and saves:
- ✅ Monthly income (e.g., "I make $3000/month")
- ✅ Groceries spending
- ✅ Gas/fuel spending
- ✅ Dining/restaurant spending
- ✅ Entertainment spending
- ✅ Utilities/bills
- ✅ Conversation count
- ✅ Last interaction time

## 💡 Example Usage

**First conversation:**
```
You: I make $3500 monthly. I spend about $250 on groceries and $120 on gas.
Bot: Got it! I've recorded your financial profile...
```

**Later conversation:**
```
You: Find me the cheapest milk in Waterloo
Bot: Based on your $250 monthly grocery budget, here are the best options:
     • FreshCo - $3.99/4L (saves you $12/month!)
     • No Frills - $4.29/4L
     Tip: Shopping at FreshCo helps you stay within your grocery budget!
```

## 📚 Full Documentation

- **USER_PROFILE_SETUP.md** - Complete setup guide with troubleshooting
- **user_profiles_schema.sql** - Full SQL schema with comments
- **USER_STORAGE_FLOW.md** - Visual flow diagram and technical details

## 🔧 Troubleshooting

**Bot not remembering data?**
- Check Supabase credentials are correct
- Verify table was created successfully
- Check n8n execution logs for errors

**"Credential not found" error?**
- Update the credential IDs in both nodes
- Make sure you copied the ID, not the name

**Need help?**
Check the detailed guides or review your n8n execution logs!

---

**Total setup time: ~10 minutes**  
**Result: Bot with perfect memory! 🧠✨**
