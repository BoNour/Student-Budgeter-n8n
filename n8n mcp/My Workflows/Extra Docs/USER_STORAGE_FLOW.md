# User Profile Storage Flow

## 📋 Overview

Your workflow now includes **persistent user storage** that remembers:
- Monthly income
- Spending by category (groceries, gas, dining, etc.)
- Budget limits
- Financial goals
- Conversation history

## 🔄 Complete Workflow Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Telegram Message Arrives                     │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
           ┌──────────────────────────┐
           │  Check if Audio file     │
           └──────┬──────────┬────────┘
                  │          │
         (Audio)  │          │  (Text)
                  ▼          ▼
         ┌──────────┐  ┌──────────┐
         │ Get file │  │Set field │
         └────┬─────┘  └────┬─────┘
              │             │
              ▼             │
      ┌──────────────┐      │
      │ Transcribe   │      │
      └──────┬───────┘      │
             │              │
             └──────┬───────┘
                    ▼
           ┌─────────────────┐
           │  Edit Fields    │
           │  (extract user  │
           │   & chat IDs)   │
           └────────┬────────┘
                    │
                    ▼
           ╔═════════════════════╗
           ║ Fetch User Profile  ║  ← NEW! Queries Supabase
           ║   from Database     ║
           ╚═══════════┬═════════╝
                       │
                       ▼
           ╔═════════════════════╗
           ║ Merge User Context  ║  ← NEW! Combines current
           ║  (add profile to    ║     message with history
           ║   current data)     ║
           ╚═══════════┬═════════╝
                       │
                       ▼
           ┌──────────────────────┐
           │  AI Agent - Planner  │
           │  (with user context) │
           └───────┬──────────────┘
                   │
        ┌──────────┼──────────┐
        │                     │
        ▼                     ▼
┌─────────────┐     ┌──────────────────┐
│ Normalize   │     │ AI Agent - Direct│ ← Always runs!
│   Flags     │     │    Response      │   Uses web search
└──────┬──────┘     │ (with profile)   │   + user context
       │            └────────┬──────────┘
   ┌───┴───┐               │
   │       │               ▼
   ▼       ▼        ┌────────────────┐
┌──────┐ ┌──────┐  │ Compose Message│
│ If   │ │ If   │  │    - Direct    │
│Analyst│ │Price?│  └───────┬────────┘
└──┬───┘ └──┬───┘          │
   │        │              ▼
   ▼        ▼       ╔══════════════════╗
   ...    ...       ║ Reply in Telegram║
                    ║     (Direct)     ║
                    ╚═════════┬════════╝
                              │
                              ▼
                    ╔═════════════════════╗
                    ║ Extract Profile     ║  ← NEW! Parses
                    ║    Updates          ║     financial data
                    ║ (from conversation) ║     from message
                    ╚═══════════┬═════════╝
                                │
                                ▼
                    ╔═════════════════════╗
                    ║  Save User Profile  ║  ← NEW! Saves to
                    ║   to Database       ║     Supabase
                    ╚═════════════════════╝
```

## 🎯 Key Improvements

### 1. **User Profile Loading** (After Edit Fields)
- Extracts Telegram `user_id`
- Queries Supabase for existing profile
- Returns empty profile for new users

### 2. **Context Merging** (Before AI Agents)
- Combines current message with user history
- Creates `user_context_summary` string
- Example: `"Monthly income: $3000 | Monthly spending - Groceries: $200, Gas: $100"`

### 3. **AI with Memory** (All AI Agents)
- **AI Agent - Planner**: Now aware of user's financial status
- **AI Agent - Analyst**: Provides insights based on spending history
- **AI Agent - Direct Response**: Personalized recommendations with context

### 4. **Automatic Profile Updates** (After Response)
- Extracts new financial data from conversation
- Updates categories if mentioned
- Saves back to database

## 📊 Data Extraction Examples

### Example 1: Income Detection
**User says**: "I make $3500 per month"
- System extracts: `monthly_income: 3500`
- Saves to database
- Future responses reference this income

### Example 2: Category Spending
**User says**: "I spend $250 on groceries and $100 on gas"
- System extracts:
  ```json
  {
    "groceries": 250,
    "gas": 100
  }
  ```
- Merges with existing categories
- AI can now give personalized grocery tips

### Example 3: Context-Aware Response
**User asks**: "Find me cheapest milk in Waterloo"

**Without profile**: Generic search results

**With profile** (knows you spend $250/month on groceries):
```
Based on your $250 monthly grocery budget, here are the best milk prices:
• FreshCo - $3.99/4L (cheapest!)
• No Frills - $4.29/4L
• Walmart - $4.49/4L

Tip: Buying at FreshCo could save you ~$10/month on dairy!
```

## 🧪 Testing Scenarios

### Test 1: Profile Creation
```
You: "I earn $3000 monthly, spend $200 on groceries and $150 on gas"
Bot: [Acknowledges and saves]
```

Check database:
```sql
SELECT * FROM user_profiles WHERE user_id = 'YOUR_TELEGRAM_ID';
```

### Test 2: Profile Recall
```
You: "How much do I spend on groceries?"
Bot: "Based on your profile, you spend $200 on groceries..."
```

### Test 3: Personalized Search
```
You: "Find cheap pasta near me"
Bot: [Searches and provides options within your grocery budget]
```

### Test 4: Conversation Count
Send multiple messages, then check:
```sql
SELECT total_conversations FROM user_profiles WHERE user_id = 'YOUR_ID';
```
Should increment with each interaction.

## 🔍 Troubleshooting

### Bot doesn't remember my income
**Check**:
1. Verify Supabase credentials are configured
2. Check "Save User Profile" node executed successfully
3. Look for extraction errors in "Extract Profile Updates" node

### AI doesn't use my profile
**Check**:
1. "Fetch User Profile" node is fetching data
2. "Merge User Context" is creating `user_context_summary`
3. AI Agent prompts include the profile reference

### Database not updating
**Check**:
1. "Extract Profile Updates" node is running
2. Supabase credentials have write permissions
3. RLS policies allow upsert operations

## 📈 Future Enhancements

You can extend this system to track:
- **Weekly spending trends**
- **Budget alerts** (when over limit)
- **Savings goals progress**
- **Recurring expenses**
- **Bill reminders**
- **Custom categories**

Just add fields to the database and update the extraction logic!

## 🎓 Understanding the Code

### User Context Summary (line 682-684)
This creates a readable summary of the user's financial profile:
```javascript
// If user has $3000 income and spends $200 on groceries
"Monthly income: $3000 | Monthly spending - Groceries: $200 | ..."
```

### Extraction Patterns (line 834-842)
Regular expressions find financial data in messages:
```javascript
/(?:groceries|food|supermarket).*?\$?([0-9,]+)/i
// Matches: "groceries $200", "food: 200", "$200 for supermarket"
```

### Profile Merging (line 676-678)
Combines new data with existing profile:
```javascript
categories: { ...existing, ...newlyExtracted }
// Preserves old categories, updates mentioned ones
```

---

**Your bot now has memory! 🧠✨**

Every conversation builds a richer financial profile, enabling increasingly personalized and helpful responses.
