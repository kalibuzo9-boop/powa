import mysqlApi, { type User } from './mysql-api.service'

export interface LoginCredentials {
  matricule: string
  password: string
}

export interface RegisterStudentData {
  matricule: string
  password: string
  nom: string
  prenom?: string
  email?: string
  telephone?: string
  akhademie_data?: any
}

export interface RegisterTeacherData {
  matricule: string
  password: string
  nom: string
  prenom?: string
  email: string
  telephone?: string
  departement?: string
  grade?: string
  email_institutionnel?: string
}

class AuthService {
  async login(credentials: LoginCredentials): Promise<{ success: boolean; user?: User; error?: string }> {
    try {
      const response = await mysqlApi.login(credentials.matricule, credentials.password)

      if (response.error) {
        return { success: false, error: response.error }
      }

      if (response.user) {
        return { success: true, user: response.user }
      }

      return { success: false, error: 'Erreur de connexion' }
    } catch (error: any) {
      if (error.response?.data?.error) {
        return { success: false, error: error.response.data.error }
      }
      return { success: false, error: 'Erreur de connexion au serveur' }
    }
  }

  async registerStudent(data: RegisterStudentData): Promise<{ success: boolean; user?: User; error?: string }> {
    try {
      const response = await mysqlApi.registerStudent(data)

      if (response.error) {
        return { success: false, error: response.error }
      }

      if (response.user) {
        return { success: true, user: response.user }
      }

      return { success: false, error: 'Erreur lors de l\'inscription' }
    } catch (error: any) {
      if (error.response?.data?.error) {
        return { success: false, error: error.response.data.error }
      }
      return { success: false, error: 'Erreur de connexion au serveur' }
    }
  }

  async registerTeacher(data: RegisterTeacherData): Promise<{ success: boolean; user?: User; error?: string }> {
    try {
      const response = await mysqlApi.registerTeacher(data)

      if (response.error) {
        return { success: false, error: response.error }
      }

      if (response.user) {
        return { success: true, user: response.user }
      }

      return { success: false, error: 'Erreur lors de l\'inscription' }
    } catch (error: any) {
      if (error.response?.data?.error) {
        return { success: false, error: error.response.data.error }
      }
      return { success: false, error: 'Erreur de connexion au serveur' }
    }
  }

  async checkMatriculeExists(matricule: string): Promise<boolean> {
    try {
      return await mysqlApi.checkMatriculeExists(matricule)
    } catch {
      return false
    }
  }

  async getCurrentUser(): Promise<User | null> {
    const userJson = localStorage.getItem('user')
    if (!userJson) return null

    try {
      return JSON.parse(userJson)
    } catch {
      return null
    }
  }

  setCurrentUser(user: User | null) {
    if (user) {
      localStorage.setItem('user', JSON.stringify(user))
    } else {
      localStorage.removeItem('user')
    }
  }

  logout() {
    this.setCurrentUser(null)
  }
}

export default new AuthService()
