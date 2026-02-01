# WHOOP Skill Setup Guide

## Prerequisites

- WHOOP account with active subscription
- `curl` and `jq` installed
- WHOOP developer app (for client ID/secret)

## Step 1: Get Your Tokens

### Using the WHOOP Dashboard App

1. Deploy or run the WHOOP dashboard app: https://github.com/adamkwolf/whoop-app
2. Click "Connect WHOOP" and authorize
3. On the dashboard, copy both:
   - **Access Token** (expires hourly)
   - **Refresh Token** (long-lived, for auto-refresh)

### Getting Client ID & Secret

1. Go to https://developer-dashboard.whoop.com
2. Sign in with your WHOOP account
3. Create or select an application
4. Copy your **Client ID** and **Client Secret**

## Step 2: Configure OpenClaw

Add all credentials to `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "entries": {
      "whoop": {
        "enabled": true,
        "env": {
          "WHOOP_ACCESS_TOKEN": "your-access-token",
          "WHOOP_REFRESH_TOKEN": "your-refresh-token",
          "WHOOP_CLIENT_ID": "your-client-id",
          "WHOOP_CLIENT_SECRET": "your-client-secret"
        }
      }
    }
  }
}
```

## Step 3: Test

```bash
# Test the API (OpenClaw will inject the env var)
~/.openclaw/skills/whoop/scripts/whoop-api.sh profile
```

You should see your profile JSON.

## Step 4: Set Up Auto-Refresh (Optional)

Access tokens expire hourly. Set up the cron job for automatic refresh:

```bash
openclaw cron add --name "WHOOP token refresh" \
  --cron "*/55 * * * *" \
  --session isolated \
  --message "Run ~/.openclaw/skills/whoop/scripts/whoop-refresh.sh and update BOTH WHOOP_ACCESS_TOKEN and WHOOP_REFRESH_TOKEN in ~/.openclaw/openclaw.json with the new tokens from the output. Both tokens rotate on each refresh." \
  --model anthropic/claude-haiku-4-5
```

Verify: `openclaw cron list | grep -i whoop`

**Note:** WHOOP rotates both tokens on each refresh. The cron job must update both to maintain the refresh cycle.

## Troubleshooting

**"WHOOP_ACCESS_TOKEN not set"**
- Check that `~/.openclaw/openclaw.json` has the token configured
- Verify the JSON syntax is valid

**401 Unauthorized**
- Token has expired - get a new one from the dashboard

**No data returned**
- Ensure your WHOOP device has synced recently
- Check that you requested the correct scopes when getting the token

## Revoking Access

To revoke your token:
1. Go to https://app.whoop.com/settings
2. Find "Connected Apps"
3. Revoke access for your application
