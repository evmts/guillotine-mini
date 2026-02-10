import { onTestFinished } from "vitest";

type OnTestFinished = typeof onTestFinished;
type OnTestFinishedHandler = Parameters<OnTestFinished>[0];

type TestContextFunction = Function & {
  onTestFinished?: (handler: OnTestFinishedHandler) => void;
};

const functionProto = Function.prototype as TestContextFunction;

if (typeof functionProto.onTestFinished !== "function") {
  Object.defineProperty(Function.prototype, "onTestFinished", {
    value: function (handler: OnTestFinishedHandler) {
      return onTestFinished(handler);
    },
    configurable: true,
    writable: true,
  });
}
