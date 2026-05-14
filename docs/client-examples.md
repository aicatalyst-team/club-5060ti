# Client Examples

Both vLLM and llama.cpp can expose an OpenAI-compatible API. Adjust the base URL and model name for your server.

## curl

~~~bash
curl -s http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen36-27b-nvfp4-mtp",
    "messages": [{"role": "user", "content": "Say 5060 Ti ready."}],
    "temperature": 0,
    "max_tokens": 128
  }'
~~~

## Python

~~~python
from openai import OpenAI

client = OpenAI(base_url="http://127.0.0.1:8000/v1", api_key="not-used")

response = client.chat.completions.create(
    model="qwen36-27b-nvfp4-mtp",
    messages=[{"role": "user", "content": "Say 5060 Ti ready."}],
    temperature=0,
    max_tokens=128,
)

print(response.choices[0].message.content)
~~~

## Open WebUI

Use an OpenAI-compatible connection:

- API base URL: http://your-host:8000/v1
- API key: any placeholder if your server does not enforce auth
- Model: qwen36-27b-nvfp4-mtp or your served model name

## Coding Agents

For coding agents and tools, start with conservative output budgets. Qwen thinking/reasoning can consume the full generation limit before returning final content.

Good starting points:

- no thinking: 1024 max tokens
- light coding help: 4096 max tokens
- harder reasoning: 8192+ max tokens

If your client supports extra request body fields for vLLM/Qwen, no-thinking mode is usually:

~~~json
{
  "chat_template_kwargs": {
    "enable_thinking": false
  }
}
~~~
