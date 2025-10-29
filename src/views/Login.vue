<template>
  <v-app>
    <v-main>
      <v-container class="fill-height" fluid>
        <v-row align="center" justify="center">
          <v-col cols="12" sm="8" md="4">
            <v-card class="elevation-12">
              <v-card-title class="text-center pa-6">
                <v-icon size="48" color="primary" class="mb-4">mdi-school</v-icon>
                <h2 class="text-h4 text-primary">UCB Bukavu</h2>
                <p class="text-subtitle-1 text-medium-emphasis">Système de Présence QR</p>
              </v-card-title>
              
              <v-card-text>
                <v-form @submit.prevent="handleLogin" ref="form">
                  <v-text-field
                    v-model="formData.matricule"
                    label="Matricule"
                    prepend-inner-icon="mdi-account"
                    variant="outlined"
                    :rules="[rules.required]"
                    class="mb-3"
                  ></v-text-field>
                  
                  <v-text-field
                    v-model="formData.password"
                    label="Mot de passe"
                    prepend-inner-icon="mdi-lock"
                    type="password"
                    variant="outlined"
                    :rules="[rules.required]"
                    class="mb-4"
                  ></v-text-field>
                  
                  <v-btn
                    type="submit"
                    color="primary"
                    size="large"
                    block
                    :loading="loading"
                    class="mb-4"
                  >
                    Se connecter
                  </v-btn>
                </v-form>
                
                <v-alert
                  v-if="errorMessage"
                  type="error"
                  variant="tonal"
                  class="mt-4"
                >
                  {{ errorMessage }}
                </v-alert>

                <v-divider class="my-4"></v-divider>

                <div class="text-center">
                  <p class="text-body-2 mb-2">Pas encore de compte ?</p>
                  <div class="d-flex gap-2">
                    <v-btn
                      variant="outlined"
                      color="primary"
                      @click="$router.push('/signup-student')"
                      class="flex-grow-1"
                    >
                      <v-icon left>mdi-account-plus</v-icon>
                      Étudiant
                    </v-btn>
                    <v-btn
                      variant="outlined"
                      color="secondary"
                      @click="$router.push('/signup-teacher')"
                      class="flex-grow-1"
                    >
                      <v-icon left>mdi-account-tie</v-icon>
                      Enseignant
                    </v-btn>
                  </div>
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
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import AuthService from '../services/auth.service'

const router = useRouter()
const form = ref()

const formData = ref({
  matricule: '',
  password: ''
})

const loading = ref(false)
const errorMessage = ref('')

const rules = {
  required: (value: string) => !!value || 'Ce champ est requis'
}

const handleLogin = async () => {
  const { valid } = await form.value.validate()
  if (!valid) return

  loading.value = true
  errorMessage.value = ''

  try {
    const result = await AuthService.login(formData.value)

    if (result.success && result.user) {
      AuthService.setCurrentUser(result.user)

      const pendingScan = localStorage.getItem('pending_scan')
      if (pendingScan) {
        const scanData = JSON.parse(pendingScan)
        router.push(`/scan?session_id=${scanData.session_id}&token=${scanData.token}`)
        return
      }

      const redirectPath = result.user.type === 'teacher'
        ? '/teacher-dashboard'
        : '/student-dashboard'

      router.push(redirectPath)
    } else {
      errorMessage.value = result.error || 'Erreur de connexion'
    }
  } catch (error: any) {
    errorMessage.value = 'Erreur de connexion. Veuillez réessayer.'
    console.error('Login error:', error)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.gap-2 {
  gap: 0.5rem;
}
</style>