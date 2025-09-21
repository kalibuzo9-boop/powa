import axios from 'axios'

const API_BASE_URL = 'http://localhost/api.php'

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

export interface LoginRequest {
  matricule: string
  password: string
}

export interface LoginResponse {
  status: 'success' | 'error'
  data?: {
    id: number
    matricule: string
    nom: string
    type: 'teacher' | 'student'
  }
  message?: string
}

export interface GenerateQRRequest {
  enseignant_id: number
}

export interface GenerateQRResponse {
  status: 'success' | 'error'
  qr_url?: string
  session_id?: string
  expiration?: string
  message?: string
}

export interface CheckAttendanceRequest {
  matricule: string
  session_id: string
  token: string
}

export interface CheckAttendanceResponse {
  status: 'success' | 'error'
  message: string
}

export interface Student {
  matricule: string
  fullname: string
  birthday: string
  birthplace: string
  city: string
  civilStatus: string
  avatar: string
  active: number
  promotionId: number
}

export interface AcademicStructure {
  id: number
  title: string
  label: string
  level: number
  entityId: number
}

export interface Presence {
  id: number
  etudiant_matricule: string
  etudiant_nom: string
  session_id: string
  date_heure: string
}

class ApiService {
  async login(data: LoginRequest): Promise<LoginResponse> {
    const response = await api.post('', data, {
      params: { action: 'login' }
    })
    return response.data
  }

  async generateQR(data: GenerateQRRequest): Promise<GenerateQRResponse> {
    const response = await api.post('', data, {
      params: { action: 'generate_qr' }
    })
    return response.data
  }

  async checkAttendance(data: CheckAttendanceRequest): Promise<CheckAttendanceResponse> {
    const response = await api.post('', data, {
      params: { action: 'check_attendance' }
    })
    return response.data
  }

  async getPresences(sessionId: string): Promise<Presence[]> {
    const response = await api.get('', {
      params: { action: 'list_presences', session_id: sessionId }
    })
    return response.data.data || []
  }

  async getMyPresences(matricule: string): Promise<Presence[]> {
    const response = await api.get('', {
      params: { action: 'my_presences', matricule }
    })
    return response.data.data || []
  }

  async getStudent(matricule: string): Promise<Student | null> {
    const response = await api.get('', {
      params: { action: 'getStudent', matricule }
    })
    return response.data.data || null
  }

  async getStructure(): Promise<AcademicStructure[]> {
    const response = await api.get('', {
      params: { action: 'getStructure' }
    })
    return response.data.data || []
  }
}

export default new ApiService()