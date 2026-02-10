import { beforeEach, onTestFinished } from "vitest";

type OnTestFinished = typeof onTestFinished;
type OnTestFinishedHandler = Parameters<OnTestFinished>[0];

type TestContext = {
  onTestFinished?: (handler: OnTestFinishedHandler) => void;
};

const safeOnTestFinished: OnTestFinished = (handler) => {
  if (typeof onTestFinished === "function") {
    return onTestFinished(handler);
  }
};

const ensureOnTestFinished = (ctx: unknown) => {
  if (!ctx) {
    return;
  }

  const context = ctx as TestContext;
  if (typeof context.onTestFinished === "function") {
    return;
  }

  Object.defineProperty(context, "onTestFinished", {
    value: safeOnTestFinished,
    configurable: true,
    writable: true,
  });
};

const prototypeContext = Object.prototype as TestContext;
if (typeof prototypeContext.onTestFinished !== "function") {
  Object.defineProperty(Object.prototype, "onTestFinished", {
    value: safeOnTestFinished,
    configurable: true,
    writable: true,
  });
}

beforeEach((ctx) => {
  ensureOnTestFinished(ctx);
});
