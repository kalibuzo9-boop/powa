<template>
  <v-app>
    <v-app-bar color="primary" dark>
      <v-app-bar-title>
        <v-icon class="mr-2">mdi-school</v-icon>
        Tableau de Bord Étudiant
      </v-app-bar-title>

      <v-spacer />

      <!-- Bouton global pour ouvrir le scanner (ne demande PAS la permission) -->
      <v-btn color="secondary" @click="openScannerDialog" class="mr-3">
        <v-icon left>mdi-qrcode-scan</v-icon>Scanner
      </v-btn>

      <v-btn icon @click="logout"><v-icon>mdi-logout</v-icon></v-btn>
    </v-app-bar>

    <v-main>
      <v-container>
        <!-- User Info -->
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
          <!-- Left quick actions -->
          <v-col cols="12" md="6">
            <v-card>
              <v-card-title>
                <v-icon class="mr-2">mdi-qrcode</v-icon>Scanner rapide
              </v-card-title>
              <v-card-text>
                <div class="mb-2">
                  <small>Appuie sur <strong>Scanner</strong> (en haut) pour ouvrir la fenêtre de scan.</small>
                </div>

                <div v-if="qrUrl" class="mb-3">
                  <strong>Dernier QR scanné :</strong>
                  <div style="word-break:break-all">{{ qrUrl }}</div>
                </div>

                <v-btn color="success" @click="checkAttendance" :disabled="!qrUrl" :loading="checkingAttendance">
                  <v-icon left>mdi-check</v-icon>Confirmer Présence
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
                <v-btn color="primary" variant="outlined" block @click="loadStudentInfo" :loading="loadingStudentInfo" class="mb-4">
                  <v-icon class="mr-2">mdi-refresh</v-icon>Charger Infos Officielles
                </v-btn>

                <div v-if="studentInfo" class="student-info">
                  <v-card variant="outlined">
                    <v-card-text>
                      <div class="text-center mb-4">
                        <v-avatar size="80" class="mb-2">
                          <v-img :src="studentInfo.avatar" alt="Photo" @error="onImageError">
                            <template v-slot:placeholder><v-icon size="40">mdi-account</v-icon></template>
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
                          <v-list-item-title>Lieu</v-list-item-title>
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
                <v-icon class="mr-2">mdi-history</v-icon>Historique des Présences
                <v-spacer></v-spacer>
                <v-btn color="primary" variant="outlined" @click="loadMyPresences" :loading="loadingPresences">
                  <v-icon class="mr-2">mdi-refresh</v-icon>Actualiser
                </v-btn>
              </v-card-title>
              <v-card-text>
                <div v-if="myPresences.length === 0" class="text-center text-medium-emphasis py-8">
                  <v-icon size="64" color="grey">mdi-clipboard-list-outline</v-icon>
                  <p class="mt-2">Aucune présence enregistrée</p>
                </div>

                <v-data-table v-else :headers="presenceHeaders" :items="myPresences" :items-per-page="10" class="elevation-1">
                  <template v-slot:item.date_heure="{ item }">{{ formatDateTime(item.date_heure) }}</template>
                </v-data-table>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>

    <!-- Scanner dialog (modal) -->
    <v-dialog v-model="scannerDialog" persistent width="900">
      <v-card>
        <v-toolbar flat>
          <v-toolbar-title><v-icon class="mr-2">mdi-qrcode-scan</v-icon> Scanner</v-toolbar-title>
          <v-spacer />
          <v-switch v-model="autoSubmit" label="Envoi auto après scan" />
          <v-btn icon @click="closeScannerDialog"><v-icon>mdi-close</v-icon></v-btn>
        </v-toolbar>

        <v-card-text>
          <v-row>
            <v-col cols="12" md="4">
              <!-- Liste des caméras (ne provoque PAS de popup) -->
              <v-select
                v-model="selectedDeviceId"
                :items="cameraDevices"
                item-title="label"
                item-value="deviceId"
                label="Caméra"
                dense
                :loading="loadingDevices"
                hide-details
              />

              <div class="mt-3">
                <!-- LANCER est le moment où on demande la permission -->
                <v-btn color="success" @click="requestAndStart" :loading="loadingPermission || scannerRunning" :disabled="scannerRunning">
                  <v-icon left>mdi-camera</v-icon>Lancer la caméra
                </v-btn>

                <v-btn color="error" @click="stopScanner" class="ml-2" :disabled="!scannerRunning">
                  <v-icon left>mdi-camera-off</v-icon>Arrêter
                </v-btn>
              </div>

              <div class="mt-4">
                <v-btn small color="primary" @click="refreshDevices" :loading="loadingDevices">
                  <v-icon left>mdi-refresh</v-icon>Rafraîchir caméras
                </v-btn>
              </div>

              <div v-if="permissionMessage" class="mt-4" style="color:#c62828">{{ permissionMessage }}</div>
              <div v-if="lastError" class="mt-3">
                <strong>Erreur :</strong>
                <pre style="white-space:pre-wrap; background:#f5f5f5; padding:6px; border-radius:4px;">{{ lastError }}</pre>
              </div>
            </v-col>

            <v-col cols="12" md="8">
              <!-- preview video (apparaît seulement si permission accordée et previewActive true) -->
              <div v-if="previewActive" class="preview-wrap mb-2">
                <video ref="videoEl" autoplay playsinline muted style="width:100%; height:360px; object-fit:cover; border-radius:6px;"></video>
              </div>

              <!-- html5-qrcode container (fallback) -->
              <div id="qr-reader" ref="qrReaderEl" style="width:100%; height:360px; background:#000; border-radius:6px; display:flex;align-items:center;justify-content:center">
                <div v-if="!scannerRunning && !permissionMessage" style="color:#fff">Scanner inactif</div>
              </div>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions>
          <v-spacer />
          <v-btn color="primary" @click="confirmAndClose" :disabled="!qrUrl" :loading="checkingAttendance">
            <v-icon left>mdi-check</v-icon> Confirmer Présence
          </v-btn>
          <v-btn text @click="closeScannerDialog">Fermer</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color">{{ snackbar.text }}</v-snackbar>
  </v-app>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import ApiService, { type Student, type Presence } from '../services/api'

