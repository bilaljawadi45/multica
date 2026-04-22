-- Audit existing workspace slugs against the newly-added reserved-slug set
-- from MUL-961 (slug review follow-up).
--
-- This PR expands the reserved list in three directions:
--   * §1 Real conflict: `homepage` — `/homepage` is an active Next.js route
--     (`apps/web/app/(landing)/homepage/page.tsx`) that was missing from the
--     reserved list, so a user could register a workspace slug that shadowed
--     the landing page. This slug is the one that actually had to be fixed.
--   * §3 Likely-future routes: home, dashboard, profile, account, billing,
--     notifications, search, members — SaaS-standard entries that we want to
--     protect before they're added, rather than doing another rename pass.
--   * API / backend-adjacent: v1, v2, graphql, webhooks, sdk, tokens, cli,
--     health, ws, metrics, ping — guard against surprise overlap with API
--     versioning, integration, or ops endpoints.
--
-- Follows the 047/049 pattern: the migration is a safety net that fails loud
-- if any prod workspace slug collides with the newly reserved set. If a real
-- conflict surfaces at deploy time, handle it with the MUL-972 playbook
-- (owner outreach → rename to `legacy-<slug>-<short-uuid>` → re-run).
--
-- Keep this slug list aligned with:
--  - server/internal/handler/workspace_reserved_slugs.go
--  - packages/core/paths/reserved-slugs.ts

DO $$
DECLARE
  conflict_count INT;
  conflict_list TEXT;
BEGIN
  SELECT
    COUNT(*),
    string_agg(slug, ', ' ORDER BY slug)
  INTO conflict_count, conflict_list
  FROM workspace
  WHERE slug IN (
    -- Real conflict fix
    'homepage',

    -- Platform / marketing (newly added)
    'home', 'dashboard',

    -- Account / billing (newly added)
    'profile', 'account', 'billing', 'notifications', 'search', 'members',

    -- API / integration prefixes (newly added)
    'v1', 'v2', 'graphql', 'webhooks', 'sdk', 'tokens', 'cli',

    -- Backend ops / observability (newly added)
    'health', 'ws', 'metrics', 'ping'
  );

  IF conflict_count > 0 THEN
    RAISE EXCEPTION 'Found % workspace(s) with slugs that collide with the newly reserved set: %. Rename or delete before deploying (see MUL-972 for the playbook).', conflict_count, conflict_list;
  END IF;
END $$;
