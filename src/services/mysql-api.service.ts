import axios, { AxiosInstance } from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost/api.php'

export interface User {
  id: number
  matricule: string
  email?: string
  nom: string
  prenom?: string
  type: 'student' | 'teacher' | 'admin'
  status: 'active' | 'pending' | 'suspended'
  avatar?: string
  telephone?: string
  created_at: string
  updated_at: string
}

export interface StudentProfile {
  id: number
  user_id: number
  akhademie_id?: string
  fullname?: string
  firstname?: string
  lastname?: string
  gender?: string
  birthday?: string
  birthplace?: string
  filiere?: string
  orientation?: string
  commune?: string
  district?: string
  street?: string
  promotion_id?: number
}

export interface TeacherProfile {
  id: number
  user_id: number
  departement?: string
  grade?: string
  piece_identite?: string
  email_institutionnel?: string
  validation_date?: string
  validated_by?: number
}

export interface Cours {
  id: number
  titre: string
  code?: string
  description?: string
  credits?: number
  departement?: string
  created_at: string
}

export interface Session {
  id: number
  session_id: string
  enseignant_id: number
  cours_id?: number
  token: string
  salle?: string
  expiration: string
  created_at: string
}

export interface Presence {
  id: number
  etudiant_id: number
  session_id: number
  date_heure: string
  created_at: string
  student_matricule?: string
  student_name?: string
  course_name?: string
  session_expiration?: string
}

export interface ApiResponse<T = any> {
  success?: boolean
  data?: T
  user?: User
  session?: Session
  qr_url?: string
  error?: string
  message?: string
  valid?: boolean
  exists?: boolean
}

class MySQLApiService {
  private api: AxiosInstance

  constructor() {
    this.api = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    })
  }

  async login(matricule: string, password: string): Promise<ApiResponse<User>> {
    const response = await this.api.post('/auth/login', { matricule, password })
    return response.data
  }

  async registerStudent(data: {
    matricule: string
    password: string
    nom: string
    prenom?: string
    email?: string
    telephone?: string
    avatar?: string
    akhademie_data?: any
  }): Promise<ApiResponse<User>> {
    const response = await this.api.post('/auth/register/student', data)
    return response.data
  }

  async registerTeacher(data: {
    matricule: string
    password: string
    nom: string
    prenom?: string
    email: string
    telephone?: string
    departement?: string
    grade?: string
    email_institutionnel?: string
  }): Promise<ApiResponse<User>> {
    const response = await this.api.post('/auth/register/teacher', data)
    return response.data
  }

  async checkMatriculeExists(matricule: string): Promise<boolean> {
    try {
      const response = await this.api.get('/auth/check-matricule', {
        params: { matricule }
      })
      return response.data.exists || false
    } catch {
      return false
    }
  }

  async getAllCourses(): Promise<Cours[]> {
    const response = await this.api.get('/courses')
    return response.data.data || []
  }

  async getTeacherCourses(teacherId: number): Promise<Cours[]> {
    const response = await this.api.get('/courses/teacher', {
      params: { teacher_id: teacherId }
    })
    return response.data.data || []
  }

  async createSession(data: {
    enseignant_id: number
    cours_id?: number
    salle?: string
    duration_minutes?: number
  }): Promise<{ session: Session; qr_url: string }> {
    const response = await this.api.post('/sessions', data)
    return {
      session: response.data.session,
      qr_url: response.data.qr_url
    }
  }

  async validateSession(sessionId: string, token: string): Promise<ApiResponse<Session>> {
    const response = await this.api.get('/sessions/validate', {
      params: { session_id: sessionId, token }
    })
    return response.data
  }

  async recordAttendance(etudiantId: number, sessionId: number): Promise<ApiResponse> {
    const response = await this.api.post('/attendance/record', {
      etudiant_id: etudiantId,
      session_id: sessionId
    })
    return response.data
  }

  async getSessionAttendance(sessionId: number): Promise<Presence[]> {
    const response = await this.api.get('/attendance/session', {
      params: { session_id: sessionId }
    })
    return response.data.data || []
  }

  async getStudentAttendance(studentId: number): Promise<Presence[]> {
    const response = await this.api.get('/attendance/student', {
      params: { student_id: studentId }
    })
    return response.data.data || []
  }

  async getTeacherAttendanceByDate(teacherId: number, date: string): Promise<Presence[]> {
    const response = await this.api.get('/attendance/teacher/date', {
      params: { teacher_id: teacherId, date }
    })
    return response.data.data || []
  }

  async getTeacherAttendanceByCourse(
    teacherId: number,
    coursId: number,
    startDate: string,
    endDate: string
  ): Promise<Presence[]> {
    const response = await this.api.get('/attendance/teacher/course', {
      params: {
        teacher_id: teacherId,
        cours_id: coursId,
        start_date: startDate,
        end_date: endDate
      }
    })
    return response.data.data || []
  }

  async getStudentFromAkhademie(matricule: string): Promise<any> {
    const response = await this.api.get('/external/student', {
      params: { matricule }
    })
    return response.data.data
  }

  async getStructureFromAkhademie(): Promise<any[]> {
    const response = await this.api.get('/external/structure')
    return response.data.data || []
  }
}

export default new MySQLApiService()