/* ---------- error helper (safe access to message/name) ---------- */
type ErrorInfo = { message: string; name?: string }

function getErrorInfo(err: unknown): ErrorInfo {
  if (err == null) return { message: String(err) }
  if (err instanceof Error) return { message: err.message, name: err.name }
  if (typeof err === 'object') {
    try {
      const anyErr = err as Record<string, unknown>
      const message = anyErr.message ?? anyErr.error ?? JSON.stringify(anyErr)
      const name = typeof anyErr.name === 'string' ? anyErr.name : undefined
      return { message: String(message), name }
    } catch {
      return { message: String(err) }
    }
  }
  return { message: String(err) }
}

/* ---------- state ---------- */
const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
const qrUrl = ref('')
const studentInfo = ref<Student | null>(null)
const myPresences = ref<Presence[]>([])
const checkingAttendance = ref(false)
const loadingStudentInfo = ref(false)
const loadingPresences = ref(false)

const snackbar = ref({ show: false, text: '', color: 'success' })

/* scanner dialog state */
const scannerDialog = ref(false)
const autoSubmit = ref(false)
const qrReaderEl = ref<HTMLElement | null>(null)
const videoEl = ref<HTMLVideoElement | null>(null)
let localStream: MediaStream | null = null
let scannerInstance: any = null
const scannerRunning = ref(false)
const previewActive = ref(false)
const permissionMessage = ref('')
const lastError = ref('')
const loadingDevices = ref(false)
const loadingPermission = ref(false)

const cameraDevices = ref<Array<{ deviceId: string; label: string }>>([])
const selectedDeviceId = ref<string | null>(null)

const presenceHeaders = [
  { title: 'Session ID', key: 'session_id' },
  { title: 'Date/Heure', key: 'date_heure' },
]

/* ---------- helpers ---------- */
const showSnackbar = (text: string, color = 'success') => { snackbar.value = { show: true, text, color } }
function setLastError(err: unknown) {
  const info = getErrorInfo(err)
  lastError.value = info.message
  // console useful for debugging
  // eslint-disable-next-line no-console
  console.debug('ErrorInfo:', info)
}

