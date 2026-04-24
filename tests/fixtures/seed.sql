-- Synthetic fixtures for the sandbox. Never load on prod.
--
-- Schema reference: server/migrations/001_init.up.sql.
-- Table names are SINGULAR (workspace, "user", agent, issue) — NOT plural.
-- The sandbox Postgres is created fresh every run, so we don't need ON CONFLICT
-- guards for the primary key, but we keep them anyway to make the seed re-runnable
-- during ad-hoc iteration.
BEGIN;

-- A workspace the E2E tests can operate inside.
INSERT INTO workspace (id, name, slug, description)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'E2E Sandbox Workspace',
  'e2e-sandbox',
  'Synthetic workspace used by the Oxflow sandbox harness'
)
ON CONFLICT (id) DO NOTHING;

-- A test user so we have something to authenticate as / assign issues to.
-- "user" is quoted because it's a reserved word in SQL.
INSERT INTO "user" (id, name, email)
VALUES (
  '00000000-0000-0000-0000-000000000101',
  'Sandbox Tester',
  'sandbox-tester@example.test'
)
ON CONFLICT (id) DO NOTHING;

-- Add that user to the workspace as an owner.
INSERT INTO member (id, workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000201',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000101',
  'owner'
)
ON CONFLICT (id) DO NOTHING;

-- A baseline agent — some future E2E tests will need an assignee of assignee_type='agent'.
INSERT INTO agent (id, workspace_id, name, runtime_mode, status, owner_id)
VALUES (
  '00000000-0000-0000-0000-000000000301',
  '00000000-0000-0000-0000-000000000001',
  'Sandbox Agent',
  'local',
  'idle',
  '00000000-0000-0000-0000-000000000101'
)
ON CONFLICT (id) DO NOTHING;

-- One visible issue so the UI has something to render.
INSERT INTO issue (
  id, workspace_id, title, description, status, priority,
  assignee_type, assignee_id, creator_type, creator_id
)
VALUES (
  '00000000-0000-0000-0000-000000000401',
  '00000000-0000-0000-0000-000000000001',
  'Hello from the sandbox',
  'Auto-seeded issue so E2E tests have something to click.',
  'todo',
  'medium',
  'member',
  '00000000-0000-0000-0000-000000000101',
  'member',
  '00000000-0000-0000-0000-000000000101'
)
ON CONFLICT (id) DO NOTHING;

COMMIT;
