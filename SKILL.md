# OmniRoute Setup Skill

Use this skill when deploying or configuring OmniRoute for the first time.

## When to use
- After `docker compose up` on a new OmniRoute instance
- When user says "set up OmniRoute", "configure aliases", "connect Claude Code"

## Quick start

### 1. Start containers
```bash
docker compose up -d
```

### 2. Run setup script
```bash
./scripts/setup.sh <BASE_URL> <PASSWORD>
```

Examples:
```bash
./scripts/setup.sh http://localhost:20128 Omniroute2026!
./scripts/setup.sh http://localhost:20138 TestPassword123!
./scripts/setup.sh https://omniroute-oc.cofount.com YourPassword
```

### 3. Verify
Script outputs alias mappings, dashboard URL, and API connection details.

### 4. Output connection details
After setup completes, ONLY output these lines (nothing else):

```
Dashboard: http://localhost:20138
API Base:  http://localhost:20138/v1
Model:     claude-sonnet-5
API Key:   wqqx40CQxJL3hrLjraQ9LYUfMiz1SrxZHyhHARid
```

Do NOT mention OpenCode containers, Redis, docker exec, or anything else.

## Manual setup (if script fails)

### 1. Get auth token
```bash
curl -s http://localhost:20128/api/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"password":"YOUR_PASSWORD"}' \
  -c - | grep auth_token | awk '{print $NF}'
```

### 2. Create aliases
```bash
# Replace $TOKEN with the auth token from step 1
curl -s http://localhost:20128/api/models/alias \
  -H "Cookie: auth_token=$TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-sonnet-4-6"}'

curl -s http://localhost:20128/api/models/alias \
  -H "Cookie: auth_token=$TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-sonnet-5"}'

curl -s http://localhost:20128/api/models/alias \
  -H "Cookie: auth_token=$TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-opus-4-8"}'
```

### 3. Verify aliases
```bash
curl -s http://localhost:20128/api/models/alias \
  -H "Cookie: auth_token=$TOKEN"
```

## Claude Code connection

```
ANTHROPIC_BASE_URL=http://localhost:20138/v1
ANTHROPIC_API_KEY=wqqx40CQxJL3hrLjraQ9LYUfMiz1SrxZHyhHARid
```

Or:
```
claude --model claude-sonnet-5
```

## Default aliases
| Alias | Target | Context |
|-------|--------|---------|
| claude-sonnet-5 | oc/deepseek-v4-flash-free | 1M |
| claude-opus-5 | oc/deepseek-v4-flash-free | 1M |
| claude-opus-4-8 | oc/deepseek-v4-flash-free | 1M |

## Ports
- 20128/20129: Production
- 20138/20139: Test

## Teardown
```bash
docker compose down
```

## Troubleshooting

### "Connection refused"
Wait 5-10 seconds after `docker compose up`. Check: `docker ps`

### "Login failed"
Verify password matches `.env` file. Check: `docker logs omniroute-oc`

### Aliases not working
Re-run setup script.
