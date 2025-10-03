# Budget Tracking with Receipt Upload - Feature Guide

## What Was Fixed

Your Budget Guardian bot now properly tracks expenses from receipt images and deducts them from your budget!

### Changes Made:

1. **Added Budget Fields** to user profiles:
   - `total_budget`: The budget amount a user sets
   - `remaining_budget`: Budget minus expenses

2. **Enhanced Receipt Processing**:
   - Receipt images are analyzed with OpenAI Vision
   - Expense data (amount, merchant, category) is extracted
   - Amount is automatically deducted from remaining budget
   - Spending is tracked by category (groceries, gas, dining, etc.)

3. **Improved Feedback**:
   - Bot now shows budget impact when you upload a receipt
   - Displays remaining budget after each expense
   - Warns you when budget is running low (< 20%)
   - Encourages setting a budget if you haven't yet

## How to Use

### Setting Your Budget

Send a message to the bot:
```
Set my budget to $500
```
or
```
My budget is $1000
```

### Uploading a Receipt

1. Take a photo of your receipt
2. Send it to the bot via Telegram
3. The bot will:
   - Extract the amount, merchant, and category
   - Deduct from your remaining budget
   - Show you the updated budget status

**Example Response:**
```
Receipt detected! $23.45 spent at Walmart (groceries)
Budget: $476.55 / $500 remaining

I've logged this expense. You're on track!
```

### Checking Your Budget

Ask the bot:
```
How much budget do I have left?
```
or
```
Show me my spending
```

## Database Setup

If your Supabase table already exists, run these commands in your Supabase SQL Editor:

```sql
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS total_budget NUMERIC;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS remaining_budget NUMERIC;
```

Or create a fresh table using the updated `user_profiles_schema.sql` file.

## Workflow Flow

1. **Telegram Message** → Receipt image uploaded
2. **Check if Image** → Detects photo message
3. **Get Image File** → Downloads the image
4. **Analyze Receipt with Vision** → OpenAI extracts expense data
5. **Format Expense Data** → Structures the data (amount, category, merchant)
6. **Edit Fields** → Passes expense_data through workflow
7. **Merge User Context** → Loads user profile with budget info
8. **AI Agent - Direct Response** → Provides receipt confirmation with budget impact
9. **Extract Profile Updates** → Calculates new remaining_budget
10. **Update/Create User Profile** → Saves to Supabase

## Features

✅ **Automatic expense extraction** from receipt photos
✅ **Budget tracking** with real-time balance updates
✅ **Category-based spending** (groceries, gas, dining, etc.)
✅ **Low budget warnings** when you're running out
✅ **Spending history** stored in notes
✅ **Multi-category budgets** (coming soon - already has budget_limits field)

## Tips

- Make sure receipts are clear and well-lit for best OCR accuracy
- The bot recognizes various receipt formats
- If the bot can't read a receipt, you can manually type: "I spent $20 at Starbucks"
- Use voice messages to quickly log expenses: "Twenty dollars on gas"

## Troubleshooting

**Receipt not recognized?**
- Ensure the image is in focus
- Try better lighting
- Make sure the total amount is visible

**Budget not updating?**
- Check that you've set a budget first
- Verify Supabase credentials are connected
- Look for expense_data in the workflow execution logs

## Next Steps

You can enhance this further by:
- Adding category-specific budgets (e.g., $200 for groceries, $100 for gas)
- Setting up alerts when approaching budget limits
- Creating weekly/monthly budget reports
- Implementing budget rollover for unused amounts


