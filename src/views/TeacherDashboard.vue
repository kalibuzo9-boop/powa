<template>
  <v-app>
    <v-app-bar color="primary" dark>
      <v-app-bar-title>
        <v-icon class="mr-2">mdi-school</v-icon>
        Tableau de Bord Enseignant
      </v-app-bar-title>
      <v-spacer></v-spacer>
      <v-btn icon @click="logout">
        <v-icon>mdi-logout</v-icon>
      </v-btn>
    </v-app-bar>

    <v-main>
      <v-container>
        <v-row>
          <v-col cols="12">
            <v-card class="mb-6">
              <v-card-title>
                <v-icon class="mr-2">mdi-account</v-icon>
                Bienvenue, {{ user?.nom }}
              </v-card-title>
              <v-card-subtitle>Matricule: {{ user?.matricule }}</v-card-subtitle>
            </v-card>
          </v-col>
        </v-row>

        <v-row>
          <!-- QR Code Generation -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-qrcode</v-icon>
                Générer QR Code
              </v-card-title>
              <v-card-text>
                <v-btn
                  color="primary"
                  size="large"
                  block
                  @click="generateQR"
                  :loading="generatingQR"
                >
                  <v-icon class="mr-2">mdi-plus</v-icon>
                  Nouvelle Session
                </v-btn>
                
                <div v-if="currentSession" class="text-center mt-4">
                  <v-card variant="outlined" class="pa-4">
                    <div v-html="qrCodeSVG" class="mb-4"></div>
                    <v-chip color="success" class="mb-2">
                      <v-icon start>mdi-clock</v-icon>
                      Expire dans: {{ timeRemaining }}
                    </v-chip>
                    <div class="text-caption">
                      Session ID: {{ currentSession.session_id }}
                    </div>
                  </v-card>
                </div>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- Session Info -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-information</v-icon>
                Informations Session
              </v-card-title>
              <v-card-text>
                <div v-if="currentSession">
                  <v-list-item>
                    <v-list-item-title>Session Active</v-list-item-title>
                    <v-list-item-subtitle>{{ currentSession.session_id }}</v-list-item-subtitle>
                  </v-list-item>
                  <v-list-item>
                    <v-list-item-title>Présences Enregistrées</v-list-item-title>
                    <v-list-item-subtitle>{{ presences.length }} étudiant(s)</v-list-item-subtitle>
                  </v-list-item>
                  <v-btn
                    color="secondary"
                    variant="outlined"
                    block
                    @click="refreshPresences"
                    :loading="loadingPresences"
                    class="mt-3"
                  >
                    <v-icon class="mr-2">mdi-refresh</v-icon>
                    Actualiser
                  </v-btn>
                </div>
                <div v-else class="text-center text-medium-emphasis">
                  <v-icon size="64" color="grey">mdi-qrcode-scan</v-icon>
                  <p class="mt-2">Aucune session active</p>
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <!-- Attendance List -->
        <v-row v-if="currentSession && presences.length > 0">
          <v-col cols="12">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-format-list-bulleted</v-icon>
                Liste des Présences
              </v-card-title>
              <v-card-text>
                <v-data-table
                  :headers="presenceHeaders"
                  :items="presences"
                  :items-per-page="10"
                  class="elevation-1"
                >
                  <template v-slot:item.date_heure="{ item }">
                    {{ formatDateTime(item.date_heure) }}
                  </template>
                </v-data-table>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color">
      {{ snackbar.text }}
    </v-snackbar>
  </v-app>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import QRCode from 'qrcode'
import ApiService, { type GenerateQRResponse, type Presence } from '../services/api'

const router = useRouter()

const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
const currentSession = ref<GenerateQRResponse | null>(null)
const qrCodeSVG = ref('')
const presences = ref<Presence[]>([])
const generatingQR = ref(false)
const loadingPresences = ref(false)
const timeLeft = ref(0)
const timer = ref<NodeJS.Timeout>()

const snackbar = ref({
  show: false,
  text: '',
  color: 'success'
})

const presenceHeaders = [
  { title: 'Matricule', key: 'etudiant_matricule' },
  { title: 'Nom', key: 'etudiant_nom' },
  { title: 'Date/Heure', key: 'date_heure' },
]

const timeRemaining = computed(() => {
  const minutes = Math.floor(timeLeft.value / 60)
  const seconds = timeLeft.value % 60
  return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
})

const generateQR = async () => {
  if (!user.value) return

  generatingQR.value = true

  try {
    const response = await ApiService.generateQR({ enseignant_id: user.value.id })
    
    if (response.status === 'success' && response.qr_url) {
      currentSession.value = response
      
      // Generate QR code SVG
      const qrCodeDataURL = await QRCode.toString(response.qr_url, {
        type: 'svg',
        width: 200,
        margin: 2,
        color: {
          dark: '#1976D2',
          light: '#FFFFFF'
        }
      })
      qrCodeSVG.value = qrCodeDataURL

      // Start countdown timer
      timeLeft.value = 5 * 60 // 5 minutes
      startTimer()
      
      // Clear previous presences
      presences.value = []
      
      showSnackbar('QR Code généré avec succès!', 'success')
    } else {
      showSnackbar(response.message || 'Erreur lors de la génération du QR', 'error')
    }
  } catch (error) {
    console.error('Generate QR error:', error)
    showSnackbar('Erreur lors de la génération du QR', 'error')
  } finally {
    generatingQR.value = false
  }
}

const refreshPresences = async () => {
  if (!currentSession.value?.session_id) return

  loadingPresences.value = true

  try {
    const data = await ApiService.getPresences(currentSession.value.session_id)
    presences.value = data
  } catch (error) {
    console.error('Refresh presences error:', error)
    showSnackbar('Erreur lors du chargement des présences', 'error')
  } finally {
    loadingPresences.value = false
  }
}

const startTimer = () => {
  if (timer.value) clearInterval(timer.value)
  
  timer.value = setInterval(() => {
    if (timeLeft.value > 0) {
      timeLeft.value--
      
      // Auto-refresh presences every 10 seconds
      if (timeLeft.value % 10 === 0) {
        refreshPresences()
      }
    } else {
      clearInterval(timer.value!)
      currentSession.value = null
      qrCodeSVG.value = ''
      showSnackbar('Session expirée', 'warning')
    }
  }, 1000)
}

const formatDateTime = (dateTime: string) => {
  return new Date(dateTime).toLocaleString('fr-FR')
}

const showSnackbar = (text: string, color: string) => {
  snackbar.value = { show: true, text, color }
}

const logout = () => {
  localStorage.removeItem('user')
  router.push('/login')
}

onMounted(() => {
  if (!user.value || user.value.type !== 'teacher') {
    router.push('/login')
  }
})

onUnmounted(() => {
  if (timer.value) {
    clearInterval(timer.value)
  }
})
</script>