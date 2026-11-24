CREATE TABLE IF NOT EXISTS departments (
  id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('STUDENT','STAFF','ADMIN')),
  department_id INTEGER REFERENCES departments(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS slots (
  id SERIAL PRIMARY KEY,
  department_id INTEGER NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
  staff_id INTEGER NOT NULL REFERENCES users(id),
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  is_open BOOLEAN NOT NULL DEFAULT TRUE,
  CHECK (ends_at > starts_at)
);
CREATE INDEX IF NOT EXISTS idx_slots_department_time ON slots(department_id, starts_at) WHERE is_open = TRUE;
CREATE TABLE IF NOT EXISTS appointments (
  id SERIAL PRIMARY KEY,
  slot_id INTEGER NOT NULL REFERENCES slots(id),
  student_id INTEGER NOT NULL REFERENCES users(id),
  status VARCHAR(20) NOT NULL DEFAULT 'BOOKED' CHECK (status IN ('BOOKED','CANCELLED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  cancelled_at TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_one_active_appointment_per_slot
  ON appointments(slot_id) WHERE status = 'BOOKED';
CREATE INDEX IF NOT EXISTS idx_appointments_student ON appointments(student_id, status);
CREATE INDEX IF NOT EXISTS idx_appointments_slot ON appointments(slot_id);
INSERT INTO departments(name) VALUES ('Student Affairs'), ('Registration'), ('IT Services') ON CONFLICT DO NOTHING;
