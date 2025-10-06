const fs = require('fs');
const https = require('https');

// Read the workflow
const workflow = JSON.parse(fs.readFileSync('telegram1-deploy.json', 'utf8'));

// n8n API endpoint - you need to set your API key
const N8N_URL = 'https://n8n.srv1034150.hstgr.cloud';
const API_KEY = process.env.N8N_API_KEY || 'YOUR_API_KEY_HERE';

if (API_KEY === 'YOUR_API_KEY_HERE') {
  console.error('❌ Please set N8N_API_KEY environment variable');
  console.error('   Run: $env:N8N_API_KEY="your-key"');
  process.exit(1);
}

const postData = JSON.stringify(workflow);

const options = {
  hostname: 'n8n.srv1034150.hstgr.cloud',
  path: '/api/v1/workflows',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData),
    'X-N8N-API-KEY': API_KEY
  }
};

console.log('🚀 Deploying workflow to n8n...');
console.log(`📝 Workflow: ${workflow.name}`);
console.log(`📊 Nodes: ${workflow.nodes.length}`);

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    if (res.statusCode === 200 || res.statusCode === 201) {
      const result = JSON.parse(data);
      console.log('\n✅ Workflow deployed successfully!');
      console.log(`📋 Workflow ID: ${result.id}`);
      console.log(`🔗 URL: ${N8N_URL}/workflow/${result.id}`);
    } else {
      console.error(`\n❌ Deployment failed with status ${res.statusCode}`);
      console.error(data);
    }
  });
});

req.on('error', (error) => {
  console.error('\n❌ Error:', error.message);
});

req.write(postData);
req.end();
