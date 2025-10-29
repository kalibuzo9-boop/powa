<template>
  <v-app>
    <v-main>
      <v-container fluid class="fill-height">
        <v-row align="center" justify="center">
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title class="text-center pa-6">
                <v-icon size="48" color="primary" class="mb-4">mdi-qrcode-scan</v-icon>
                <h2 class="text-h4">Scan de Présence</h2>
              </v-card-title>

              <v-card-text>
                <v-alert v-if="statusMessage" :type="statusType" class="mb-4">
                  {{ statusMessage }}
                </v-alert>

                <div v-if="loading" class="text-center py-8">
                  <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
                  <p class="mt-4">Vérification en cours...</p>
                </div>

                <div v-else-if="!isAuthenticated" class="text-center py-6">
                  <v-icon size="80" color="warning" class="mb-4">mdi-account-alert</v-icon>
                  <h3 class="text-h5 mb-4">Compte requis</h3>
                  <p class="mb-4">Vous devez créer un compte pour enregistrer votre présence</p>

                  <v-btn color="primary" size="large" @click="goToRegistration" class="mb-3">
                    <v-icon left>mdi-account-plus</v-icon>
                    Créer un compte
                  </v-btn>

                  <div class="mt-4">
                    <v-btn variant="text" @click="goToLogin">
                      Déjà un compte ? Se connecter
                    </v-btn>
                  </div>
                </div>

                <div v-else-if="success" class="text-center py-6">
                  <v-icon size="80" color="success" class="mb-4">mdi-check-circle</v-icon>
                  <h3 class="text-h5 mb-4">Présence enregistrée!</h3>
                  <p>Votre présence a été enregistrée avec succès.</p>

                  <v-btn color="primary" @click="goToDashboard" class="mt-4">
                    Aller au tableau de bord
                  </v-btn>
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import AuthService from '../services/auth.service'
import AttendanceService from '../services/attendance.service'

const router = useRouter()
const route = useRoute()

const isAuthenticated = ref(false)
const loading = ref(true)
const success = ref(false)
const statusMessage = ref('')
const statusType = ref<'success' | 'error' | 'warning' | 'info'>('info')

onMounted(async () => {
  const sessionId = route.query.session_id as string
  const token = route.query.token as string

  if (!sessionId || !token) {
    statusMessage.value = 'Paramètres de session manquants'
    statusType.value = 'error'
    loading.value = false
    return
  }

  const user = await AuthService.getCurrentUser()
  isAuthenticated.value = !!user

  if (!user) {
    localStorage.setItem('pending_scan', JSON.stringify({ session_id: sessionId, token }))
    statusMessage.value = 'Veuillez créer un compte ou vous connecter pour continuer'
    statusType.value = 'warning'
    loading.value = false
    return
  }

  try {
    const validation = await AttendanceService.validateSession(sessionId, token)

    if (!validation.valid) {
      statusMessage.value = validation.error || 'Session invalide'
      statusType.value = 'error'
      loading.value = false
      return
    }

    const result = await AttendanceService.recordAttendance(user.id, validation.session!.id)

    if (result.success) {
      success.value = true
      statusMessage.value = 'Présence enregistrée avec succès!'
      statusType.value = 'success'
      localStorage.removeItem('pending_scan')
    } else {
      statusMessage.value = result.error || 'Erreur lors de l\'enregistrement'
      statusType.value = 'error'
    }
  } catch (error: any) {
    statusMessage.value = 'Erreur: ' + error.message
    statusType.value = 'error'
  } finally {
    loading.value = false
  }
})

const goToRegistration = () => {
  router.push('/signup-student')
}

const goToLogin = () => {
  router.push('/login')
}

const goToDashboard = () => {
  const user = JSON.parse(localStorage.getItem('user') || '{}')
  const path = user.type === 'teacher' ? '/teacher-dashboard' : '/student-dashboard'
  router.push(path)
}
</script>
