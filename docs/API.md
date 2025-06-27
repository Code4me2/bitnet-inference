# API Reference

BitNet server implements OpenAI-compatible endpoints plus additional features.

## Base URL
```
http://localhost:8081
```

## Endpoints

### Health Check
```http
GET /health
```

**Response:**
```json
{"status": "ok"}
```

### Chat Completions (OpenAI Compatible)
```http
POST /chat/completions
```

**Request:**
```json
{
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is BitNet?"}
  ],
  "temperature": 0.7,
  "max_tokens": 100,
  "stream": false
}
```

**Response:**
```json
{
  "choices": [{
    "message": {
      "role": "assistant",
      "content": "BitNet is a 1-bit Large Language Model..."
    },
    "finish_reason": "stop"
  }],
  "usage": {
    "prompt_tokens": 15,
    "completion_tokens": 25,
    "total_tokens": 40
  }
}
```

### Completions
```http
POST /completion
```

**Request:**
```json
{
  "prompt": "The capital of France is",
  "n_predict": 50,
  "temperature": 0.7,
  "top_k": 40,
  "top_p": 0.95
}
```

### Streaming

Add `"stream": true` to any request:

```bash
curl -X POST http://localhost:8081/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Count to 5"}],
    "stream": true
  }'
```

Returns Server-Sent Events (SSE):
```
data: {"choices":[{"delta":{"content":"1"}}]}
data: {"choices":[{"delta":{"content":"2"}}]}
...
data: [DONE]
```

## Parameters

### Common Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `temperature` | float | 0.8 | Randomness (0.0-2.0) |
| `max_tokens` | int | -1 | Max tokens to generate (-1 = unlimited) |
| `top_k` | int | 40 | Top-k sampling |
| `top_p` | float | 0.95 | Nucleus sampling |
| `repeat_penalty` | float | 1.1 | Penalty for repetition |
| `seed` | int | -1 | Random seed for reproducibility |

### Advanced Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `n_ctx` | int | 2048 | Context window size |
| `n_batch` | int | 512 | Batch size for processing |
| `n_threads` | int | auto | Override thread count |
| `stop` | array | [] | Stop sequences |
| `presence_penalty` | float | 0.0 | Presence penalty |
| `frequency_penalty` | float | 0.0 | Frequency penalty |

## Examples

### Python
```python
import requests

response = requests.post(
    "http://localhost:8081/chat/completions",
    json={
        "messages": [{"role": "user", "content": "Hello!"}],
        "max_tokens": 50
    }
)
print(response.json()["choices"][0]["message"]["content"])
```

### JavaScript
```javascript
const response = await fetch('http://localhost:8081/chat/completions', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    messages: [{role: 'user', content: 'Hello!'}],
    max_tokens: 50
  })
});
const data = await response.json();
console.log(data.choices[0].message.content);
```

### Streaming with Python
```python
import requests
import json

response = requests.post(
    "http://localhost:8081/chat/completions",
    json={"messages": [{"role": "user", "content": "Hello!"}], "stream": True},
    stream=True
)

for line in response.iter_lines():
    if line and line.startswith(b'data: '):
        data = line[6:]
        if data != b'[DONE]':
            chunk = json.loads(data)
            print(chunk['choices'][0]['delta'].get('content', ''), end='')
```

## Error Handling

### Common Status Codes
- `200 OK` - Success
- `400 Bad Request` - Invalid parameters
- `500 Internal Server Error` - Server error
- `503 Service Unavailable` - Model not loaded

### Error Response Format
```json
{
  "error": {
    "message": "Invalid temperature value",
    "type": "invalid_request_error",
    "code": "invalid_parameter"
  }
}
```

## Rate Limiting

No built-in rate limiting. Implement at proxy/application level if needed.

## Authentication

No built-in authentication. For production:
1. Use reverse proxy (nginx) with auth
2. Implement API keys at application level
3. Restrict network access