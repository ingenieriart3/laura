// assets/tailwind.config.js
module.exports = {
  content: [
    '../lib/laura_web/components/**/*.{heex,ex}',
    '../lib/laura_web/live/**/*.{heex,ex}',
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
