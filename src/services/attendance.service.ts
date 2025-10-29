import mysqlApi, { type Session, type Presence, type Cours } from './mysql-api.service'

export interface CreateSessionData {
  enseignant_id: number
  cours_id?: number
  salle?: string
  duration_minutes?: number
}

export interface AttendanceRecord extends Presence {
  student_name?: string
  student_matricule?: string
  course_name?: string
  session_expiration?: string
}

class AttendanceService {
  async getCourses(): Promise<Cours[]> {
    try {
      return await mysqlApi.getAllCourses()
    } catch (error) {
      console.error('Error loading courses:', error)
      return []
    }
  }

  async getTeacherCourses(teacherId: number): Promise<Cours[]> {
    try {
      return await mysqlApi.getTeacherCourses(teacherId)
    } catch (error) {
      console.error('Error loading teacher courses:', error)
      return []
    }
  }

  async createSession(data: CreateSessionData): Promise<{ session: Session; qr_url: string }> {
    try {
      return await mysqlApi.createSession(data)
    } catch (error: any) {
      throw new Error(error.response?.data?.error || 'Erreur lors de la création de la session')
    }
  }

  async validateSession(sessionId: string, token: string): Promise<{ valid: boolean; session?: Session; error?: string }> {
    try {
      const response = await mysqlApi.validateSession(sessionId, token)

      if (response.valid && response.session) {
        return { valid: true, session: response.session }
      }

      return { valid: false, error: response.error || 'Session invalide' }
    } catch (error: any) {
      if (error.response?.status === 410) {
        return { valid: false, error: 'Session expirée' }
      }
      if (error.response?.status === 404) {
        return { valid: false, error: 'Session invalide' }
      }
      return { valid: false, error: error.response?.data?.error || 'Erreur lors de la validation' }
    }
  }

  async recordAttendance(studentId: number, sessionId: number): Promise<{ success: boolean; error?: string }> {
    try {
      const response = await mysqlApi.recordAttendance(studentId, sessionId)

      if (response.error) {
        return { success: false, error: response.error }
      }

      return { success: true }
    } catch (error: any) {
      if (error.response?.status === 409) {
        return { success: false, error: 'Présence déjà enregistrée pour cette session' }
      }
      return { success: false, error: error.response?.data?.error || 'Erreur lors de l\'enregistrement' }
    }
  }

  async getSessionAttendance(sessionId: number): Promise<AttendanceRecord[]> {
    try {
      return await mysqlApi.getSessionAttendance(sessionId)
    } catch (error) {
      console.error('Error loading session attendance:', error)
      return []
    }
  }

  async getStudentAttendance(studentId: number): Promise<AttendanceRecord[]> {
    try {
      return await mysqlApi.getStudentAttendance(studentId)
    } catch (error) {
      console.error('Error loading student attendance:', error)
      return []
    }
  }

  async getTeacherAttendanceByDate(teacherId: number, date: string): Promise<AttendanceRecord[]> {
    try {
      return await mysqlApi.getTeacherAttendanceByDate(teacherId, date)
    } catch (error) {
      console.error('Error loading teacher attendance by date:', error)
      return []
    }
  }

  async getTeacherAttendanceByCourse(teacherId: number, coursId: number, startDate: string, endDate: string): Promise<AttendanceRecord[]> {
    try {
      return await mysqlApi.getTeacherAttendanceByCourse(teacherId, coursId, startDate, endDate)
    } catch (error) {
      console.error('Error loading teacher attendance by course:', error)
      return []
    }
  }
}

export default new AttendanceService()
