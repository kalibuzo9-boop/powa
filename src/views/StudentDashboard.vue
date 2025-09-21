<template>
  <v-app>
    <v-app-bar color="primary" dark>
      <v-app-bar-title>
        <v-icon class="mr-2">mdi-school</v-icon>
        Tableau de Bord Étudiant
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
          <!-- QR Scanner -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-qrcode-scan</v-icon>
                Scanner QR Code
              </v-card-title>
              <v-card-text>
                <v-text-field
                  v-model="qrUrl"
                  label="URL du QR Code"
                  placeholder="Collez l'URL du QR code ici"
                  variant="outlined"
                  class="mb-4"
                  hint="Scannez le QR code ou collez l'URL manuellement"
                  persistent-hint
                ></v-text-field>
                
                <v-btn
                  color="success"
                  size="large"
                  block
                  @click="checkAttendance"
                  :loading="checkingAttendance"
                  :disabled="!qrUrl"
                >
                  <v-icon class="mr-2">mdi-check</v-icon>
                  Confirmer Présence
                </v-btn>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- Student Info -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-account-details</v-icon>
                Informations Étudiants
              </v-card-title>
              <v-card-text>
                <v-btn
                  color="primary"
                  variant="outlined"
                  block
                  @click="loadStudentInfo"
                  :loading="loadingStudentInfo"
                  class="mb-4"
                >
                  <v-icon class="mr-2">mdi-refresh</v-icon>
                  Charger Infos Officielles
                </v-btn>
                
                <div v-if="studentInfo" class="student-info">
                  <v-card variant="outlined">
                    <v-card-text>
                      <div class="text-center mb-4">
                        <v-avatar size="80" class="mb-2">
                          <v-img
                            :src="studentInfo.avatar"
                            alt="Photo étudiant"
                            @error="onImageError"
                          >
                            <template v-slot:placeholder>
                              <v-icon size="40">mdi-account</v-icon>
                            </template>
                          </v-img>
                        </v-avatar>
                      </div>
                      
                      <v-list density="compact">
                        <v-list-item>
                          <v-list-item-title>Nom complet</v-list-item-title>
                          <v-list-item-subtitle>{{ studentInfo.fullname }}</v-list-item-subtitle>
                        </v-list-item>
                        <v-list-item>
                          <v-list-item-title>Date de naissance</v-list-item-title>
                          <v-list-item-subtitle>{{ formatDate(studentInfo.birthday) }}</v-list-item-subtitle>
                        </v-list-item>
                        <v-list-item>
                          <v-list-item-title>Lieu de naissance</v-list-item-title>
                          <v-list-item-subtitle>{{ studentInfo.birthplace }}</v-list-item-subtitle>
                        </v-list-item>
                        <v-list-item>
                          <v-list-item-title>Statut</v-list-item-title>
                          <v-list-item-subtitle>
                            <v-chip :color="studentInfo.active ? 'success' : 'error'" size="small">
                              {{ studentInfo.active ? 'Actif' : 'Inactif' }}
                            </v-chip>
                          </v-list-item-subtitle>
                        </v-list-item>
                      </v-list>
                    </v-card-text>
                  </v-card>
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <!-- Attendance History -->
        <v-row>
          <v-col cols="12">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-history</v-icon>
                Historique des Présences
                <v-spacer></v-spacer>
                <v-btn
                  color="primary"
                  variant="outlined"
                  @click="loadMyPresences"
                  :loading="loadingPresences"
                >
                  <v-icon class="mr-2">mdi-refresh</v-icon>
                  Actualiser
                </v-btn>
              </v-card-title>
              <v-card-text>
                <div v-if="myPresences.length === 0" class="text-center text-medium-emphasis py-8">
                  <v-icon size="64" color="grey">mdi-clipboard-list-outline</v-icon>
                  <p class="mt-2">Aucune présence enregistrée</p>
                </div>
                
                <v-data-table
                  v-else
                  :headers="presenceHeaders"
                  :items="myPresences"
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
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import ApiService, { type Student, type Presence } from '../services/api'

const router = useRouter()

const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
const qrUrl = ref('')
const studentInfo = ref<Student | null>(null)
const myPresences = ref<Presence[]>([])
const checkingAttendance = ref(false)
const loadingStudentInfo = ref(false)
const loadingPresences = ref(false)

const snackbar = ref({
  show: false,
  text: '',
  color: 'success'
})

const presenceHeaders = [
  { title: 'Session ID', key: 'session_id' },
  { title: 'Date/Heure', key: 'date_heure' },
]

const checkAttendance = async () => {
  if (!qrUrl.value || !user.value) return

  checkingAttendance.value = true

  try {
    // Parse URL to extract session_id and token
    const url = new URL(qrUrl.value)
    const sessionId = url.searchParams.get('session_id')
    const token = url.searchParams.get('token')

    if (!sessionId || !token) {
      showSnackbar('URL QR code invalide', 'error')
      return
    }

    const response = await ApiService.checkAttendance({
      matricule: user.value.matricule,
      session_id: sessionId,
      token: token
    })

    if (response.status === 'success') {
      showSnackbar('Présence enregistrée avec succès!', 'success')
      qrUrl.value = ''
      loadMyPresences() // Refresh attendance history
    } else {
      showSnackbar(response.message || 'Erreur lors de l\'enregistrement', 'error')
    }
  } catch (error) {
    console.error('Check attendance error:', error)
    showSnackbar('Erreur lors de l\'enregistrement de la présence', 'error')
  } finally {
    checkingAttendance.value = false
  }
}

const loadStudentInfo = async () => {
  if (!user.value) return

  loadingStudentInfo.value = true

  try {
    const data = await ApiService.getStudent(user.value.matricule)
    if (data) {
      studentInfo.value = data
      showSnackbar('Informations chargées avec succès', 'success')
    } else {
      showSnackbar('Aucune information trouvée', 'warning')
    }
  } catch (error) {
    console.error('Load student info error:', error)
    showSnackbar('Erreur lors du chargement des informations', 'error')
  } finally {
    loadingStudentInfo.value = false
  }
}

const loadMyPresences = async () => {
  if (!user.value) return

  loadingPresences.value = true

  try {
    const data = await ApiService.getMyPresences(user.value.matricule)
    myPresences.value = data
  } catch (error) {
    console.error('Load presences error:', error)
    showSnackbar('Erreur lors du chargement de l\'historique', 'error')
  } finally {
    loadingPresences.value = false
  }
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}

const formatDateTime = (dateTime: string) => {
  return new Date(dateTime).toLocaleString('fr-FR')
}

const onImageError = (event: Event) => {
  // Handle image load error
  console.log('Image load error:', event)
}

const showSnackbar = (text: string, color: string) => {
  snackbar.value = { show: true, text, color }
}

const logout = () => {
  localStorage.removeItem('user')
  router.push('/login')
}

onMounted(() => {
  if (!user.value || user.value.type !== 'student') {
    router.push('/login')
  } else {
    loadMyPresences()
  }
})
</script>

<style scoped>
.student-info .v-avatar img {
  object-fit: cover;
}
</style>