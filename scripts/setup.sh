#!/bin/bash
set -e

BASE_URL="${1:-http://localhost:20138}"
PASSWORD="${2:-TestPassword123!}"
API_KEY="${3:-wqqx40CQxJL3hrLjraQ9LYUfMiz1SrxZHyhHARid}"

echo "=== OmniRoute Setup ==="
echo "Target: $BASE_URL"

# Wait for OmniRoute to be ready
echo -n "Waiting for OmniRoute..."
until curl -s "$BASE_URL/" > /dev/null 2>&1; do
  sleep 1
  echo -n "."
done
echo " ready"

# Login and get auth token
AUTH_TOKEN=$(curl -s "$BASE_URL/api/auth/login" \
  -X POST \
  -H "Content-Type: application/json" \
  -d "{\"password\":\"$PASSWORD\"}" \
  -c - | grep auth_token | awk '{print $NF}')

if [ -z "$AUTH_TOKEN" ]; then
  echo "ERROR: Login failed"
  exit 1
fi
echo "Logged in"

# Create model aliases
create_alias() {
  local ALIAS=$1
  local TARGET=$2
  curl -s "$BASE_URL/api/models/alias" \
    -H "Cookie: auth_token=$AUTH_TOKEN" \
    -H "Content-Type: application/json" \
    -X PUT \
    -d "{\"model\":\"$TARGET\",\"alias\":\"$ALIAS\"}" > /dev/null
  echo "  $ALIAS -> $TARGET"
}

echo "Creating aliases..."
create_alias "claude-sonnet-4-6" "oc/deepseek-v4-flash-free"
create_alias "claude-sonnet-5" "oc/deepseek-v4-flash-free"
create_alias "claude-opus-4-8" "oc/deepseek-v4-flash-free"

# Verify
echo ""
echo "=== Verification ==="
curl -s "$BASE_URL/api/models/alias" \
  -H "Cookie: auth_token=$AUTH_TOKEN" | python3 -m json.tool

echo ""
echo "=== Connection Details ==="
echo "Dashboard: $BASE_URL"
echo "API Base:  $BASE_URL/v1"
echo "Model:     claude-sonnet-4-6"
echo "API Key:   $API_KEY"
