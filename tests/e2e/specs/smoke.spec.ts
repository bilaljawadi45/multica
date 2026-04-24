import { test, expect } from "../fixtures/test.ts";

test("homepage responds", async ({ page }) => {
  await page.goto("/");
  // We just want the frontend to respond with something, not 500 or hang
  await expect(page).toHaveTitle(/DefinitelyNotMulticaXYZ/i);
});

test("backend health endpoint responds", async ({ request }) => {
  // Backend exposes /health (see server/cmd/server/router.go), not /api/health.
  const backend = process.env.MULTICA_BACKEND_URL ?? "http://localhost:8091";
  const res = await request.get(`${backend}/health`);
  expect(res.ok()).toBe(true);
});
