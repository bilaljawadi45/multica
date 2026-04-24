// Writes Playwright progress to sandbox/live-feed/state.json and latest.png.
// FEED_DIR must be an absolute path passed via env (LIVE_FEED_DIR). If unset,
// we fall back to a path relative to process.cwd() (which is tests/e2e) that
// points at ../../../sandbox/live-feed — this assumes the layout under the
// umbrella-repo worktree.
import type { Page, TestInfo } from "@playwright/test";
import { mkdirSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const FEED_DIR = process.env.LIVE_FEED_DIR
  ? resolve(process.env.LIVE_FEED_DIR)
  : resolve(process.cwd(), "..", "..", "..", "sandbox", "live-feed");

interface State {
  statusLight: "green" | "yellow" | "red";
  currentStep: string;
  currentTest: string;
  currentFile: string;
  history: Array<{ ts: string; summary: string }>;
}

const state: State = {
  statusLight: "green",
  currentStep: "initializing",
  currentTest: "",
  currentFile: "",
  history: [],
};

mkdirSync(FEED_DIR, { recursive: true });

function flush(): void {
  writeFileSync(resolve(FEED_DIR, "state.json"), JSON.stringify(state, null, 2));
}

export function installLiveFeed(page: Page, testInfo: TestInfo): void {
  state.currentTest = testInfo.title;
  state.currentFile = testInfo.file;
  state.currentStep = "starting";
  state.history.push({ ts: new Date().toISOString(), summary: `start: ${testInfo.title}` });
  flush();

  // Wrap common page actions so the viewer sees every step.
  // The cast chain is ugly but Playwright's Page method overloads are many —
  // we just need the call signatures to remain identical to the callee.
  const wrap = <T extends (...args: unknown[]) => unknown>(name: string, fn: T): T => {
    return (async (...args: unknown[]) => {
      const firstArg = typeof args[0] === "string" ? args[0] : "";
      state.currentStep = `${name}(${firstArg})`;
      state.history.push({ ts: new Date().toISOString(), summary: state.currentStep });
      if (state.history.length > 50) state.history.shift();
      flush();
      try {
        const result = await (fn as (...a: unknown[]) => Promise<unknown>).apply(page, args);
        // Best-effort screenshot after each action.
        try {
          const buf = await page.screenshot({ type: "png" });
          writeFileSync(resolve(FEED_DIR, "latest.png"), buf);
        } catch {
          /* screenshot best-effort */
        }
        return result;
      } catch (e) {
        state.statusLight = "red";
        state.history.push({
          ts: new Date().toISOString(),
          summary: `FAIL: ${(e as Error).message}`,
        });
        flush();
        throw e;
      }
    }) as unknown as T;
  };

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (page as any).click = wrap("click", page.click.bind(page) as never);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (page as any).fill = wrap("fill", page.fill.bind(page) as never);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (page as any).goto = wrap("goto", page.goto.bind(page) as never);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (page as any).press = wrap("press", page.press.bind(page) as never);
}
