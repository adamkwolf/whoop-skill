#!/bin/bash
# whoop-refresh.sh - Refresh WHOOP access token using refresh token
# Designed to be called by OpenClaw cron job

set -e

WHOOP_TOKEN_URL="https://api.prod.whoop.com/oauth/oauth2/token"

# Check required environment variables
if [ -z "$WHOOP_REFRESH_TOKEN" ]; then
    echo "Error: WHOOP_REFRESH_TOKEN not set"
    exit 1
fi

if [ -z "$WHOOP_CLIENT_ID" ]; then
    echo "Error: WHOOP_CLIENT_ID not set"
    exit 1
fi

if [ -z "$WHOOP_CLIENT_SECRET" ]; then
    echo "Error: WHOOP_CLIENT_SECRET not set"
    exit 1
fi

echo "Refreshing WHOOP access token..."

# Request new tokens
TOKEN_RESPONSE=$(curl -s -X POST "$WHOOP_TOKEN_URL" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$WHOOP_REFRESH_TOKEN" \
    -d "client_id=$WHOOP_CLIENT_ID" \
    -d "client_secret=$WHOOP_CLIENT_SECRET" \
    -d "scope=offline")

# Check for error
if echo "$TOKEN_RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    ERROR=$(echo "$TOKEN_RESPONSE" | jq -r '.error')
    DESC=$(echo "$TOKEN_RESPONSE" | jq -r '.error_description // "No description"')
    echo "Token refresh failed: $ERROR - $DESC"
    exit 1
fi

# Extract new tokens
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')
NEW_REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.refresh_token')
EXPIRES_IN=$(echo "$TOKEN_RESPONSE" | jq -r '.expires_in')

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
    echo "Error: No access token in response"
    exit 1
fi

# Output the new tokens as JSON (for OpenClaw to parse and update config)
echo ""
echo "=== NEW TOKENS ==="
echo "Access Token: $ACCESS_TOKEN"
echo ""
echo "Refresh Token: $NEW_REFRESH_TOKEN"
echo ""
echo "Expires In: ${EXPIRES_IN}s"
echo ""
echo "Update your OpenClaw config with the new WHOOP_ACCESS_TOKEN above."

# Also output as JSON for programmatic use
echo ""
echo "=== JSON ==="
echo "$TOKEN_RESPONSE" | jq '{access_token, refresh_token, expires_in}'
