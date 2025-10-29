// esbuild.config.js (en la raíz del proyecto)
require('esbuild')
  .build({
    entryPoints: ['assets/js/app.js'],
    bundle: true,
    outdir: 'priv/static/assets',
    target: 'es2017',
    external: ['/fonts/*', '/images/*'],
    loader: {
      '.ttf': 'file',
      '.woff': 'file',
      '.woff2': 'file',
      '.eot': 'file',
      '.svg': 'file',
    },
  })
  .catch(() => process.exit(1));
