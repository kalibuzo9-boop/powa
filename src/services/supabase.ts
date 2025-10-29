import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export interface User {
  id: string
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
  id: string
  user_id: string
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
  id: string
  user_id: string
  departement?: string
  grade?: string
  piece_identite?: string
  email_institutionnel?: string
  validation_date?: string
  validated_by?: string
}

export interface Cours {
  id: string
  titre: string
  code?: string
  description?: string
  credits?: number
  departement?: string
  created_at: string
}

export interface Session {
  id: string
  session_id: string
  enseignant_id: string
  cours_id?: string
  token: string
  salle?: string
  expiration: string
  created_at: string
}

export interface Presence {
  id: string
  etudiant_id: string
  session_id: string
  date_heure: string
  created_at: string
}
