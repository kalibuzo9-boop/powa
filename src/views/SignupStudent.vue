<template>
  <v-app>
    <v-main>
      <v-container fluid class="fill-height">
        <v-row align="center" justify="center">
          <v-col cols="12" md="8" lg="6">
            <v-card class="elevation-12">
              <v-card-title class="text-center pa-6 bg-primary">
                <div class="w-100">
                  <v-icon size="48" color="white" class="mb-4">mdi-account-plus</v-icon>
                  <h2 class="text-h4 text-white">Inscription Étudiant</h2>
                  <p class="text-subtitle-1 text-white">Université Catholique de Bukavu</p>
                </div>
              </v-card-title>

              <v-card-text class="pa-6">
                <v-stepper v-model="step" :items="['Matricule', 'Informations', 'Confirmation']">
                  <template v-slot:item.1>
                    <v-card flat>
                      <v-card-text>
                        <h3 class="text-h6 mb-4">Étape 1: Saisissez votre matricule</h3>

                        <v-text-field
                          v-model="matricule"
                          label="Matricule (ex: 05/23.07433)"
                          prepend-inner-icon="mdi-card-account-details"
                          variant="outlined"
                          :rules="[rules.required]"
                          :loading="loadingAkhademie"
                          :disabled="loadingAkhademie"
                          @keyup.enter="fetchAkhademieData"
                        ></v-text-field>

                        <v-alert v-if="akhademieError" type="error" class="mb-4">
                          {{ akhademieError }}
                        </v-alert>

                        <v-btn
                          color="primary"
                          size="large"
                          block
                          @click="fetchAkhademieData"
                          :loading="loadingAkhademie"
                          :disabled="!matricule"
                        >
                          <v-icon left>mdi-magnify</v-icon>
                          Rechercher
                        </v-btn>

                        <div class="text-center mt-4">
                          <v-btn variant="text" @click="$router.push('/login')">
                            Déjà un compte ? Se connecter
                          </v-btn>
                        </div>
                      </v-card-text>
                    </v-card>
                  </template>

                  <template v-slot:item.2>
                    <v-card flat>
                      <v-card-text>
                        <h3 class="text-h6 mb-4">Étape 2: Vérifiez vos informations</h3>

                        <v-row v-if="akhademieData">
                          <v-col cols="12" class="text-center mb-4">
                            <v-avatar size="100">
                              <v-img :src="formData.avatar || undefined" alt="Photo">
                                <template v-slot:placeholder>
                                  <v-icon size="50">mdi-account</v-icon>
                                </template>
                              </v-img>
                            </v-avatar>
                          </v-col>

                          <v-col cols="12" md="6">
                            <v-text-field
                              v-model="formData.nom"
                              label="Nom complet"
                              variant="outlined"
                              :rules="[rules.required]"
                            ></v-text-field>
                          </v-col>

                          <v-col cols="12" md="6">
                            <v-text-field
                              v-model="formData.prenom"
                              label="Prénom"
                              variant="outlined"
                            ></v-text-field>
                          </v-col>

                          <v-col cols="12" md="6">
                            <v-text-field
                              v-model="formData.email"
                              label="Email"
                              type="email"
                              variant="outlined"
                              prepend-inner-icon="mdi-email"
                            ></v-text-field>
                          </v-col>

                          <v-col cols="12" md="6">
                            <v-text-field
                              v-model="formData.telephone"
                              label="Téléphone"
                              variant="outlined"
                              prepend-inner-icon="mdi-phone"
                            ></v-text-field>
                          </v-col>

                          <v-col cols="12" md="6">
                            <v-text-field
                              v-model="formData.filiere"
                              label="Filière"
                              variant="outlined"
                              readonly
                            ></v-text-field>
                          </v-col>

                          <v-col cols="12" md="6">
                            <v-text-field
                              v-model="formData.orientation"
                              label="Orientation"
                              variant="outlined"
                              readonly
                            ></v-text-field>
                          </v-col>

                          <v-col cols="12">
                            <v-text-field
                              v-model="formData.password"
                              label="Mot de passe"
                              type="password"
                              variant="outlined"
                              prepend-inner-icon="mdi-lock"
                              :rules="[rules.required, rules.minLength]"
                            ></v-text-field>
                          </v-col>

                          <v-col cols="12">
                            <v-text-field
                              v-model="confirmPassword"
                              label="Confirmer le mot de passe"
                              type="password"
                              variant="outlined"
                              prepend-inner-icon="mdi-lock-check"
                              :rules="[rules.required, rules.passwordMatch]"
                            ></v-text-field>
                          </v-col>
                        </v-row>

                        <v-alert v-if="registrationError" type="error" class="mb-4">
                          {{ registrationError }}
                        </v-alert>

                        <div class="d-flex gap-2">
                          <v-btn @click="step = 1" variant="outlined">
                            <v-icon left>mdi-arrow-left</v-icon>
                            Retour
                          </v-btn>
                          <v-btn
                            color="primary"
                            @click="submitRegistration"
                            :loading="submitting"
                            :disabled="!canSubmit"
                            class="flex-grow-1"
                          >
                            <v-icon left>mdi-check</v-icon>
                            Créer mon compte
                          </v-btn>
                        </div>
                      </v-card-text>
                    </v-card>
                  </template>

                  <template v-slot:item.3>
                    <v-card flat>
                      <v-card-text class="text-center py-8">
                        <v-icon size="100" color="success" class="mb-4">mdi-check-circle</v-icon>
                        <h3 class="text-h5 mb-4">Compte créé avec succès!</h3>
                        <p class="mb-6">Votre compte a été créé. Vous pouvez maintenant vous connecter.</p>

                        <v-btn color="primary" size="large" @click="completeRegistration">
                          <v-icon left>mdi-login</v-icon>
                          Se connecter
                        </v-btn>
                      </v-card-text>
                    </v-card>
                  </template>
                </v-stepper>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import AuthService from '../services/auth.service'

