# Bug Fix: Budget Fields Being Overridden

## Issue Description
When users set category budgets (e.g., "reduce my dining budget by 50 from 300 to 250"), the workflow was incorrectly overriding `total_budget`, `remaining_budget`, and `ai_savings_total` with the category budget amount (50 in this case).

**Example Bug:**
- User had `total_budget: $900`
- User said: "reduce my dining budget by 50 from 300 to 250"
- Bug result: `total_budget: 50`, `remaining_budget: 50`, `ai_savings_total: 50` ❌

## Root Cause
The regex patterns in the **Extract Profile Updates** node were too broad and matched any text containing "budget" + a number, including category budget commands.

### Affected Fields:
1. `total_budget` (extract-profile-009)
2. `remaining_budget` (extract-profile-010)
3. `ai_savings_total` (extract-profile-012)

## Solution

### 1. Fixed `total_budget` Extraction
**Before:**
```javascript
const budgetMatch = text.match(/(?:set|overall|total)?\\s*(?:budget|limit).*?\\$?([0-9,]+)/i);
```
This matched ANY "budget" + number, including "dining budget by 50".

**After:**
```javascript
// Skip if text mentions specific categories or reduction words
if (text.includes('dining') || text.includes('groceries') || text.includes('gas') || 
    text.includes('entertainment') || text.includes('utilities') || 
    text.includes('reduce') || text.includes('cut') || 
    text.includes('lower') || text.includes('decrease')) {
  return existing || null;
}

// Only match overall/total/monthly budget commands
const budgetMatch = text.match(/(?:set|my)?\\s*(?:overall|total|monthly)?\\s*budget\\s*(?:to|is|at)?\\s*\\$?([0-9,]+)/i);
```

### 2. Fixed `remaining_budget` Extraction
**Before:**
```javascript
const newBudgetMatch = text.match(/(?:set|overall|total)?\\s*(?:budget|limit).*?\\$?([0-9,]+)/i);
if (newBudgetMatch) {
  const newBudget = parseFloat(newBudgetMatch[1].replace(/,/g, ''));
  return newBudget;
}
```

**After:**
```javascript
// Skip category budget commands
if (text.includes('dining') || text.includes('groceries') || text.includes('gas') || 
    text.includes('entertainment') || text.includes('utilities')) {
  // Only update remaining_budget for expense tracking
  if (expenseData && expenseData.amount > 0) {
    return Math.max(0, existingRemaining - expenseData.amount);
  }
  return existingRemaining;
}

// Only match overall budget commands without reduction words
const newBudgetMatch = text.match(/(?:set|my)?\\s*(?:overall|total|monthly)?\\s*budget\\s*(?:to|is)?\\s*\\$?([0-9,]+)/i);
if (newBudgetMatch && !text.includes('reduce') && !text.includes('cut') && 
    !text.includes('lower') && !text.includes('decrease')) {
  const newBudget = parseFloat(newBudgetMatch[1].replace(/,/g, ''));
  return newBudget;
}
```

### 3. Fixed `ai_savings_total` Extraction
**Before:**
```javascript
// Analyzed both user input and AI output together
const text = getSourceText().toLowerCase();
const reduceMatch = text.match(/(?:cut|reduce|lower|decrease).*?(?:to|by)\\s*\\$?([0-9,]+)/i);
if (reduceMatch) {
  const reduction = parseFloat(reduceMatch[1].replace(/,/g, ''));
  if (reduction > 0) {
    return existing + reduction;
  }
}
```
This matched user commands like "reduce my dining budget by 50".

**After:**
```javascript
// Separate user input from AI output
const userText = $('Edit Fields1').item.json.user_text || '';
const aiOutput = $json.output || '';

// Skip if user is setting/changing budgets (not implementing AI suggestions)
if (userText.toLowerCase().includes('reduce') || 
    userText.toLowerCase().includes('set') || 
    userText.toLowerCase().includes('change')) {
  return existing;
}

// Only analyze AI output for savings recommendations
const text = aiOutput.toLowerCase();
if (!text || text.length < 10) {
  return existing;
}

// Look for AI suggesting savings
const savingsMatch = text.match(/(?:save|saving|saved)\\s*\\$?([0-9,]+(?:\\.[0-9]{2})?)/i);
if (savingsMatch) {
  const newSavings = parseFloat(savingsMatch[1].replace(/,/g, ''));
  if (newSavings > 0 && newSavings < 10000 && text.includes('month')) {
    return existing + newSavings;
  }
}
```

### 4. Fixed `ai_savings_recommendations` Extraction
Similar fix - now only tracks AI output, not user commands:

```javascript
const userText = $('Edit Fields1').item.json.user_text || '';
const aiOutput = $json.output || '';

// Skip user budget commands
if (userText.toLowerCase().includes('reduce') || 
    userText.toLowerCase().includes('set') || 
    userText.toLowerCase().includes('change')) {
  return existing;
}

// Only analyze AI output
const text = aiOutput;
```

## Key Improvements

1. **Separate User Input from AI Output**: Now distinguishes between what the user says vs. what the AI suggests
2. **Category Detection**: Skips total budget updates when specific categories are mentioned
3. **Action Word Detection**: Ignores reduction/change commands for overall budget fields
4. **More Specific Regex**: Requires "overall", "total", or "monthly" keywords for budget updates
5. **Sanity Checks**: Added upper bounds (< $10,000) to prevent accidental large values

## Testing Scenarios

### ✅ Should NOT Update Total Budget:
- "reduce my dining budget by 50"
- "set my groceries budget to 200"
- "cut entertainment to 100"
- "lower my gas budget"

### ✅ SHOULD Update Total Budget:
- "set my total budget to 900"
- "my overall budget is 1200"
- "set monthly budget to 1500"

### ✅ Should NOT Update AI Savings:
- User: "reduce my dining budget by 50" (user command, not AI suggestion)
- User: "set my budget to 500" (budget setting, not savings)

### ✅ SHOULD Update AI Savings:
- AI: "Cut dining to $300 (save $150/month)" (AI recommendation)
- AI: "You could save $200/month by reducing entertainment" (AI suggestion)

## Result
Now when users set category budgets, only the relevant `budget_limits` field is updated. The `total_budget`, `remaining_budget`, and `ai_savings_total` fields remain unchanged unless specifically commanded or recommended by the AI.

**Fixed Example:**
- User has `total_budget: $900`, `remaining_budget: $650`
- User says: "reduce my dining budget by 50 from 300 to 250"
- Correct result: 
  - `budget_limits.dining: 250` ✅
  - `total_budget: 900` ✅ (unchanged)
  - `remaining_budget: 650` ✅ (unchanged)
  - `ai_savings_total: 0` ✅ (unchanged, since user set it, not AI)