/* ---------- camera & devices (no silent getUserMedia by default) ---------- */
const refreshDevices = async () => {
  loadingDevices.value = true
  permissionMessage.value = ''
  try {
    if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
      permissionMessage.value = "navigator.mediaDevices.enumerateDevices() non supporté."
      cameraDevices.value = []
      loadingDevices.value = false
      return
    }

    // We do NOT call getUserMedia() here — labels may be empty until permission
    const devices = await navigator.mediaDevices.enumerateDevices()
    const cams = devices
      .filter(d => d.kind === 'videoinput')
      .map(d => ({ deviceId: d.deviceId, label: d.label || `Caméra ${d.deviceId.slice(-4)}` }))
    cameraDevices.value = cams
    if (cams.length && !selectedDeviceId.value) selectedDeviceId.value = cams[0].deviceId
  } catch (err: unknown) {
    setLastError(err)
    const info = getErrorInfo(err)
    permissionMessage.value = 'Impossible de lister les caméras : ' + info.message
  } finally { loadingDevices.value = false }
}

/* ---------- preview & scanner: permission requested WHEN user clicks Lancer ---------- */
async function stopPreview() {
  try {
    if (localStream) {
      localStream.getTracks().forEach(t => t.stop())
      localStream = null
    }
    if (videoEl.value) videoEl.value.srcObject = null
    previewActive.value = false
  } catch (err: unknown) {
    setLastError(err)
  }
}

async function startPreviewForDevice(deviceId: string) {
  await stopPreview()
  loadingPermission.value = true
  try {
    // this request WILL trigger the browser permission popup
    const constraints: MediaStreamConstraints = { video: { deviceId: { exact: deviceId } } }
    localStream = await navigator.mediaDevices.getUserMedia(constraints)
    if (videoEl.value) {
      videoEl.value.srcObject = localStream
      try { await videoEl.value.play() } catch (_) {}
      previewActive.value = true
    }
    loadingPermission.value = false
    permissionMessage.value = ''
    return true
  } catch (err: unknown) {
    loadingPermission.value = false
    setLastError(err)
    const info = getErrorInfo(err)
    permissionMessage.value = info.name === 'NotAllowedError' ? 'Permission caméra refusée.' :
      info.name === 'NotFoundError' ? "Aucune caméra trouvée." :
      'Erreur preview: ' + info.message
    throw err
  }
}

const requestAndStart = async () => {
  if (!selectedDeviceId.value) { permissionMessage.value = 'Sélectionne une caméra.'; return }
  permissionMessage.value = ''
  lastError.value = ''
  try {
    // explicit permission request here
    await startPreviewForDevice(selectedDeviceId.value)
  } catch (_err) {
    return // message already set inside startPreviewForDevice
  }
  await nextTick()
  await startScanner(selectedDeviceId.value)
}

const startScanner = async (deviceId: string) => {
  if (scannerRunning.value) return
  if (!qrReaderEl.value) { permissionMessage.value = 'Container scanner introuvable'; return }
  try {
    const module = await import('html5-qrcode')
    const Html5Qrcode = (module as any).Html5Qrcode
    if (!Html5Qrcode) { permissionMessage.value = 'module html5-qrcode non trouvé'; return }

    try { await stopScanner() } catch (e) { /* ignore */ }

    if (!qrReaderEl.value.id) qrReaderEl.value.id = 'qr-reader'
    scannerInstance = new Html5Qrcode(qrReaderEl.value.id)
    const cameraConfig = { deviceId: { exact: deviceId } }
    const config = { fps: 10, qrbox: 250 }

    await scannerInstance.start(
      cameraConfig,
      config,
      async (decodedText: string) => {
        qrUrl.value = decodedText
        showSnackbar('QR Code détecté !', 'success')
        if (autoSubmit.value) {
          try {
            await checkAttendance()
          } catch (e) {
            // nothing special — checkAttendance handles errors
          }
          await stopScanner()
          await stopPreview()
          scannerDialog.value = false
        }
      },
      (_errMsg: any) => { /* per-frame errors are ignored */ }
    )
    scannerRunning.value = true
  } catch (err: unknown) {
    setLastError(err)
    const info = getErrorInfo(err)
    scannerRunning.value = false
    if (info.name === 'NotAllowedError') permissionMessage.value = 'Permission caméra refusée.'
    else if (info.name === 'NotFoundError') permissionMessage.value = "Aucune caméra détectée."
    else permissionMessage.value = 'Impossible de démarrer le scanner: ' + info.message
  }
}

