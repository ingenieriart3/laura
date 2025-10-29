// // assets/tailwind.config.js
// module.exports = {
//   content: [
//     './js/**/*.js',
//     '../lib/laura_web/**/*.{heex,ex,exs}',
//     '../lib/laura_web/components/**/*.{heex,ex}',
//     '../lib/laura_web/controllers/**/*.{heex,ex}',
//     '../lib/laura_web/live/**/*.{heex,ex}',
//     '../lib/laura_web/templates/**/*.{heex,ex}',
//   ],
//   theme: {
//     extend: {},
//   },
//   plugins: [require('@tailwindcss/forms'), require('daisyui')],
//   daisyui: {
//     themes: ['corporate', 'business'],
//   },
// };

// assets/tailwind.config.js
module.exports = {
  content: [
    '../lib/laura_web/**/*.{heex,ex,exs}',
    '../lib/laura/**/*.{heex,ex,exs}', // ← AGREGAR esto
    './js/**/*.js',
  ],
  theme: {
    extend: {},
  },
  plugins: [require('@tailwindcss/forms'), require('daisyui')],
  daisyui: {
    themes: ['corporate', 'business'],
  },
};
