#!/bin/bash
set -e

# Defaults
BASE_URL="http://localhost:20138"
PASSWORD="TestPassword123!"
ALIASES_FILE="$(dirname "$0")/../aliases.json"

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --base-url) BASE_URL="$2"; shift 2 ;;
    --password) PASSWORD="$2"; shift 2 ;;
    --aliases) ALIASES_FILE="$2"; shift 2 ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

echo "=== Update Aliases ==="
echo "Target: $BASE_URL"

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

# Update aliases from JSON file
update_alias() {
  local ALIAS=$1
  local TARGET=$2
  curl -s "$BASE_URL/api/models/alias" \
    -H "Cookie: auth_token=$AUTH_TOKEN" \
    -H "Content-Type: application/json" \
    -X PUT \
    -d "{\"model\":\"$TARGET\",\"alias\":\"$ALIAS\"}" > /dev/null
  echo "  $ALIAS -> $TARGET"
}

echo "Updating aliases..."
if [ -f "$ALIASES_FILE" ]; then
  while IFS='=' read -r alias target; do
    [ -z "$alias" ] && continue
    [[ "$alias" =~ ^# ]] && continue
    update_alias "$alias" "$target"
  done < <(python3 -c "import json; [print(f'{k}={v}') for k,v in json.load(open('$ALIASES_FILE')).items()]")
else
  echo "ERROR: aliases.json not found at $ALIASES_FILE"
  exit 1
fi

# Verify
echo ""
echo "=== Current Aliases ==="
curl -s "$BASE_URL/api/models/alias" \
  -H "Cookie: auth_token=$AUTH_TOKEN" | python3 -m json.tool
