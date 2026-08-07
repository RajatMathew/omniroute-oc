# OmniRoute Setup Skill

Use this skill when deploying or configuring OmniRoute for the first time.

## When to use
- After `docker compose up` on a new OmniRoute instance
- When user says "set up OmniRoute", "configure aliases", "connect Claude Code"

## Quick start

### 0. Choose profile
Ask user: **full** (with dashboard) or **base** (API-only, lighter)?

- **Full**: Remove `COMPOSE_PROFILES=base` from `.env` or set `COMPOSE_PROFILES=` empty
- **Base**: Keep `COMPOSE_PROFILES=base` (default)

Base has NO web UI — only accessible via API at `/v1`.

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

## Base compose profile

This stack uses `COMPOSE_PROFILES=base` for a lighter image.

**Base profile has NO web UI/dashboard.** API-only.

To get the dashboard, remove `COMPOSE_PROFILES=base` from `.env` or Dokploy env.

## Dokploy deployment

### Environment variables
```
COMPOSE_PROFILES=base
INITIAL_PASSWORD=<strong-password>
AUTH_COOKIE_SECURE=true
REQUIRE_API_KEY=true
NODE_ENV=production
```

### After deploy — set aliases
Run in Dokploy Docker terminal or SSH:
```bash
curl -s http://localhost:20138/api/auth/login -X POST -H "Content-Type: application/json" -d '{"password":"YOUR_PASSWORD"}' -c /tmp/oc.txt && curl -s http://localhost:20138/api/models/alias -b /tmp/oc.txt -H "Content-Type: application/json" -X PUT -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-sonnet-5"}' && curl -s http://localhost:20138/api/models/alias -b /tmp/oc.txt -H "Content-Type: application/json" -X PUT -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-opus-5"}' && curl -s http://localhost:20138/api/models/alias -b /tmp/oc.txt -H "Content-Type: application/json" -X PUT -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-opus-4-8"}' && curl -s http://localhost:20138/api/models/alias -b /tmp/oc.txt
```

## Manual setup (if script fails)

### 1. Login
```bash
curl -s http://localhost:20138/api/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"password":"YOUR_PASSWORD"}' \
  -c /tmp/oc.txt
```

### 2. Create aliases
```bash
curl -s http://localhost:20138/api/models/alias \
  -b /tmp/oc.txt \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-sonnet-5"}'

curl -s http://localhost:20138/api/models/alias \
  -b /tmp/oc.txt \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-opus-5"}'

curl -s http://localhost:20138/api/models/alias \
  -b /tmp/oc.txt \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{"model":"oc/deepseek-v4-flash-free","alias":"claude-opus-4-8"}'
```

### 3. Verify aliases
```bash
curl -s http://localhost:20138/api/models/alias -b /tmp/oc.txt
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

## Updating aliases

After deployment, edit `aliases.json` and run:

```bash
./scripts/update-aliases.sh
```

Flags (optional):
```bash
./scripts/update-aliases.sh --base-url http://localhost:20128 --password MyPassword
```

## Troubleshooting

### "Bad Gateway"
- Base profile has no UI — this is expected
- API still works at `/v1`
- To get dashboard, remove `COMPOSE_PROFILES=base`

### "Connection refused"
Wait 5-10 seconds after `docker compose up`. Check: `docker ps`

### "Login failed"
Verify password matches `.env` file. Check: `docker logs omniroute-oc`

### Aliases not working
Re-run setup script or use curl commands above.
