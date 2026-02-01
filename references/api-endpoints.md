# WHOOP API v2 Endpoints

Base URL: `https://api.prod.whoop.com/developer`

## Authentication

All requests require OAuth2 Bearer token:
```
Authorization: Bearer {access_token}
```

## User Endpoints

### GET /v2/user/profile/basic
**Scope:** `read:profile`

Returns basic user profile information.

**Response:**
```json
{
  "user_id": 12345,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe"
}
```

### GET /v2/user/measurement/body
**Scope:** `read:body_measurement`

Returns user's body measurements.

**Response:**
```json
{
  "height_meter": 1.83,
  "weight_kilogram": 81.6,
  "max_heart_rate": 195
}
```

## Recovery Endpoints

### GET /v2/recovery
**Scope:** `read:recovery`

Returns paginated recovery records.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| start | string | ISO 8601 datetime for range start |
| end | string | ISO 8601 datetime for range end |
| limit | integer | Max records (1-25, default: 25) |
| nextToken | string | Pagination token |

**Response:**
```json
{
  "records": [{
    "cycle_id": "uuid",
    "sleep_id": "uuid",
    "user_id": 12345,
    "created_at": "2024-01-15T08:00:00.000Z",
    "updated_at": "2024-01-15T08:00:00.000Z",
    "score_state": "SCORED",
    "score": {
      "user_calibrating": false,
      "recovery_score": 67,
      "resting_heart_rate": 52,
      "hrv_rmssd_milli": 45.2,
      "spo2_percentage": 97.5,
      "skin_temp_celsius": 33.2
    }
  }],
  "next_token": "..."
}
```

### GET /v2/cycle/{cycleId}/recovery
**Scope:** `read:recovery`

Returns recovery for a specific cycle.

## Sleep Endpoints

### GET /v2/activity/sleep
**Scope:** `read:sleep`

Returns paginated sleep records.

**Query Parameters:** Same as recovery endpoint.

**Response:**
```json
{
  "records": [{
    "id": "uuid",
    "user_id": 12345,
    "created_at": "2024-01-15T06:45:00.000Z",
    "updated_at": "2024-01-15T06:45:00.000Z",
    "start": "2024-01-14T22:30:00.000Z",
    "end": "2024-01-15T06:45:00.000Z",
    "timezone_offset": "-05:00",
    "nap": false,
    "score_state": "SCORED",
    "score": {
      "stage_summary": {
        "total_in_bed_time_milli": 29700000,
        "total_awake_time_milli": 1800000,
        "total_light_sleep_time_milli": 12600000,
        "total_slow_wave_sleep_time_milli": 7200000,
        "total_rem_sleep_time_milli": 8100000,
        "sleep_cycle_count": 4,
        "disturbance_count": 3
      },
      "sleep_needed": {
        "baseline_milli": 28080000,
        "need_from_sleep_debt_milli": 3600000,
        "need_from_recent_strain_milli": 1800000,
        "need_from_recent_nap_milli": 0
      },
      "respiratory_rate": 14.5,
      "sleep_performance_percentage": 85,
      "sleep_consistency_percentage": 78,
      "sleep_efficiency_percentage": 94
    }
  }],
  "next_token": "..."
}
```

### GET /v2/activity/sleep/{sleepId}
**Scope:** `read:sleep`

Returns a specific sleep record.

### GET /v2/cycle/{cycleId}/sleep
**Scope:** `read:sleep`

Returns sleep associated with a specific cycle.

## Workout Endpoints

### GET /v2/activity/workout
**Scope:** `read:workout`

Returns paginated workout records.

**Query Parameters:** Same as recovery endpoint.

**Response:**
```json
{
  "records": [{
    "id": "uuid",
    "user_id": 12345,
    "created_at": "2024-01-15T18:30:00.000Z",
    "updated_at": "2024-01-15T19:00:00.000Z",
    "start": "2024-01-15T17:00:00.000Z",
    "end": "2024-01-15T18:15:00.000Z",
    "timezone_offset": "-05:00",
    "sport_id": 1,
    "score_state": "SCORED",
    "score": {
      "strain": 12.5,
      "average_heart_rate": 145,
      "max_heart_rate": 178,
      "kilojoule": 1850.5,
      "percent_recorded": 98.5,
      "distance_meter": 8500.0,
      "altitude_gain_meter": 45.0,
      "altitude_change_meter": 10.0,
      "zone_duration": {
        "zone_zero_milli": 60000,
        "zone_one_milli": 300000,
        "zone_two_milli": 900000,
        "zone_three_milli": 1200000,
        "zone_four_milli": 900000,
        "zone_five_milli": 300000
      }
    }
  }],
  "next_token": "..."
}
```

### GET /v2/activity/workout/{workoutId}
**Scope:** `read:workout`

Returns a specific workout record.

## Cycle Endpoints

### GET /v2/cycle
**Scope:** `read:cycles`

Returns paginated physiological cycle records.

**Query Parameters:** Same as recovery endpoint.

**Response:**
```json
{
  "records": [{
    "id": "uuid",
    "user_id": 12345,
    "created_at": "2024-01-15T06:00:00.000Z",
    "updated_at": "2024-01-15T22:00:00.000Z",
    "start": "2024-01-15T06:00:00.000Z",
    "end": "2024-01-16T06:00:00.000Z",
    "timezone_offset": "-05:00",
    "score_state": "SCORED",
    "score": {
      "strain": 14.2,
      "kilojoule": 2850.5,
      "average_heart_rate": 68,
      "max_heart_rate": 178
    }
  }],
  "next_token": "..."
}
```

### GET /v2/cycle/{cycleId}
**Scope:** `read:cycles`

Returns a specific cycle record.

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 204 | Success (no content) |
| 400 | Bad request |
| 401 | Unauthorized (invalid/expired token) |
| 404 | Not found |
| 429 | Rate limit exceeded |
| 500 | Server error |

## Pagination

Collection endpoints return max 25 records per request. Use `next_token` from response in subsequent requests:

```bash
# First request
/v2/recovery?limit=25

# Next page
/v2/recovery?limit=25&nextToken=abc123
```
