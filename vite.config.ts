import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'GuillotineMini',
      formats: ['es'],
      fileName: (format) => `index.js`,
    },
    commonjsOptions: {
      include: [/node_modules/],
    },
    rollupOptions: {
      treeshake: false,
      // Externalize dependencies that shouldn't be bundled
      external: [
        '@tevm/voltaire',
        '@noble/hashes',
      ],
      output: {
        // Preserve module structure for tree-shaking
        preserveModules: false,
        // Output ESM with proper extensions
        entryFileNames: '[name].js',
        // Global variables for UMD build (not used in ESM-only but good to have)
        globals: {
          '@tevm/voltaire': 'Voltaire',
          '@noble/hashes': 'NobleHashes',
        },
      },
    },
    // Generate source maps for debugging
    sourcemap: true,
    // Minify for production
    minify: 'esbuild',
    // Target modern browsers/Node.js with BigInt support
    target: 'es2022',
    // Output directory
    outDir: 'dist',
    // Clean output directory before build
    emptyOutDir: true,
  },
  resolve: {
    alias: {
      '@voltaire': resolve(__dirname, 'src/utils/voltaire-imports'),
      '@': resolve(__dirname, 'src'),
    },
  },
  // Optimize dependencies
  optimizeDeps: {
    include: ['@noble/hashes'],
  },
});
