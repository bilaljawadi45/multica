# Multica sandbox E2E tests

Playwright tests that run inside the Oxflow code-review sandbox. These are
separate from `multica/e2e/` (the product's own E2E suite) — they exist to
verify a running sandbox stack and drive the live-feed viewer that humans
watch during autonomous PR review.

## Layout

- `specs/` — Playwright test files.
- `fixtures/test.ts` — shared Playwright `test` that installs the live-feed hook.
- `fixtures/live-feed-hook.ts` — wraps common `page.*` actions so the viewer
  on `localhost:9001` sees every step + a screenshot.

## Running against the sandbox

These tests are designed to run against the sandbox stack (ports 8091/3001) spun up
by `sandbox/run-sandbox.sh` in the umbrella repo. Environment vars:

- `MULTICA_FRONTEND_URL` (default `http://localhost:3001`)
- `MULTICA_BACKEND_URL` (default `http://localhost:8091`)
- `LIVE_FEED_DIR` (absolute path; the sandbox orchestrator sets this)

## Running against your own local dev Multica

Set `MULTICA_FRONTEND_URL=http://localhost:3000` and
`MULTICA_BACKEND_URL=http://localhost:8090` (the production self-host ports).

## Local dev

```bash
cd tests/e2e
pnpm install
pnpm install-browsers
pnpm test
```