const router = useRouter()

const step = ref(1)
const matricule = ref('')
const loadingAkhademie = ref(false)
const akhademieError = ref('')
const akhademieData = ref<any>(null)
const submitting = ref(false)
const registrationError = ref('')
const confirmPassword = ref('')

const formData = ref({
  nom: '',
  prenom: '',
  email: '',
  telephone: '',
  password: '',
  filiere: '',
  orientation: '',
  avatar: ''
})

const rules = {
  required: (v: string) => !!v || 'Ce champ est requis',
  minLength: (v: string) => v.length >= 6 || 'Minimum 6 caractères',
  passwordMatch: (v: string) => v === formData.value.password || 'Les mots de passe ne correspondent pas'
}

const canSubmit = computed(() => {
  return formData.value.nom &&
    formData.value.password &&
    formData.value.password.length >= 6 &&
    confirmPassword.value === formData.value.password
})

const fetchAkhademieData = async () => {
  if (!matricule.value) return

  loadingAkhademie.value = true
  akhademieError.value = ''

  try {
    const response = await axios.get(
      `https://akhademie.ucbukavu.ac.cd/api/v1/school-students/read-by-matricule?matricule=${encodeURIComponent(matricule.value)}`
    )

    if (response.data) {
      akhademieData.value = response.data

      formData.value.nom = response.data.fullname || ''
      formData.value.prenom = response.data.firstname || ''
      formData.value.filiere = response.data.schoolFilieres?.shortName || ''
      formData.value.orientation = response.data.schoolOrientations?.title || ''
      formData.value.avatar = response.data.avatar || ''

      step.value = 2
    } else {
      akhademieError.value = 'Aucune donnée trouvée pour ce matricule'
    }
  } catch (error: any) {
    akhademieError.value = 'Erreur lors de la récupération des données. Vérifiez le matricule.'
  } finally {
    loadingAkhademie.value = false
  }
}

const submitRegistration = async () => {
  if (!canSubmit.value) return

  submitting.value = true
  registrationError.value = ''

  try {
    const result = await AuthService.registerStudent({
      matricule: matricule.value,
      nom: formData.value.nom,
      prenom: formData.value.prenom,
      email: formData.value.email,
      telephone: formData.value.telephone,
      password: formData.value.password,
      akhademie_data: akhademieData.value
    })

    if (result.success) {
      step.value = 3
    } else {
      registrationError.value = result.error || 'Erreur lors de l\'inscription'
    }
  } catch (error: any) {
    registrationError.value = 'Erreur: ' + error.message
  } finally {
    submitting.value = false
  }
}

const completeRegistration = () => {
  const pendingScan = localStorage.getItem('pending_scan')

  if (pendingScan) {
    const scanData = JSON.parse(pendingScan)
    router.push(`/scan?session_id=${scanData.session_id}&token=${scanData.token}`)
  } else {
    router.push('/login')
  }
}
</script>

<style scoped>
.gap-2 {
  gap: 0.5rem;
}
</style>
