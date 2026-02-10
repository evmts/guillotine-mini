import { beforeEach, onTestFinished } from "vitest";

type OnTestFinished = typeof onTestFinished;
type OnTestFinishedHandler = Parameters<OnTestFinished>[0];

type TestContext = {
  onTestFinished?: (handler: OnTestFinishedHandler) => void;
};

beforeEach((ctx) => {
  const context = ctx as TestContext;
  if (typeof context.onTestFinished === "function") {
    return;
  }

  Object.defineProperty(context, "onTestFinished", {
    value: onTestFinished,
    configurable: true,
    writable: true,
  });
});
