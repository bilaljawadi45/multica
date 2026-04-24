import { defineConfig } from "@playwright/test";

const FRONTEND_URL = process.env.MULTICA_FRONTEND_URL ?? "http://localhost:3001";

export default defineConfig({
  testDir: "./specs",
  fullyParallel: false,         // sandbox is a single shared state
  retries: 0,                   // retries handled by sandbox/run-tests.sh wrapper
  workers: 1,                   // one test at a time against the shared sandbox
  reporter: [
    ["list"],
    ["json", { outputFile: "playwright-report.json" }],
    ["html", { outputFolder: "playwright-html", open: "never" }],
  ],
  use: {
    baseURL: FRONTEND_URL,
    trace: "on",
    screenshot: "on",
    video: "retain-on-failure",
  },
});
