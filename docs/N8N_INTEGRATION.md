# N8N Integration Guide

Connect BitNet inference server with N8N workflows for AI-powered automation.

## Setup

### 1. Network Configuration

#### Docker Compose (Recommended)
Add to your `docker-compose.yml`:

```yaml
services:
  bitnet:
    image: bitnet-inference:latest
    ports:
      - "8081:8081"
    networks:
      - n8n-network
    environment:
      - BITNET_KERNEL=i2_s
      - OMP_NUM_THREADS=8

  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    networks:
      - n8n-network
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=password

networks:
  n8n-network:
    driver: bridge
```

#### Standalone Setup
- BitNet server: `http://localhost:8081`
- N8N: `http://localhost:5678`

### 2. N8N HTTP Request Node

Configure HTTP Request node in N8N:

**Settings:**
- Method: POST
- URL: `http://bitnet:8081/chat/completions` (Docker) or `http://localhost:8081/chat/completions`
- Headers:
  - Content-Type: `application/json`
- Body (JSON):
```json
{
  "messages": [
    {"role": "user", "content": "{{$json.prompt}}"}
  ],
  "max_tokens": 100,
  "temperature": 0.7
}
```

### 3. Custom BitNet Node

Install the custom node from [N8N BitNet Repository](https://github.com/Code4me2/data-compose):

```bash
# In your n8n custom nodes directory
npm install n8n-nodes-bitnet
```

## Example Workflows

### Simple Chat Workflow
```json
{
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "path": "chat",
        "method": "POST"
      }
    },
    {
      "name": "BitNet Chat",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "http://bitnet:8081/chat/completions",
        "jsonBody": {
          "messages": [{"role": "user", "content": "={{$json.message}}"}],
          "max_tokens": 100
        }
      }
    }
  ]
}
```

### Text Processing Pipeline
1. **Trigger**: Webhook/Cron/Email
2. **BitNet**: Process/summarize/analyze text
3. **Action**: Send to Slack/Email/Database

### Advanced Use Cases

#### Document Summarization
```javascript
// Function node to prepare request
const documents = items.map(item => ({
  messages: [{
    role: "system",
    content: "Summarize the following document in 3 bullet points"
  }, {
    role: "user",
    content: item.json.document
  }],
  max_tokens: 150
}));

return documents;
```

#### Sentiment Analysis
```javascript
// Analyze customer feedback
const prompt = `Analyze sentiment: "${$json.feedback}"
Return: positive, negative, or neutral`;

return [{
  json: {
    messages: [{role: "user", content: prompt}],
    max_tokens: 10,
    temperature: 0.1
  }
}];
```

## Best Practices

### 1. Error Handling
Add IF node to check BitNet response:
```javascript
// Check for errors
if ($json.error) {
  throw new Error($json.error.message);
}
return items;
```

### 2. Rate Limiting
Use Wait node between requests:
- Wait: 100ms between requests
- Batch: Process in groups of 10

### 3. Response Parsing
Extract content from response:
```javascript
// Extract assistant message
const content = $json.choices[0].message.content;
return [{json: {response: content}}];
```

### 4. Streaming Responses
For long responses, use streaming:
```javascript
// In HTTP Request node
{
  "stream": true,
  "messages": [{"role": "user", "content": "{{$json.prompt}}"}]
}
```

## Common Patterns

### 1. Email Assistant
Webhook → Read Email → BitNet (draft response) → Review → Send

### 2. Content Generator
Schedule → BitNet (generate) → Format → Publish

### 3. Data Enrichment
Database → BitNet (analyze) → Update Records

### 4. Chatbot
Webhook → Context → BitNet → Response

## Troubleshooting

### Connection Issues
- Check network connectivity between containers
- Verify BitNet health: `curl http://bitnet:8081/health`
- Check N8N logs: `docker logs n8n`

### Performance
- Adjust `max_tokens` for faster responses
- Use appropriate `temperature` (lower = more deterministic)
- Implement caching for repeated queries

### Integration Tips
- Store system prompts in N8N variables
- Use Set node to format data before BitNet
- Implement retry logic with Error Trigger node

## Resources
- [N8N Documentation](https://docs.n8n.io)
- [BitNet Custom Node](https://github.com/Code4me2/data-compose)
- [Example Workflows](https://github.com/Code4me2/bitnet-inference/tree/main/examples/n8n)