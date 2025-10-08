/**
 * Import the bundled WASM module.
 * This works in both Node.js and browser environments via Vite's WASM plugin.
 */
import wasmModule from '../wasm/guillotine_mini.wasm?init';

export { wasmModule };
