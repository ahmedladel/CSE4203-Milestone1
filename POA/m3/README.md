# SoloQ — University Appointment & Student Services System (UASSS)

**CSE4203 · Milestone 3 — Architectural Prototype**  
**Student:** Ahmed Adel — 221004576  
**Instructor:** Dr. Nada Mahmoud Hassan · **TA:** Eng. Mohamed Fareh  
**Team:** SoloQ (individual submission approved by instructor)  
**Date:** 19 November 2026

## 1. Overview
SoloQ is a web application for university appointment scheduling. It has three roles: students, department staff and administrators. Students register/sign in, browse departments and open slots, book and cancel their own appointments, and receive a booking-confirmation notification. Staff can publish availability and review appointments for their department. The database enforces the no-double-booking rule.

## 2. Architecture
The prototype follows the M2 layered client–server design. React is served by Nginx; the browser calls a REST API implemented with Node.js and Express; PostgreSQL owns persistent users, departments, slots and appointments. Notification delivery is behind a separate service module and can use SMTP or the development console adapter.

| M2 component / responsibility | Code location |
|---|---|
| Web UI | `web/src/` |
| Web static hosting / reverse proxy | `web/nginx.conf`, `web/Dockerfile` |
| API entry point and REST routing | `api/src/app.js`, `api/src/server.js` |
| Authentication and JWT issuance | `api/src/modules/auth/`, `api/src/middleware/auth.js` |
| Department catalogue | `api/src/modules/departments/` |
| Slot availability and schedule management | `api/src/modules/slots/` |
| Booking, cancellation and staff appointment view | `api/src/modules/appointments/` |
| Email adapter | `api/src/modules/notifications/` |
| Persistent data model and integrity constraints | `db/init.sql` |

### Architecture erosion prevention
- HTTP requests enter through `app.js`; route modules own their feature endpoints.
- Role checks are applied in API middleware, not only in the browser.
- Notification-provider details stay in `notification.service.js`; appointment routes call its interface.
- SQL schema and integrity rules are versioned in `db/init.sql`.
- Unit tests protect the booking-conflict mapping; integration tests exercise PostgreSQL's unique constraint.
- Avoid importing route modules from other feature modules. Shared cross-cutting behavior belongs in `middleware/` or `config/`.

## 3. Requirements implemented
| M1 requirement | Prototype implementation |
|---|---|
| FR1 sign in | Student registration and JWT login; staff/admin can sign in after demo account seeding |
| FR2 view departments and available slots | `GET /api/departments`, `GET /api/slots` |
| FR3 book an available slot | `POST /api/appointments` |
| FR4 cancel own appointment | `PATCH /api/appointments/:id/cancel`, constrained by student ID |
| FR5 booking email confirmation | SMTP adapter; console fallback if SMTP is not configured |
| FR6 staff view department appointments | `GET /api/appointments/department` with staff department scope |
| FR7 create/update availability | `POST /api/slots` and `PATCH /api/slots/:id` (create/update) |
| FR8 prevent duplicate active bookings | PostgreSQL partial unique index and transaction; API returns HTTP 409 |



## 4. Run locally
Requires Docker Desktop / Docker Engine with Compose.

```bash
cp .env.example .env
docker compose up --build
```

Open the UI at `http://localhost:8080`; API health is `http://localhost:4000/health`.

Register a student from the UI. To create demo staff and administrator accounts, run in another terminal:

```bash
docker compose exec api node src/seed-demo.js
```

Demo accounts (password: `SoloQ-Demo-2026`):
- Staff: `staff@soloq.local`
- Administrator: `admin@soloq.local`

The seed command is safe to re-run; existing email accounts are not overwritten. Change demo credentials before any public deployment. For real SMTP delivery, set `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, and `MAIL_FROM` in `.env`, then restart the API. Without SMTP, a confirmation attempt is written to the API log and the booking still commits.

## 5. Tests
API unit tests:

```bash
docker compose exec api npm test
```

Database integration test (requires a reachable test database initialized with `db/init.sql`):

```bash
cd api
TEST_DATABASE_URL='postgres://soloq:soloq_dev_password@localhost:5432/soloq' npm run test:integration
```

The integration test is skipped if `TEST_DATABASE_URL` is not set. It creates temporary rows and checks that PostgreSQL rejects a second active appointment for one slot.

## 6. Quality attribute experiments
The M1 response measures remain targets, not assumed results:
- **QA-1 Performance:** 95% of availability requests complete within 500 ms. Run `k6 run tests/availability.js` with k6 installed and the stack running. The script uses 200 virtual users for 60 seconds and enforces a p95 threshold of 500 ms.
- **QA-4 Consistency:** exactly one successful booking in 100 concurrent attempts for one slot. Create a test slot, sign in as a student, then run `STUDENT_TOKEN=... SLOT_ID=... k6 run tests/booking-race.js`. Expected status distribution: one HTTP 201 and the remaining requests HTTP 409. Repeat with a fresh slot for another run.
- **QA-2 Security:** verify student token cannot call staff-only slot creation or department appointment routes (403), and a student cannot cancel another student's appointment (404). Record actual responses in `evidence/qa-results.md`.

No measured performance or concurrency values are claimed in this repository until the commands are run against the Docker deployment. Save the k6 summary and environment details in `evidence/` for the final submission.

## 7. API summary
- `POST /api/auth/register` — student registration
- `POST /api/auth/login` — sign in
- `GET /api/departments` — department list
- `GET /api/slots?departmentId=1` — open future slots
- `POST /api/slots` — staff/admin create slot
- `PATCH /api/slots/:id` — staff/admin update slot or close availability
- `POST /api/appointments` — student book slot
- `GET /api/appointments/mine` — student's appointments
- `PATCH /api/appointments/:id/cancel` — cancel own booking
- `GET /api/appointments/department` — staff/admin appointment list

## 8. Design changes since M2
The high-level architecture and technology stack are unchanged. The prototype makes two implementation details explicit: (1) notification delivery is attempted after the booking transaction commits, so an SMTP outage does not roll back a valid appointment; (2) a development console adapter is used when SMTP settings are absent. These clarify the M2 notification adapter decision rather than replace the architecture. The staff availability endpoint currently supports creation only; edit support is recorded as remaining work, not a design change.

## 9. Repository layout
```text
api/        Express API, modules, middleware and tests
web/        React frontend and Nginx configuration
db/         PostgreSQL schema, indexes and seed data
tests/      k6 performance and booking-race scripts
evidence/   measured experiment outputs (to be filled after execution)
diagrams/   M2 architecture diagrams and editable PlantUML sources
docs/       milestone notes and supporting documentation
```
