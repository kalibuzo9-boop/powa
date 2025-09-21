// src/plugins/vuetify.ts
import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'

import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

import { aliases, mdi } from 'vuetify/iconsets/mdi'

export default createVuetify({
  components,   // ✅ enregistrement des composants
  directives,   // ✅ enregistrement des directives
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#1976D2',
          secondary: '#4CAF50',
          accent: '#FF9800',
          error: '#F44336',
          warning: '#FF9800',
          info: '#2196F3',
          success: '#4CAF50',
          surface: '#FFFFFF',
          background: '#F5F5F5',
        },
      },
      dark: {
        colors: {
          primary: '#2196F3',
          secondary: '#4CAF50',
          accent: '#FF9800',
          error: '#F44336',
          warning: '#FF9800',
          info: '#2196F3',
          success: '#4CAF50',
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
