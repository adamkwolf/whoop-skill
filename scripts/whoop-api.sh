#!/bin/bash
# whoop-api.sh - WHOOP API Request Helper
# Makes authenticated requests to WHOOP API

set -e

WHOOP_BASE_URL="https://api.prod.whoop.com/developer"

# Check for token
if [ -z "$WHOOP_ACCESS_TOKEN" ]; then
    cat >&2 << 'EOF'
Error: WHOOP_ACCESS_TOKEN not set.

To configure:
1. Get an access token from https://developer-dashboard.whoop.com
2. Add to ~/.openclaw/openclaw.json:

{
  "skills": {
    "entries": {
      "whoop": {
        "enabled": true,
        "env": {
          "WHOOP_ACCESS_TOKEN": "your-token-here"
        }
      }
    }
  }
}

See the setup guide for details.
EOF
    exit 1
fi

# Make API request
whoop_request() {
    local endpoint="$1"
    local params="$2"

    # Build URL
    local url="${WHOOP_BASE_URL}${endpoint}"
    if [ -n "$params" ]; then
        url="${url}?${params}"
    fi

    # Make request and capture both body and status code
    local response
    local http_code
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer $WHOOP_ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "$url")

    http_code=$(echo "$response" | tail -1)
    local body
    body=$(echo "$response" | sed '$d')

    # Handle errors
    if [ "$http_code" = "401" ]; then
        echo '{"error": "Unauthorized - token may be expired. Get a new token from the WHOOP developer dashboard.", "http_status": 401}'
        return 1
    fi

    if [ "$http_code" -ge 400 ]; then
        echo "$body" | jq -c '. + {"http_status": '"$http_code"'}' 2>/dev/null || \
            echo '{"error": "Request failed", "http_status": '"$http_code"', "body": "'"$body"'"}'
        return 1
    fi

    # Return formatted JSON
    echo "$body" | jq '.'
}

# Parse date arguments
parse_args() {
    local start=""
    local end=""
    local limit=""
    local next_token=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --start|-s)
                start="$2"
                shift 2
                ;;
            --end|-e)
                end="$2"
                shift 2
                ;;
            --limit|-l)
                limit="$2"
                shift 2
                ;;
            --next|--token)
                next_token="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Build query string
    local params=""
    [ -n "$start" ] && params="${params}start=${start}T00:00:00.000Z&"
    [ -n "$end" ] && params="${params}end=${end}T23:59:59.999Z&"
    [ -n "$limit" ] && params="${params}limit=${limit}&"
    [ -n "$next_token" ] && params="${params}nextToken=${next_token}&"

    # Remove trailing &
    echo "${params%&}"
}

# Show usage
usage() {
    cat << EOF
Usage: whoop-api.sh <command> [options]

Commands:
  profile         Get user profile
  body            Get body measurements
  recovery        Get recovery data
  sleep           Get sleep data
  workouts        Get workout data
  cycles          Get physiological cycles
  raw <endpoint>  Make raw API request to endpoint

Options for data commands:
  --start, -s DATE    Start date (YYYY-MM-DD)
  --end, -e DATE      End date (YYYY-MM-DD)
  --limit, -l N       Max records to return (default: 25)
  --next TOKEN        Pagination token for next page

Examples:
  whoop-api.sh profile
  whoop-api.sh recovery --start 2024-01-01 --end 2024-01-07
  whoop-api.sh sleep --limit 10
  whoop-api.sh raw /v2/user/profile/basic
EOF
}

# Main command handler
main() {
    local command="${1:-}"
    shift || true

    case "$command" in
        profile)
            whoop_request "/v2/user/profile/basic"
            ;;
        body)
            whoop_request "/v2/user/measurement/body"
            ;;
        recovery)
            local params
            params=$(parse_args "$@")
            whoop_request "/v2/recovery" "$params"
            ;;
        sleep)
            local params
            params=$(parse_args "$@")
            whoop_request "/v2/activity/sleep" "$params"
            ;;
        workouts)
            local params
            params=$(parse_args "$@")
            whoop_request "/v2/activity/workout" "$params"
            ;;
        cycles)
            local params
            params=$(parse_args "$@")
            whoop_request "/v2/cycle" "$params"
            ;;
        raw)
            local endpoint="${1:-}"
            shift || true
            local params
            params=$(parse_args "$@")
            if [ -z "$endpoint" ]; then
                echo "Error: Endpoint required for raw command"
                exit 1
            fi
            whoop_request "$endpoint" "$params"
            ;;
        help|--help|-h)
            usage
            ;;
        "")
            usage
            exit 1
            ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
