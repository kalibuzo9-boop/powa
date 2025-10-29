<template>
  <v-app>
    <v-app-bar color="primary" dark>
      <v-app-bar-title>
        <v-icon class="mr-2">mdi-school</v-icon>
        Tableau de Bord Étudiant
      </v-app-bar-title>
      <v-spacer />
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
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-chart-box</v-icon>
                Statistiques
              </v-card-title>
              <v-card-text>
                <v-list>
                  <v-list-item>
                    <v-list-item-title>Total des présences</v-list-item-title>
                    <v-list-item-subtitle class="text-h4 text-primary">
                      {{ myPresences.length }}
                    </v-list-item-subtitle>
                  </v-list-item>
                </v-list>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-account-details</v-icon>
                Actions Rapides
              </v-card-title>
              <v-card-text>
                <p class="text-body-2 mb-3">
                  Scannez un QR code de session pour enregistrer votre présence
                </p>
                <v-alert type="info" variant="tonal" density="compact">
                  Le professeur génère un QR code à scanner pendant le cours
                </v-alert>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <v-row>
          <v-col cols="12">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-history</v-icon>
                Historique des Présences
                <v-spacer></v-spacer>
                <v-btn color="primary" variant="outlined" @click="loadMyPresences" :loading="loadingPresences">
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
                  <template v-slot:item.course_name="{ item }">
                    <v-chip size="small" color="primary" variant="tonal">
                      {{ item.course_name || 'N/A' }}
                    </v-chip>
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
import AuthService from '../services/auth.service'
import AttendanceService, { type AttendanceRecord } from '../services/attendance.service'

const router = useRouter()

const user = ref(await AuthService.getCurrentUser())
const myPresences = ref<AttendanceRecord[]>([])
const loadingPresences = ref(false)

const snackbar = ref({
  show: false,
  text: '',
  color: 'success'
})

const presenceHeaders = [
  { title: 'Cours', key: 'course_name' },
  { title: 'Date/Heure', key: 'date_heure' },
]

const loadMyPresences = async () => {
  if (!user.value) return

  loadingPresences.value = true
  try {
    const data = await AttendanceService.getStudentAttendance(user.value.id)
    myPresences.value = data
  } catch (error: any) {
    console.error('Load presences error:', error)
    showSnackbar('Erreur lors du chargement de l\'historique', 'error')
  } finally {
    loadingPresences.value = false
  }
}

const formatDateTime = (dateTime: string) => {
  return new Date(dateTime).toLocaleString('fr-FR')
}

const showSnackbar = (text: string, color: string) => {
  snackbar.value = { show: true, text, color }
}

const logout = () => {
  AuthService.logout()
  router.push('/login')
}

onMounted(async () => {
  if (!user.value || user.value.type !== 'student') {
    router.push('/login')
    return
  }

  await loadMyPresences()
})
</script>
