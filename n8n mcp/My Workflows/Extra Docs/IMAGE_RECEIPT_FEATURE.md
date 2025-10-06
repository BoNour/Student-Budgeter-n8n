# 📸 Image Receipt Scanner Feature

## 🎯 Overview

Your bot now automatically reads and processes receipt images! Just send a photo of any receipt and the AI will:
- Extract the total amount
- Identify the merchant/store
- Categorize the expense
- Add it to your spending profile
- Track all receipts in your notes

## 🔄 How It Works

```
User sends image
    ↓
Check if Image? → YES
    ↓
Get Image File from Telegram
    ↓
Analyze with OpenAI Vision
    ↓
Extract expense details (amount, merchant, category, items)
    ↓
Format expense data
    ↓
Merge with user message
    ↓
Update user profile (adds to spending category)
    ↓
Save receipt details to notes
```

## 📊 What Gets Extracted

The AI vision model analyzes receipts and extracts:

✅ **Amount**: Total spent (e.g., $25.47)  
✅ **Merchant**: Store name (e.g., "Walmart", "FreshCo")  
✅ **Category**: Auto-categorized as:
- `groceries` - Food stores, supermarkets
- `gas` - Gas stations, fuel
- `dining` - Restaurants, cafes
- `entertainment` - Movies, games, subscriptions
- `utilities` - Bills, phone, internet
- `other` - Everything else

✅ **Date**: Purchase date (if visible)  
✅ **Items**: List of purchased items  
✅ **Payment Method**: Cash, card, debit, etc.  
✅ **Notes**: Any additional details

## 💡 Usage Examples

### Example 1: Grocery Receipt
**Send**: Photo of grocery receipt from FreshCo showing $45.23

**Bot response**:
```
Receipt processed: $45.23 at FreshCo for groceries (milk, bread, eggs, cheese)
```

**What happens**:
- Adds $45.23 to your `groceries` category
- Saves note: `[2025-09-30] Receipt: $45.23 at FreshCo (groceries)`
- Updates your total monthly grocery spending

### Example 2: Gas Receipt
**Send**: Photo of gas station receipt for $52.10

**Bot response**:
```
Receipt processed: $52.10 at Shell for gas
```

**What happens**:
- Adds $52.10 to your `gas` category
- Tracks in your spending profile

### Example 3: Restaurant Receipt
**Send**: Photo of restaurant bill from The Keg

**Bot extracts**:
- Amount: $87.50
- Merchant: The Keg
- Category: dining
- Items: Steak, salad, drink

## 📈 Benefits

### 1. **Automatic Tracking**
No need to manually type expenses - just snap a photo!

### 2. **Accurate Categorization**
AI understands context and assigns correct categories

### 3. **Complete History**
All receipts saved in your profile notes with dates

### 4. **Budget Insights**
See real spending patterns: "You've spent $200 on groceries this month"

### 5. **Receipt Archive**
Never lose track of purchases - everything is logged

## 🧪 Testing

### Test 1: Clear Receipt
Take a photo of a clear, well-lit receipt and send it

**Expected**: Bot extracts all details accurately

### Test 2: Check Profile
After sending 2-3 receipts, ask:
```
How much have I spent on groceries?
```

**Expected**: Bot shows cumulative total

### Test 3: View History
Check your Supabase `user_profiles` table → `notes` field

**Expected**: See list of all receipt entries with dates

## 🔧 Technical Details

### Nodes Added:
1. **Check if Image** (IF node)
   - Checks if message contains photo array
   
2. **Get Image File** (Telegram node)
   - Downloads highest quality image from Telegram
   
3. **Analyze Receipt with Vision** (OpenAI Vision node)
   - Uses GPT-4 Vision with "high" detail mode
   - Specialized prompt for receipt extraction
   
4. **Format Expense Data** (Set node)
   - Parses AI response into structured data
   - Creates user-friendly message

### Data Flow:
- Image → Vision AI → JSON parsing → Category update → Database save

### Vision Prompt:
The AI is instructed to extract:
```json
{
  "amount": (number),
  "currency": (string),
  "category": (string),
  "merchant": (string),
  "date": (string),
  "items": (array),
  "payment_method": (string),
  "notes": (string)
}
```

## 💾 Database Storage

### Categories Updated:
The expense amount is **added** to the existing category total:
```javascript
categories[category] = (existing_amount || 0) + new_amount
```

### Notes Field:
Each receipt adds a timestamped entry:
```
[2025-09-30] Receipt: $45.23 at FreshCo (groceries)
[2025-10-01] Receipt: $52.10 at Shell (gas)
[2025-10-02] Receipt: $87.50 at The Keg (dining)
```

## 🎨 Supported Image Types

✅ Receipt photos  
✅ Bill screenshots  
✅ Invoice images  
✅ Store receipts  
✅ Gas station receipts  
✅ Restaurant bills  

## ⚠️ Tips for Best Results

### 1. **Good Lighting**
Take photos in good lighting - avoid shadows

### 2. **Clear Focus**
Make sure the receipt is in focus and readable

### 3. **Full Receipt**
Capture the entire receipt, especially the total

### 4. **Flat Surface**
Place receipt on flat surface for best angle

### 5. **High Resolution**
Telegram automatically sends high quality - no need to compress

## 🔒 Privacy & Security

- Images are processed through OpenAI Vision API
- No images are permanently stored
- Only extracted data (amounts, categories) saved
- All data encrypted in Supabase

## 📊 Example Workflow

**Day 1**: Send 3 grocery receipts ($45, $32, $67)  
**Result**: Groceries category = $144

**Day 2**: Ask "How much did I spend on groceries?"  
**Bot**: "Based on your profile, you spend $144 on groceries..."

**Day 3**: Send gas receipt ($52)  
**Result**: Gas category = $52

**Day 4**: Ask "Show me my spending this week"  
**Bot**: Shows breakdown with all categories

## 🚀 Future Enhancements

Potential improvements:
- [ ] Support for multiple items on one receipt
- [ ] Tax extraction and tracking
- [ ] Tip calculations for restaurants
- [ ] Recurring expense detection
- [ ] Budget alerts when exceeding limits
- [ ] Monthly receipt summaries
- [ ] Export receipts to CSV/PDF

---

## ✅ Quick Start

**Just send a receipt photo to your bot!**

The AI does everything automatically:
1. Recognizes it's a receipt
2. Extracts all financial data
3. Updates your spending profile
4. Confirms what was processed

**No commands needed. No manual entry. Just snap and send! 📸✨**

