# Telegram Budget Guardian - Deployment Guide

Your workflow `telegram1.json` has been prepared for deployment to n8n.

## Files Created
- ✅ `telegram1-deploy.json` - Workflow ready for deployment (with node IDs added)
- ✅ `api-deploy.js` - Node.js deployment script
- ✅ `direct-deploy.ps1` - PowerShell deployment script

## Deployment Options

### Option 1: Manual Import via n8n UI (EASIEST)

1. Open your n8n instance: https://n8n.srv1034150.hstgr.cloud/
2. Click on **Workflows** in the left sidebar
3. Click the **"Import from File"** or **"+"** button
4. Select the file: `telegram1-deploy.json`
5. The workflow will be imported with all 31 nodes and connections

### Option 2: API Deployment with Node.js

1. Get your n8n API Key:
   - Open n8n: https://n8n.srv1034150.hstgr.cloud/
   - Go to Settings > API
   - Copy your API key

2. Set the API key:
   ```powershell
   $env:N8N_API_KEY = "your-api-key-here"
   ```

3. Run the deployment script:
   ```powershell
   cd "C:\Users\noura\Desktop\Fortnite\n8n mcp\My Workflows"
   node api-deploy.js
   ```

### Option 3: API Deployment with PowerShell

1. Set the API key (same as above)

2. Run the PowerShell script:
   ```powershell
   cd "C:\Users\noura\Desktop\Fortnite\n8n mcp\My Workflows"
   .\direct-deploy.ps1
   ```

## Workflow Details

- **Name**: Telegram Budget Guardian
- **Total Nodes**: 31
- **Node Types**:
  - Telegram Trigger
  - Voice message processing
  - OpenAI Whisper transcription
  - Multi-agent AI system (Planner, Financial Analyst, Data Retrieval, User Interaction)
  - HTTP requests for external APIs
  - Function nodes for data transformation

## Required Credentials

After importing, you'll need to configure these credentials in n8n:

1. **Telegram Bot** - For Telegram Trigger and message nodes
2. **OpenAI Header Auth** - For Whisper transcription and GPT-4 agents
3. **Convex Service Auth** (optional) - For spending data and FAQ vector search
4. **SerpAPI Key** (optional) - For retail price search

## Next Steps After Import

1. Configure all required credentials
2. Update placeholder URLs:
   - `https://your-convex-app.convex.cloud/api/spendings`
   - `https://your-convex-app.convex.cloud/api/faq/search`
3. Test the workflow with a Telegram voice message
4. Activate the workflow when ready

## Troubleshooting

- If nodes show errors, check that all credentials are properly configured
- If imports fail, ensure you're using `telegram1-deploy.json` (not `telegram1.json`)
- For API deployment issues, verify your API key is correct

## Support

Your n8n instance: https://n8n.srv1034150.hstgr.cloud/
