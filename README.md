# Student Budgeter n8n Workflows

Student Budgeter is an AI-powered budgeting assistant built as an n8n workflow.  
It connects a chat interface (Telegram) to Supabase so the bot can **remember each user’s financial profile** and give personalized budgeting advice over time.

## Features

- **Conversational budgeting assistant**: Chat with the bot about income, spending, and goals.
- **Persistent user profiles**: Every user’s income, category budgets, and notes are stored in a Supabase `user_profiles` table.
- **Automatic tracking**:
  - Monthly income (e.g., “I make $3000/month”)
  - Category spending (groceries, gas, dining, entertainment, utilities, other)
  - Spending goals and monthly spending (via JSON fields)
  - Conversation count and last interaction time
- **AI analysis & responses**:
  - An **AI Agent – Analyst** node that understands the user’s financial context
  - An **AI Agent – Direct Response** node that replies with tailored guidance
- **Extensible design**: Extra docs show how to add features like AI savings tracking, image receipt parsing, deployment helpers, and more.

## Repository Structure

- **`n8n mcp/My Workflows/telegram1.json`**: Main n8n workflow (Telegram bot + user profile storage flow).
- **`n8n mcp/My Workflows/QUICK_START.md`**: Short setup guide for Supabase + n8n credentials.
- **`n8n mcp/My Workflows/user_profiles_schema.sql`**: SQL schema for the `user_profiles` table.
- **`n8n mcp/My Workflows/Extra Docs/`**: Additional documentation and helpers:
  - `USER_PROFILE_SETUP.md` – Full setup guide and troubleshooting.
  - `USER_STORAGE_FLOW.md` – Flow diagram and technical details.
  - `BUDGET_TRACKING_GUIDE.md`, `AI_SAVINGS_TRACKING.md`, `IMAGE_RECEIPT_FEATURE.md`, `DEPLOYMENT-GUIDE.md`, etc.
- **`Old versions/`**: Archived / backup workflow JSON files.

## Prerequisites

- **n8n instance** (self-hosted or cloud).
- **Supabase project** with access to the SQL Editor and service role key.
- **Telegram bot** (if you use the Telegram workflow) with a bot token configured in n8n.

## Quick Start

This is a high-level summary; for screenshots and more detail see `n8n mcp/My Workflows/QUICK_START.md`.

### 1. Set Up Supabase

1. Go to [Supabase](https://supabase.com) and create a project.
2. In the **SQL Editor**, run the SQL from `n8n mcp/My Workflows/user_profiles_schema.sql`  
   (or copy the table definition from `QUICK_START.md`).
3. Confirm the `user_profiles` table exists and row-level security policies are applied.

### 2. Create Supabase Credentials in n8n

1. In n8n, go to **Credentials → New → Supabase**.
2. Enter:
   - **Host**: `https://your-project.supabase.co`
   - **Service Role Key**: from Supabase **Project Settings → API**.
3. Save the credential (e.g., as **"Supabase account"**) and note its **credential ID**.

### 3. Import and Configure the Workflow

1. In n8n, import `n8n mcp/My Workflows/telegram1.json` as a new workflow.
2. Update the Supabase nodes to use your credentials:
   - Either:
     - Open `telegram1.json` in a text editor and replace every
       `"id": "REPLACE_WITH_YOUR_SUPABASE_CREDENTIAL_ID"`
       with your actual credential ID, **or**
     - Inside n8n, open the **Fetch User Profile** and **Save User Profile** nodes and select your Supabase credential from the dropdown.
3. Configure the Telegram (or other trigger) node with your own bot/token or channel.

### 4. Activate and Test

1. **Activate** the workflow in n8n.
2. In your chat app, send a message like:
   - `I earn $3000 per month and spend $200 on groceries`
3. Later, ask:
   - `How much do I spend on groceries?`
4. The bot should recall your stored data and answer using your profile.

## Demo Video

_Placeholder – add your demo video link or embed here (e.g., YouTube or Loom walkthrough)._

## More Documentation & Troubleshooting

- **Quick overview**: `n8n mcp/My Workflows/QUICK_START.md`
- **Full setup & diagrams**: `USER_PROFILE_SETUP.md`, `USER_STORAGE_FLOW.md` (in `Extra Docs`)
- **Advanced features**: See the other markdown files in `Extra Docs` for savings tracking, budget overrides, receipt image handling, and deployment guides.

If the bot isn’t remembering data, double-check:

- **Supabase credentials** in n8n match your project.
- The **`user_profiles` table** was created successfully.
- The correct **credential ID** is set in the Supabase nodes.
- n8n **execution logs** for any workflow errors.


