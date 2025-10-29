import { supabase, type Session, type Presence, type Cours } from './supabase'

export interface CreateSessionData {
  enseignant_id: string
  cours_id?: string
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
    const { data, error } = await supabase
      .from('cours')
      .select('*')
      .order('titre')

    if (error) throw error
    return data || []
  }

  async getTeacherCourses(teacherId: string): Promise<Cours[]> {
    const { data, error } = await supabase
      .from('teacher_courses')
      .select('cours(*)')
      .eq('teacher_id', teacherId)

    if (error) throw error
    return data?.map((tc: any) => tc.cours) || []
  }

  async createSession(data: CreateSessionData): Promise<{ session: Session; qr_url: string }> {
    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    const token = Array.from(crypto.getRandomValues(new Uint8Array(16)))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('')

    const durationMinutes = data.duration_minutes || 5
    const expiration = new Date(Date.now() + durationMinutes * 60 * 1000).toISOString()

    const { data: session, error } = await supabase
      .from('sessions')
      .insert({
        session_id: sessionId,
        enseignant_id: data.enseignant_id,
        cours_id: data.cours_id,
        salle: data.salle,
        token,
        expiration
      })
      .select()
      .single()

    if (error) throw error

    const baseUrl = window.location.origin
    const qrUrl = `${baseUrl}/scan?session_id=${sessionId}&token=${token}`

    return { session, qr_url: qrUrl }
  }

  async validateSession(sessionId: string, token: string): Promise<{ valid: boolean; session?: Session; error?: string }> {
    const { data: session, error } = await supabase
      .from('sessions')
      .select('*')
      .eq('session_id', sessionId)
      .eq('token', token)
      .maybeSingle()

    if (error) {
      return { valid: false, error: error.message }
    }

    if (!session) {
      return { valid: false, error: 'Session invalide' }
    }

    const now = new Date()
    const expiration = new Date(session.expiration)

    if (now > expiration) {
      return { valid: false, error: 'Session expirée' }
    }

    return { valid: true, session }
  }

  async recordAttendance(studentId: string, sessionId: string): Promise<{ success: boolean; error?: string }> {
    try {
      const { data: existing } = await supabase
        .from('presences')
        .select('id')
        .eq('etudiant_id', studentId)
        .eq('session_id', sessionId)
        .maybeSingle()

      if (existing) {
        return { success: false, error: 'Présence déjà enregistrée pour cette session' }
      }

      const { error } = await supabase
        .from('presences')
        .insert({
          etudiant_id: studentId,
          session_id: sessionId,
          date_heure: new Date().toISOString()
        })

      if (error) {
        return { success: false, error: error.message }
      }

      return { success: true }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async getSessionAttendance(sessionId: string): Promise<AttendanceRecord[]> {
    const { data, error } = await supabase
      .from('presences')
      .select(`
        *,
        users:etudiant_id (
          matricule,
          nom,
          prenom
        )
      `)
      .eq('session_id', sessionId)
      .order('date_heure', { ascending: false })

    if (error) throw error

    return data?.map((p: any) => ({
      ...p,
      student_matricule: p.users?.matricule,
      student_name: `${p.users?.nom} ${p.users?.prenom || ''}`.trim()
    })) || []
  }

  async getStudentAttendance(studentId: string): Promise<AttendanceRecord[]> {
    const { data, error } = await supabase
      .from('presences')
      .select(`
        *,
        sessions:session_id (
          expiration,
          cours:cours_id (
            titre
          )
        )
      `)
      .eq('etudiant_id', studentId)
      .order('date_heure', { ascending: false })

    if (error) throw error

    return data?.map((p: any) => ({
      ...p,
      session_expiration: p.sessions?.expiration,
      course_name: p.sessions?.cours?.titre
    })) || []
  }

  async getTeacherAttendanceByDate(teacherId: string, date: string): Promise<AttendanceRecord[]> {
    const startOfDay = new Date(date)
    startOfDay.setHours(0, 0, 0, 0)

    const endOfDay = new Date(date)
    endOfDay.setHours(23, 59, 59, 999)

    const { data, error } = await supabase
      .from('presences')
      .select(`
        *,
        users:etudiant_id (
          matricule,
          nom,
          prenom
        ),
        sessions:session_id (
          enseignant_id,
          salle,
          cours:cours_id (
            titre,
            code
          )
        )
      `)
      .gte('date_heure', startOfDay.toISOString())
      .lte('date_heure', endOfDay.toISOString())

    if (error) throw error

    const filtered = data?.filter((p: any) => p.sessions?.enseignant_id === teacherId) || []

    return filtered.map((p: any) => ({
      ...p,
      student_matricule: p.users?.matricule,
      student_name: `${p.users?.nom} ${p.users?.prenom || ''}`.trim(),
      course_name: p.sessions?.cours?.titre
    }))
  }

  async getTeacherAttendanceByCourse(teacherId: string, coursId: string, startDate: string, endDate: string): Promise<AttendanceRecord[]> {
    const start = new Date(startDate)
    start.setHours(0, 0, 0, 0)

    const end = new Date(endDate)
    end.setHours(23, 59, 59, 999)

    const { data: sessions } = await supabase
      .from('sessions')
      .select('id')
      .eq('enseignant_id', teacherId)
      .eq('cours_id', coursId)
      .gte('created_at', start.toISOString())
      .lte('created_at', end.toISOString())

    if (!sessions || sessions.length === 0) return []

    const sessionIds = sessions.map(s => s.id)

    const { data, error } = await supabase
      .from('presences')
      .select(`
        *,
        users:etudiant_id (
          matricule,
          nom,
          prenom
        ),
        sessions:session_id (
          salle,
          cours:cours_id (
            titre
          )
        )
      `)
      .in('session_id', sessionIds)
      .order('date_heure', { ascending: false })

    if (error) throw error

    return data?.map((p: any) => ({
      ...p,
      student_matricule: p.users?.matricule,
      student_name: `${p.users?.nom} ${p.users?.prenom || ''}`.trim(),
      course_name: p.sessions?.cours?.titre
    })) || []
  }
}

export default new AttendanceService()
