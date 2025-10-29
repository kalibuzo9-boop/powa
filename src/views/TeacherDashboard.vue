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
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-qrcode</v-icon>
                Générer QR Code
              </v-card-title>
              <v-card-text>
                <v-select
                  v-model="selectedCourse"
                  :items="myCourses"
                  item-title="titre"
                  item-value="id"
                  label="Sélectionner un cours"
                  variant="outlined"
                  prepend-inner-icon="mdi-book-open-variant"
                  :loading="loadingCourses"
                  class="mb-3"
                ></v-select>

                <v-text-field
                  v-model="salle"
                  label="Salle (optionnel)"
                  variant="outlined"
                  prepend-inner-icon="mdi-door"
                  class="mb-3"
                ></v-text-field>

                <v-btn
                  color="primary"
                  size="large"
                  block
                  @click="generateQR"
                  :loading="generatingQR"
                  :disabled="!selectedCourse"
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
                    <div class="text-caption mb-2">
                      Cours: {{ selectedCourseName }}
                    </div>
                    <div class="text-caption">
                      Salle: {{ salle || 'Non spécifiée' }}
                    </div>
                  </v-card>
                </div>
              </v-card-text>
            </v-card>
          </v-col>

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

        <v-row>
          <v-col cols="12">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-file-pdf-box</v-icon>
                Exporter les Présences
              </v-card-title>
              <v-card-text>
                <v-row>
                  <v-col cols="12" md="4">
                    <v-select
                      v-model="exportCourse"
                      :items="myCourses"
                      item-title="titre"
                      item-value="id"
                      label="Cours"
                      variant="outlined"
                    ></v-select>
                  </v-col>
                  <v-col cols="12" md="4">
                    <v-text-field
                      v-model="exportDate"
                      label="Date"
                      type="date"
                      variant="outlined"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="12" md="4" class="d-flex align-center">
                    <v-btn
                      color="primary"
                      @click="exportPDF"
                      :loading="exporting"
                      :disabled="!exportCourse || !exportDate"
                      block
                    >
                      <v-icon class="mr-2">mdi-download</v-icon>
                      Exporter PDF
                    </v-btn>
                  </v-col>
                </v-row>
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
import AuthService from '../services/auth.service'
import AttendanceService, { type AttendanceRecord } from '../services/attendance.service'
import PDFService from '../services/pdf.service'
import type { Cours } from '../services/mysql-api.service'

const router = useRouter()

const user = ref(await AuthService.getCurrentUser())
const myCourses = ref<Cours[]>([])
const selectedCourse = ref<number | ''>('')
const salle = ref('')
const currentSession = ref<any>(null)
const qrCodeSVG = ref('')
const presences = ref<AttendanceRecord[]>([])
const generatingQR = ref(false)
const loadingCourses = ref(false)
const loadingPresences = ref(false)
const timeLeft = ref(0)
const timer = ref<NodeJS.Timeout>()

const exportCourse = ref<number | ''>('')
const exportDate = ref(new Date().toISOString().split('T')[0])
const exporting = ref(false)

const snackbar = ref({
  show: false,
  text: '',
  color: 'success'
})

const presenceHeaders = [
  { title: 'Matricule', key: 'student_matricule' },
  { title: 'Nom', key: 'student_name' },
  { title: 'Date/Heure', key: 'date_heure' },
]

const timeRemaining = computed(() => {
  const minutes = Math.floor(timeLeft.value / 60)
  const seconds = timeLeft.value % 60
  return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
})

const selectedCourseName = computed(() => {
  const course = myCourses.value.find((c: Cours) => c.id === selectedCourse.value)
  return course?.titre || ''
})

const loadMyCourses = async () => {
  if (!user.value) return

  loadingCourses.value = true
  try {
    const courses = await AttendanceService.getTeacherCourses(user.value.id)
    myCourses.value = courses
  } catch (error) {
    console.error('Load courses error:', error)
    showSnackbar('Erreur lors du chargement des cours', 'error')
  } finally {
    loadingCourses.value = false
  }
}

const generateQR = async () => {
  if (!user.value || !selectedCourse.value) return

  generatingQR.value = true

  try {
    const { session, qr_url } = await AttendanceService.createSession({
      enseignant_id: user.value.id,
      cours_id: selectedCourse.value,
      salle: salle.value || undefined,
      duration_minutes: 5
    })

    currentSession.value = session

    const qrCodeDataURL = await QRCode.toString(qr_url, {
      type: 'svg',
      width: 200,
      margin: 2,
      color: {
        dark: '#003366',
        light: '#FFFFFF'
      }
    })
    qrCodeSVG.value = qrCodeDataURL

    timeLeft.value = 5 * 60
    startTimer()

    presences.value = []

    showSnackbar('QR Code généré avec succès!', 'success')
  } catch (error: any) {
    console.error('Generate QR error:', error)
    showSnackbar('Erreur lors de la génération du QR', 'error')
  } finally {
    generatingQR.value = false
  }
}

const refreshPresences = async () => {
  if (!currentSession.value?.id) return

  loadingPresences.value = true

  try {
    const data = await AttendanceService.getSessionAttendance(currentSession.value.id)
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

const exportPDF = async () => {
  if (!user.value || !exportCourse.value || !exportDate.value) return

  exporting.value = true

  try {
    const course = myCourses.value.find((c: Cours) => c.id === exportCourse.value)
    const records = await AttendanceService.getTeacherAttendanceByDate(
      user.value.id,
      exportDate.value
    )

    const filtered = records.filter((r: any) =>
      r.sessions?.cours_id === exportCourse.value
    )

    PDFService.generateAttendancePDF({
      teacherName: `${user.value.nom} ${user.value.prenom || ''}`.trim(),
      courseName: course?.titre,
      date: exportDate.value,
      records: filtered
    })

    showSnackbar('PDF exporté avec succès!', 'success')
  } catch (error: any) {
    console.error('Export PDF error:', error)
    showSnackbar('Erreur lors de l\'export PDF', 'error')
  } finally {
    exporting.value = false
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
  if (!user.value || user.value.type !== 'teacher') {
    router.push('/login')
    return
  }

  await loadMyCourses()
})

onUnmounted(() => {
  if (timer.value) {
    clearInterval(timer.value)
  }
})
</script>
