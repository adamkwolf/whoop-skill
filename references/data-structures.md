# WHOOP Data Structures

Reference for interpreting WHOOP API response data.

## Score States

All scored records include a `score_state` field:

| State | Description |
|-------|-------------|
| `SCORED` | Fully processed, score available |
| `PENDING_SCORE` | Processing in progress |
| `UNSCORABLE` | Cannot be scored (insufficient data) |

Only access `score` object when `score_state` is `SCORED`.

## Recovery Score

```json
{
  "user_calibrating": false,
  "recovery_score": 67,
  "resting_heart_rate": 52,
  "hrv_rmssd_milli": 45.2,
  "spo2_percentage": 97.5,
  "skin_temp_celsius": 33.2
}
```

| Field | Unit | Description |
|-------|------|-------------|
| `user_calibrating` | boolean | True during initial 4-day calibration |
| `recovery_score` | 0-100% | Overall recovery status |
| `resting_heart_rate` | bpm | Resting heart rate during sleep |
| `hrv_rmssd_milli` | milliseconds | Heart rate variability (RMSSD) |
| `spo2_percentage` | 0-100% | Blood oxygen saturation |
| `skin_temp_celsius` | celsius | Skin temperature during sleep |

### Recovery Score Zones

| Range | Zone | Meaning |
|-------|------|---------|
| 67-100% | Green | Well recovered, ready for high strain |
| 34-66% | Yellow | Moderate recovery, balance activity |
| 0-33% | Red | Low recovery, prioritize rest |

## Sleep Score

### Stage Summary
```json
{
  "total_in_bed_time_milli": 29700000,
  "total_awake_time_milli": 1800000,
  "total_light_sleep_time_milli": 12600000,
  "total_slow_wave_sleep_time_milli": 7200000,
  "total_rem_sleep_time_milli": 8100000,
  "sleep_cycle_count": 4,
  "disturbance_count": 3
}
```

All times in milliseconds. Convert: `ms / 1000 / 60` = minutes.

| Field | Description |
|-------|-------------|
| `total_in_bed_time_milli` | Total time in bed |
| `total_awake_time_milli` | Time awake while in bed |
| `total_light_sleep_time_milli` | Light sleep duration |
| `total_slow_wave_sleep_time_milli` | Deep/SWS sleep duration |
| `total_rem_sleep_time_milli` | REM sleep duration |
| `sleep_cycle_count` | Number of sleep cycles |
| `disturbance_count` | Number of disturbances |

### Sleep Need
```json
{
  "baseline_milli": 28080000,
  "need_from_sleep_debt_milli": 3600000,
  "need_from_recent_strain_milli": 1800000,
  "need_from_recent_nap_milli": 0
}
```

Total sleep need = baseline + debt + strain - naps

### Sleep Metrics

| Field | Description |
|-------|-------------|
| `respiratory_rate` | Breaths per minute during sleep |
| `sleep_performance_percentage` | Actual vs needed sleep (100% = optimal) |
| `sleep_consistency_percentage` | Sleep schedule regularity |
| `sleep_efficiency_percentage` | Time asleep vs time in bed |

## Strain Score

```json
{
  "strain": 14.2,
  "kilojoule": 2850.5,
  "average_heart_rate": 68,
  "max_heart_rate": 178
}
```

| Field | Unit | Description |
|-------|------|-------------|
| `strain` | 0-21 | Cardiovascular load score |
| `kilojoule` | kJ | Energy expenditure |
| `average_heart_rate` | bpm | Average heart rate |
| `max_heart_rate` | bpm | Maximum heart rate |

### Strain Scale

| Range | Level | Description |
|-------|-------|-------------|
| 0-9 | Light | Minimal cardiovascular stress |
| 10-13 | Moderate | Medium effort activities |
| 14-17 | High | Strenuous activity |
| 18-21 | All-out | Maximum effort |

## Workout Data

### Zone Duration
```json
{
  "zone_zero_milli": 60000,
  "zone_one_milli": 300000,
  "zone_two_milli": 900000,
  "zone_three_milli": 1200000,
  "zone_four_milli": 900000,
  "zone_five_milli": 300000
}
```

Heart rate zones based on max HR percentage:

| Zone | HR Range | Description |
|------|----------|-------------|
| 0 | <50% | Rest/recovery |
| 1 | 50-60% | Light activity |
| 2 | 60-70% | Moderate/aerobic |
| 3 | 70-80% | Aerobic/threshold |
| 4 | 80-90% | Threshold/anaerobic |
| 5 | 90-100% | Max effort |

### Sport IDs

Common sport IDs (partial list):

| ID | Sport |
|----|-------|
| 1 | Running |
| 0 | Activity (general) |
| 33 | Cycling |
| 44 | Swimming |
| 52 | Strength Training |
| 71 | HIIT |
| 63 | Yoga |

## Body Measurements

```json
{
  "height_meter": 1.83,
  "weight_kilogram": 81.6,
  "max_heart_rate": 195
}
```

| Field | Unit | Description |
|-------|------|-------------|
| `height_meter` | meters | User height |
| `weight_kilogram` | kg | User weight |
| `max_heart_rate` | bpm | Calculated max HR |

## Timestamps

All timestamps use ISO 8601 format with timezone offset:
```
2024-01-15T08:00:00.000Z
2024-01-15T03:00:00-05:00
```

The `timezone_offset` field indicates user's local timezone.

## Pagination

Collection responses include pagination:
```json
{
  "records": [...],
  "next_token": "eyJhbGciOiJIUzI1..."
}
```

- `next_token` is null/absent when no more pages
- Pass token to `nextToken` query parameter for next page
