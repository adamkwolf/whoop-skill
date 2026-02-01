# WHOOP Skill Setup Guide

## Prerequisites

- WHOOP account with active subscription
- `curl` and `jq` installed

## Step 1: Get a WHOOP Access Token

### Option A: WHOOP Developer Dashboard (Recommended)

1. Go to https://developer-dashboard.whoop.com
2. Sign in with your WHOOP account
3. Create or select an application
4. Use the OAuth playground or token generator to get an access token
5. Request these scopes:
   - `read:recovery`
   - `read:cycles`
   - `read:workout`
   - `read:sleep`
   - `read:profile`
   - `read:body_measurement`

### Option B: OAuth Flow (Advanced)

If you need to run the full OAuth flow:

1. Register an app at https://developer-dashboard.whoop.com
2. Set redirect URI to your callback endpoint
3. Direct user to:
   ```
   https://api.prod.whoop.com/oauth/oauth2/auth?
     client_id=YOUR_CLIENT_ID&
     redirect_uri=YOUR_REDIRECT_URI&
     response_type=code&
     scope=read:recovery%20read:cycles%20read:workout%20read:sleep%20read:profile%20read:body_measurement
   ```
4. Exchange the returned code for tokens:
   ```bash
   curl -X POST https://api.prod.whoop.com/oauth/oauth2/token \
     -d "grant_type=authorization_code" \
     -d "code=AUTH_CODE" \
     -d "client_id=YOUR_CLIENT_ID" \
     -d "client_secret=YOUR_CLIENT_SECRET" \
     -d "redirect_uri=YOUR_REDIRECT_URI"
   ```

## Step 2: Configure OpenClaw

Add your token to `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "entries": {
      "whoop": {
        "enabled": true,
        "env": {
          "WHOOP_ACCESS_TOKEN": "your-access-token-here"
        }
      }
    }
  }
}
```

If the file doesn't exist, create it. If it exists, merge the whoop entry into the existing structure.

## Step 3: Test

```bash
# Set token for testing
export WHOOP_ACCESS_TOKEN="your-token"

# Test the API
~/.openclaw/skills/whoop/scripts/whoop-api.sh profile
```

You should see your profile JSON.

## Token Expiration

WHOOP access tokens expire after ~1 hour. When you get a 401 error:

1. Get a new token from the developer dashboard
2. Update `~/.openclaw/openclaw.json` with the new token

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
