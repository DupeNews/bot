const { nodeExternalsPlugin } = require('esbuild-node-externals');

// Build Discord bot
require('esbuild').build({
  entryPoints: ['./src/index.ts'],
  sourceRoot: './src',
  bundle: true,
  outfile: 'index.js',
  minify: true,
  plugins: [nodeExternalsPlugin()],
  external: ['fs', 'child_process'],
  minifyWhitespace: false,
}).catch(() => process.exit(1));

// Build API server
require('esbuild').build({
  entryPoints: ['./src/api.ts'],
  sourceRoot: './src',
  bundle: true,
  outfile: 'api.js',
  minify: true,
  plugins: [nodeExternalsPlugin()],
  external: ['fs', 'child_process'],
  minifyWhitespace: false,
}).catch(() => process.exit(1));
