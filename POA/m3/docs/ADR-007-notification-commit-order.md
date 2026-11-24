# ADR-007 — Send booking notification after database commit

- **Status:** Accepted for prototype
- **Date / decider:** 19 November 2026 — Ahmed Adel
- **Context:** The booking must remain consistent even if the external SMTP provider is unavailable. A notification failure should not undo an appointment already accepted by the database.
- **Alternatives considered:**
  - Send email before commit. Positive: email is sent only after initial validation. Negative: provider delay/failure can block the transaction and create misleading behavior if commit later fails.
  - Send email after commit and handle failure separately. Positive: appointment integrity is independent of SMTP availability. Negative: delivery can fail after a successful booking; retry/outbox support is future work.
- **Decision:** Commit the appointment first, then attempt notification through the notification adapter. Log delivery failure and keep the appointment.
- **Rationale:** Protects QA-4 consistency and keeps the external provider outside the database transaction.
- **Consequences:** Positive: SMTP failure does not roll back a booking. Negative: notification retry is not implemented in this prototype.
