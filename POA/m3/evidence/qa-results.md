# SoloQ M3 — Quality Attribute Evidence Log

**Status:** Experiments are prepared; results must be recorded after running against the Docker deployment. No measurements are fabricated.

## Environment record
- Date/time:
- Host OS / CPU / RAM:
- Docker version:
- API / PostgreSQL image versions:
- Dataset size (departments / slots / appointments):

## QA-1 — Availability query performance
- M1 response measure: 95% of availability requests complete within 500 ms.
- Command: `k6 run tests/availability.js`
- VUs / duration: 200 / 60 seconds.
- Requests:
- p50:
- p95:
- p99:
- Error rate:
- Met / not met:
- Interpretation and limitations:

## QA-4 — Concurrent booking consistency
- M1 response measure: exactly one successful booking for a slot under 100 concurrent attempts.
- Command: `STUDENT_TOKEN=... SLOT_ID=... k6 run tests/booking-race.js`
- HTTP 201 count:
- HTTP 409 count:
- Other responses:
- Active appointment rows for tested slot:
- Met / not met:
- Interpretation and limitations:

## QA-2 — Authorization checks (additional)
| Test | Expected | Actual |
|---|---|---|
| Student calls staff-only create-slot endpoint | 403 | |
| Student calls department appointments endpoint | 403 | |
| Student cancels another student's appointment | 404 | |
