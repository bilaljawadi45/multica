import { test as base, expect } from "@playwright/test";
import { installLiveFeed } from "./live-feed-hook.ts";

export const test = base.extend({
  page: async ({ page }, use, testInfo) => {
    installLiveFeed(page, testInfo);
    await use(page);
  },
});

export { expect };
