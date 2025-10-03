# PowerShell script to deploy workflow to n8n
$workflowJson = Get-Content -Path "telegram1-deploy.json" -Raw
$n8nUrl = "https://n8n.srv1034150.hstgr.cloud/api/v1/workflows"

# Get n8n API key from environment or prompt
$apiKey = $env:N8N_API_KEY
if (-not $apiKey) {
    Write-Host "N8N_API_KEY environment variable not set"
    Write-Host "Please set it first using: `$env:N8N_API_KEY='your-api-key'"
    exit 1
}

$headers = @{
    "X-N8N-API-KEY" = $apiKey
    "Content-Type" = "application/json"
}

Write-Host "Deploying workflow to n8n..."
Write-Host "URL: $n8nUrl"

try {
    $response = Invoke-RestMethod -Uri $n8nUrl -Method Post -Headers $headers -Body $workflowJson
    Write-Host "`n✅ Workflow deployed successfully!"
    Write-Host "Workflow ID: $($response.id)"
    Write-Host "Workflow Name: $($response.name)"
} catch {
    Write-Host "`n❌ Deployment failed:"
    Write-Host $_.Exception.Message
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message
    }
}