const stopScanner = async () => {
  try {
    if (scannerInstance && typeof scannerInstance.stop === 'function') await scannerInstance.stop()
    if (scannerInstance && typeof scannerInstance.clear === 'function') await scannerInstance.clear()
  } catch (err: unknown) {
    setLastError(err)
  }
  scannerInstance = null
  scannerRunning.value = false
}

/* ---------- attendance & data ---------- */
const checkAttendance = async () => {
  if (!qrUrl.value || !user.value) return
  checkingAttendance.value = true
  try {
    const url = new URL(qrUrl.value)
    const sessionId = url.searchParams.get('session_id')
    const token = url.searchParams.get('token')
    if (!sessionId || !token) { showSnackbar('QR Code invalide', 'error'); return }
    const response = await ApiService.checkAttendance({ matricule: user.value.matricule, session_id: sessionId, token })
    if (response.status === 'success') { showSnackbar('Présence enregistrée!', 'success'); qrUrl.value = ''; loadMyPresences() }
    else showSnackbar(response.message || 'Erreur enregistrement', 'error')
  } catch (err: unknown) {
    setLastError(err)
    const info = getErrorInfo(err)
    showSnackbar('Erreur enregistrement: ' + info.message, 'error')
  } finally { checkingAttendance.value = false }
}

/* ---------- other features ---------- */
const loadStudentInfo = async () => {
  if (!user.value) return
  loadingStudentInfo.value = true
  try {
    const data = await ApiService.getStudent(user.value.matricule)
    if (data) studentInfo.value = data
    else showSnackbar('Aucune info', 'warning')
  } catch (err: unknown) {
    setLastError(err)
    showSnackbar('Erreur chargement', 'error')
  } finally { loadingStudentInfo.value = false }
}

const loadMyPresences = async () => {
  if (!user.value) return
  loadingPresences.value = true
  try {
    const data = await ApiService.getMyPresences(user.value.matricule)
    myPresences.value = data
  } catch (err: unknown) {
    setLastError(err)
    showSnackbar('Erreur historique', 'error')
  } finally { loadingPresences.value = false }
}

/* ---------- dialog control ---------- */
const openScannerDialog = async () => {
  scannerDialog.value = true
  await nextTick()
  if (qrReaderEl.value && !qrReaderEl.value.id) qrReaderEl.value.id = 'qr-reader'
  // refresh device list WITHOUT asking permission
  await refreshDevices()
}

const closeScannerDialog = async () => {
  await stopScanner()
  await stopPreview()
  scannerDialog.value = false
}

const confirmAndClose = async () => {
  if (!qrUrl.value) { showSnackbar('Aucun QR scanné', 'error'); return }
  await checkAttendance()
  await stopScanner()
  await stopPreview()
  scannerDialog.value = false
}

/* ---------- misc ---------- */
const onImageError = (v: any) => console.log('img err', v)
const formatDate = (d: string) => new Date(d).toLocaleDateString('fr-FR')
const formatDateTime = (d: string) => new Date(d).toLocaleString('fr-FR')
const logout = () => { localStorage.removeItem('user'); router.push('/login') }

/* ---------- lifecycle ---------- */
onMounted(async () => {
  if (!user.value || user.value.type !== 'student') router.push('/login')
  else {
    // initial devices list (no permission popup)
    await refreshDevices()
    loadMyPresences()
  }
})

onBeforeUnmount(async () => {
  try { await stopScanner(); await stopPreview() } catch (_) {}
})
</script>

<style scoped>
.preview-wrap video { width:100%; height:100%; object-fit:cover; border-radius:6px; }
.qr-box { border-radius:6px; overflow:hidden; min-height:260px; background:#000; display:flex; align-items:center; justify-content:center; }
</style>
