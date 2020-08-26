const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  purge: [
    './src/**/*.html',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  variants: {
    textColor: ['group-hover', 'hover', 'focus'],
    fontFamily: ['group-hover'],
    boxShadow: ['focus-within', 'hover', 'group-hover'],
  },
  plugins: [
    require('@tailwindcss/ui'),
  ]
}

