/// <reference types="vite/client" />

declare module '*.wasm?init' {
  const initWasm: () => Promise<WebAssembly.Module>;
  export default initWasm;
}
