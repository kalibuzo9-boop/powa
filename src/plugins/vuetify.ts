// src/plugins/vuetify.ts
import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'

import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

import { aliases, mdi } from 'vuetify/iconsets/mdi'

export default createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#003366',
          secondary: '#1abc9c',
          accent: '#f39c12',
          error: '#e74c3c',
          warning: '#f39c12',
          info: '#3498db',
          success: '#27ae60',
          surface: '#FFFFFF',
          background: '#f5f7fa',
        },
      },
      dark: {
        colors: {
          primary: '#1a5490',
          secondary: '#1abc9c',
          accent: '#f39c12',
          error: '#e74c3c',
          warning: '#f39c12',
          info: '#3498db',
          success: '#27ae60',
        },
      },
    },
  },
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi,
    },
  },
})
