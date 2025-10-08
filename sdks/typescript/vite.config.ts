import { defineConfig } from 'vite';
import { resolve } from 'path';
import dts from 'vite-plugin-dts';
import wasm from 'vite-plugin-wasm';

export default defineConfig({
  plugins: [
    wasm(),
    dts({
      insertTypesEntry: true,
      outDir: 'dist',
      include: ['src/**/*.ts'],
    }),
  ],
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'GuillotineMini',
      formats: ['es', 'cjs'],
      fileName: (format) => `index.${format === 'es' ? 'js' : 'cjs'}`,
    },
    rollupOptions: {
      external: ['fs/promises'],
      output: {
        exports: 'named',
        preserveModules: false,
        assetFileNames: '[name][extname]',
      },
    },
    sourcemap: true,
    target: 'es2022',
    minify: false,
  },
  resolve: {
    extensions: ['.ts', '.js', '.wasm'],
  },
  assetsInclude: ['**/*.wasm'],
});
