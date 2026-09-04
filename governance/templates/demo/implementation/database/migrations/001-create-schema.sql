CREATE TABLE IF NOT EXISTS demo_items (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('draft', 'review', 'approved', 'archived')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
