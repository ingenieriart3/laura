// // // assets/esbuild.config.js
// // const esbuild = require('esbuild');

// // const args = process.argv.slice(2);
// // const watch = args.includes('--watch');
// // const deploy = args.includes('--deploy');

// // const loader = {
// //   // Add loaders for images/fonts/etc if necessary
// //   '.png': 'file',
// //   '.jpg': 'file',
// //   '.svg': 'file',
// //   '.ttf': 'file',
// //   '.woff': 'file',
// //   '.woff2': 'file',
// // };

// // const plugins = [];

// // let opts = {
// //   entryPoints: ['js/app.js'],
// //   bundle: true,
// //   logLevel: 'info',
// //   target: 'es2017',
// //   outdir: '../priv/static/assets',
// //   external: ['/fonts/*', '/images/*'],
// //   loader: loader,
// //   plugins: plugins,
// // };

// // if (deploy) {
// //   opts = {
// //     ...opts,
// //     minify: true,
// //   };
// // }

// // if (watch) {
// //   opts = {
// //     ...opts,
// //     sourcemap: 'inline',
// //   };

// //   esbuild.context(opts).then((ctx) => {
// //     ctx.watch();
// //   });
// // } else {
// //   esbuild.build(opts).catch(() => process.exit(1));
// // }

// // assets/esbuild.config.js
// const esbuild = require('esbuild');

// const isWatch = process.argv.includes('--watch');
// const isDeploy = process.argv.includes('--deploy');

// const config = {
//   entryPoints: ['js/app.js'],
//   bundle: true,
//   outdir: '../priv/static/assets', // ✅ DIRECTO en assets/
//   target: 'es2017',
//   external: ['/fonts/*', '/images/*'],
//   logLevel: 'info',
// };

// if (isDeploy) {
//   config.minify = true;
// }

// if (isWatch) {
//   config.sourcemap = 'inline';
//   esbuild.context(config).then((ctx) => ctx.watch());
// } else {
//   esbuild.build(config).catch(() => process.exit(1));
// }
