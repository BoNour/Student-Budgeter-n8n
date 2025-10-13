# AI Savings Tracking Feature

## Overview
This feature enables Budget Guardian to track how much money users save through AI recommendations, creating a running total that motivates users and demonstrates the bot's value.

## Database Schema Changes

### New Columns Added to `user_profiles` Table

1. **`ai_savings_total`** (NUMERIC, DEFAULT 0)
   - Tracks the cumulative dollar amount saved through AI recommendations
   - Updates when AI suggests budget cuts or spending reductions
   - Example: If AI suggests cutting dining from $450 to $300, this adds $150

2. **`ai_savings_recommendations`** (JSONB, DEFAULT '[]')
   - Stores an array of savings recommendations with details
   - Each entry includes:
     - `date`: When the recommendation was made
     - `category`: Which spending category (groceries, dining, etc.)
     - `amount`: Dollar amount saved
     - `recommendation`: Brief text of what was suggested
   - Limited to last 10 recommendations

### Migration SQL
To add these columns to an existing database:

```sql
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS ai_savings_total NUMERIC DEFAULT 0;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS ai_savings_recommendations JSONB DEFAULT '[]'::jsonb;
```

## Workflow Changes

### 1. Merge User Context Node
- Now includes `ai_savings_total` and `ai_savings_recommendations` in user profile
- Displays AI savings in the user context summary when > $0
- Example: `"AI has helped save: $450.00 total"`

### 2. Extract Profile Updates Node
Added two new field assignments:

**`ai_savings_total` (extract-profile-012):**
- Detects savings mentions in AI responses
- Patterns detected:
  - "save/saving/saved $X"
  - "cut/reduce/lower/decrease to/by $X"
- Only adds to total when "month" is mentioned (to capture monthly savings)
- Accumulates on top of existing total

**`ai_savings_recommendations` (extract-profile-013):**
- Captures savings recommendations with context
- Extracts category from text (groceries, dining, gas, etc.)
- Stores date, category, amount, and recommendation text
- Keeps only the last 10 recommendations

### 3. Update User Profile & Create User Profile Nodes
Both now save the new fields to Supabase:
- `ai_savings_total`
- `ai_savings_recommendations`

### 4. AI Agent - Direct Response Prompt
Enhanced with savings tracking capabilities:

**DETAILED USER DATA section:**
- Now includes AI Savings in the data provided to the AI
- Shows total saved through recommendations

**CRITICAL: PERSONALIZATION & SAVINGS TRACKING section:**
- AI now PROACTIVELY suggests savings when seeing overspending
- Mentions specific dollar amounts in savings recommendations
- Reminds users of their cumulative AI savings
- Example output: *"You've spent $450 on dining. Cut that to $300/month and save $150. So far, I've helped you save $450 total!"*

## How It Works

### Example Flow:

1. **User asks:** "How do I save more money?"

2. **AI analyzes their spending:**
   - Sees: dining: $450/month, entertainment: $200/month
   - No budgets set

3. **AI responds:**
   ```
   Based on your spending: You spent $450 on dining and $200 on entertainment. 
   Try cutting dining to $300 (save $150) and entertainment to $100 (save $100). 
   That's $250/month saved!
   ```

4. **Extract Profile Updates detects:**
   - "save $150" → adds to ai_savings_total
   - "save $100" → adds to ai_savings_total
   - Creates recommendation entries for both

5. **Database updates:**
   - `ai_savings_total`: 0 → 250
   - `ai_savings_recommendations`: Adds two entries with date, categories, amounts

6. **Next conversation:**
   - AI sees: `"AI Savings: $250.00 total saved through recommendations"`
   - Can reference this in future responses

## Benefits

1. **Motivation:** Users see concrete value from the AI's suggestions
2. **Accountability:** Tracks which categories generate the most savings
3. **Proof of Value:** Demonstrates the bot's financial impact
4. **Gamification:** Creates a sense of achievement as savings grow
5. **Personalization:** AI can reference past savings in conversations

## Usage Examples

### When User Uploads Receipt
```
"Receipt detected! $45.00 at Starbucks (dining). You've spent $450 this month 
on dining. Cut that to $300 and save $150/month. So far I've helped you save 
$250 total!"
```

### When User Asks About Budget
```
"Your dining budget is $300/month. You've spent $280, leaving $20. Good job! 
By following my suggestions, you've saved $250 total. 💰"
```

### Proactive Savings Suggestions
```
"Your entertainment spending ($200) is high. Try streaming services instead 
of going out - save $100/month. I've helped you save $250 so far!"
```

## Future Enhancements

Potential improvements:
- Monthly/yearly savings reports
- Savings goals and tracking
- Category-specific savings breakdown
- Comparison with other users (anonymized)
- Badges/achievements for savings milestones
- Export savings history for taxes/records

