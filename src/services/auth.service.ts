import { supabase, type User, type StudentProfile, type TeacherProfile } from './supabase'
import bcrypt from 'bcryptjs'

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
      const { data: users, error } = await supabase
        .from('users')
        .select('*')
        .eq('matricule', credentials.matricule)
        .maybeSingle()

      if (error) {
        return { success: false, error: error.message }
      }

      if (!users) {
        return { success: false, error: 'Matricule ou mot de passe incorrect' }
      }

      const isValidPassword = await bcrypt.compare(credentials.password, users.password)

      if (!isValidPassword) {
        return { success: false, error: 'Matricule ou mot de passe incorrect' }
      }

      if (users.status !== 'active') {
        return { success: false, error: 'Compte en attente de validation ou suspendu' }
      }

      const userWithoutPassword = { ...users }
      delete (userWithoutPassword as any).password

      return { success: true, user: userWithoutPassword }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async registerStudent(data: RegisterStudentData): Promise<{ success: boolean; user?: User; error?: string }> {
    try {
      const hashedPassword = await bcrypt.hash(data.password, 10)

      const { data: existingUser } = await supabase
        .from('users')
        .select('id')
        .eq('matricule', data.matricule)
        .maybeSingle()

      if (existingUser) {
        return { success: false, error: 'Ce matricule est déjà enregistré' }
      }

      const { data: newUser, error: userError } = await supabase
        .from('users')
        .insert({
          matricule: data.matricule,
          password: hashedPassword,
          nom: data.nom,
          prenom: data.prenom,
          email: data.email,
          telephone: data.telephone,
          type: 'student',
          status: 'active',
          avatar: data.akhademie_data?.avatar
        })
        .select()
        .single()

      if (userError) {
        return { success: false, error: userError.message }
      }

      if (data.akhademie_data) {
        const profileData: Partial<StudentProfile> = {
          user_id: newUser.id,
          akhademie_id: data.akhademie_data.matricule,
          fullname: data.akhademie_data.fullname,
          firstname: data.akhademie_data.firstname,
          lastname: data.akhademie_data.lastname,
          gender: data.akhademie_data.gender,
          birthday: data.akhademie_data.birthday,
          birthplace: data.akhademie_data.birthplace,
          filiere: data.akhademie_data.schoolFilieres?.shortName,
          orientation: data.akhademie_data.schoolOrientations?.title,
          commune: data.akhademie_data.commune,
          district: data.akhademie_data.district,
          street: data.akhademie_data.street,
          promotion_id: data.akhademie_data.promotionId
        }

        await supabase
          .from('student_profiles')
          .insert(profileData)

        await supabase
          .from('logs_api_akhademie')
          .insert({
            matricule: data.matricule,
            success: true,
            response_data: data.akhademie_data
          })
      }

      const userWithoutPassword = { ...newUser }
      delete (userWithoutPassword as any).password

      return { success: true, user: userWithoutPassword }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async registerTeacher(data: RegisterTeacherData): Promise<{ success: boolean; user?: User; error?: string }> {
    try {
      const hashedPassword = await bcrypt.hash(data.password, 10)

      const { data: existingUser } = await supabase
        .from('users')
        .select('id')
        .eq('matricule', data.matricule)
        .maybeSingle()

      if (existingUser) {
        return { success: false, error: 'Ce matricule est déjà enregistré' }
      }

      const { data: newUser, error: userError } = await supabase
        .from('users')
        .insert({
          matricule: data.matricule,
          password: hashedPassword,
          nom: data.nom,
          prenom: data.prenom,
          email: data.email,
          telephone: data.telephone,
          type: 'teacher',
          status: 'pending'
        })
        .select()
        .single()

      if (userError) {
        return { success: false, error: userError.message }
      }

      const profileData: Partial<TeacherProfile> = {
        user_id: newUser.id,
        departement: data.departement,
        grade: data.grade,
        email_institutionnel: data.email_institutionnel
      }

      await supabase
        .from('teacher_profiles')
        .insert(profileData)

      const userWithoutPassword = { ...newUser }
      delete (userWithoutPassword as any).password

      return { success: true, user: userWithoutPassword }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async checkMatriculeExists(matricule: string): Promise<boolean> {
    const { data } = await supabase
      .from('users')
      .select('id')
      .eq('matricule', matricule)
      .maybeSingle()

    return !!data
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
