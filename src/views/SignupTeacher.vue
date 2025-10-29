<template>
  <v-app>
    <v-main>
      <v-container fluid class="fill-height">
        <v-row align="center" justify="center">
          <v-col cols="12" md="8" lg="6">
            <v-card class="elevation-12">
              <v-card-title class="text-center pa-6 bg-primary">
                <div class="w-100">
                  <v-icon size="48" color="white" class="mb-4">mdi-account-tie</v-icon>
                  <h2 class="text-h4 text-white">Inscription Enseignant</h2>
                  <p class="text-subtitle-1 text-white">Université Catholique de Bukavu</p>
                </div>
              </v-card-title>

              <v-card-text class="pa-6">
                <v-alert v-if="!success" type="info" variant="tonal" class="mb-4">
                  <div class="d-flex align-center">
                    <v-icon class="mr-2">mdi-information</v-icon>
                    <div>
                      Votre compte sera en attente de validation par un administrateur après l'inscription.
                    </div>
                  </div>
                </v-alert>

                <div v-if="success">
                  <v-card flat color="success" variant="tonal" class="pa-6 text-center">
                    <v-icon size="80" color="success" class="mb-4">mdi-check-circle</v-icon>
                    <h3 class="text-h5 mb-4">Inscription réussie!</h3>
                    <p class="mb-4">
                      Votre demande d'inscription a été soumise avec succès.
                      Un administrateur va vérifier vos informations et valider votre compte sous peu.
                    </p>
                    <p class="mb-6 font-weight-bold">
                      Vous recevrez un email de confirmation une fois votre compte validé.
                    </p>

                    <v-btn color="primary" size="large" @click="$router.push('/login')">
                      <v-icon left>mdi-login</v-icon>
                      Retour à la connexion
                    </v-btn>
                  </v-card>
                </div>

                <v-form v-else @submit.prevent="submitRegistration" ref="form">
                  <v-row>
                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="formData.nom"
                        label="Nom *"
                        variant="outlined"
                        prepend-inner-icon="mdi-account"
                        :rules="[rules.required]"
                      ></v-text-field>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="formData.prenom"
                        label="Prénom *"
                        variant="outlined"
                        prepend-inner-icon="mdi-account"
                        :rules="[rules.required]"
                      ></v-text-field>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="formData.matricule"
                        label="Matricule *"
                        variant="outlined"
                        prepend-inner-icon="mdi-card-account-details"
                        :rules="[rules.required]"
                      ></v-text-field>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="formData.email_institutionnel"
                        label="Email institutionnel *"
                        type="email"
                        variant="outlined"
                        prepend-inner-icon="mdi-email"
                        :rules="[rules.required, rules.email]"
                      ></v-text-field>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="formData.email"
                        label="Email personnel"
                        type="email"
                        variant="outlined"
                        prepend-inner-icon="mdi-email-outline"
                      ></v-text-field>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="formData.telephone"
                        label="Téléphone *"
                        variant="outlined"
                        prepend-inner-icon="mdi-phone"
                        :rules="[rules.required]"
                      ></v-text-field>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="formData.departement"
                        label="Département *"
                        variant="outlined"
                        prepend-inner-icon="mdi-domain"
                        :rules="[rules.required]"
                      ></v-text-field>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-select
                        v-model="formData.grade"
                        label="Grade académique *"
                        :items="grades"
                        variant="outlined"
                        prepend-inner-icon="mdi-school"
                        :rules="[rules.required]"
                      ></v-select>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="formData.password"
                        label="Mot de passe *"
                        type="password"
                        variant="outlined"
                        prepend-inner-icon="mdi-lock"
                        :rules="[rules.required, rules.minLength]"
                      ></v-text-field>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-text-field
                        v-model="confirmPassword"
                        label="Confirmer le mot de passe *"
                        type="password"
                        variant="outlined"
                        prepend-inner-icon="mdi-lock-check"
                        :rules="[rules.required, rules.passwordMatch]"
                      ></v-text-field>
                    </v-col>
                  </v-row>

                  <v-alert v-if="errorMessage" type="error" class="mb-4">
                    {{ errorMessage }}
                  </v-alert>

                  <v-btn
                    type="submit"
                    color="primary"
                    size="large"
                    block
                    :loading="submitting"
                    class="mb-4"
                  >
                    <v-icon left>mdi-check</v-icon>
                    S'inscrire
                  </v-btn>

                  <div class="text-center">
                    <v-btn variant="text" @click="$router.push('/login')">
                      Déjà un compte ? Se connecter
                    </v-btn>
                  </div>
                </v-form>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import AuthService from '../services/auth.service'

const form = ref()

const formData = ref({
  matricule: '',
  nom: '',
  prenom: '',
  email: '',
  email_institutionnel: '',
  telephone: '',
  departement: '',
  grade: '',
  password: ''
})

const confirmPassword = ref('')
const submitting = ref(false)
const errorMessage = ref('')
const success = ref(false)

const grades = [
  'Assistant',
  'Chef de Travaux',
  'Professeur',
  'Professeur Associé',
  'Professeur Ordinaire',
  'Chargé de Cours'
]

const rules = {
  required: (v: string) => !!v || 'Ce champ est requis',
  email: (v: string) => !v || /.+@.+\..+/.test(v) || 'Email invalide',
  minLength: (v: string) => v.length >= 6 || 'Minimum 6 caractères',
  passwordMatch: (v: string) => v === formData.value.password || 'Les mots de passe ne correspondent pas'
}

const submitRegistration = async () => {
  const { valid } = await form.value.validate()
  if (!valid) return

  submitting.value = true
  errorMessage.value = ''

  try {
    const result = await AuthService.registerTeacher({
      matricule: formData.value.matricule,
      nom: formData.value.nom,
      prenom: formData.value.prenom,
      email: formData.value.email,
      telephone: formData.value.telephone,
      departement: formData.value.departement,
      grade: formData.value.grade,
      email_institutionnel: formData.value.email_institutionnel,
      password: formData.value.password
    })

    if (result.success) {
      success.value = true
    } else {
      errorMessage.value = result.error || 'Erreur lors de l\'inscription'
    }
  } catch (error: any) {
    errorMessage.value = 'Erreur: ' + error.message
  } finally {
    submitting.value = false
  }
}
</script>
