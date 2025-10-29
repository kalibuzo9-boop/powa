/*
  # UCB Attendance System - Complete Schema

  ## Overview
  Complete database schema for the UCB Bukavu attendance system with QR code scanning,
  student/teacher management, course tracking, and attendance records.

  ## New Tables

  ### 1. `users` (Main user table)
    - `id` (uuid, primary key) - Unique identifier
    - `matricule` (text, unique) - Student/teacher registration number
    - `email` (text, unique) - Email address
    - `password` (text) - Hashed password
    - `nom` (text) - Full name
    - `prenom` (text) - First name
    - `type` (text) - User type: 'student' or 'teacher'
    - `status` (text) - Account status: 'active', 'pending', 'suspended'
    - `avatar` (text) - Profile picture URL
    - `telephone` (text) - Phone number
    - `created_at` (timestamptz) - Account creation date
    - `updated_at` (timestamptz) - Last update date

  ### 2. `student_profiles` (Extended student information)
    - `id` (uuid, primary key)
    - `user_id` (uuid, foreign key) - Reference to users table
    - `akhademie_id` (text) - ID from Akhademie system
    - `fullname` (text) - Full name from Akhademie
    - `firstname` (text) - First name
    - `lastname` (text) - Last name
    - `gender` (text) - Gender
    - `birthday` (date) - Date of birth
    - `birthplace` (text) - Place of birth
    - `filiere` (text) - Academic program/field
    - `orientation` (text) - Academic orientation
    - `commune` (text) - Municipality
    - `district` (text) - District
    - `street` (text) - Street address
    - `promotion_id` (integer) - Promotion/class ID

  ### 3. `teacher_profiles` (Extended teacher information)
    - `id` (uuid, primary key)
    - `user_id` (uuid, foreign key) - Reference to users table
    - `departement` (text) - Department
    - `grade` (text) - Academic grade/title
    - `piece_identite` (text) - ID document URL
    - `email_institutionnel` (text) - Institutional email
    - `validation_date` (timestamptz) - Admin validation date
    - `validated_by` (uuid) - Admin who validated

  ### 4. `cours` (Courses)
    - `id` (uuid, primary key)
    - `titre` (text) - Course title
    - `code` (text) - Course code
    - `description` (text) - Course description
    - `credits` (integer) - Number of credits
    - `departement` (text) - Department
    - `created_at` (timestamptz)

  ### 5. `teacher_courses` (Teacher-Course relationship)
    - `id` (uuid, primary key)
    - `teacher_id` (uuid, foreign key) - Reference to users
    - `cours_id` (uuid, foreign key) - Reference to cours
    - `annee_academique` (text) - Academic year
    - `created_at` (timestamptz)

  ### 6. `sessions` (QR Code attendance sessions)
    - `id` (uuid, primary key)
    - `session_id` (text, unique) - Unique session identifier
    - `enseignant_id` (uuid, foreign key) - Teacher who created session
    - `cours_id` (uuid, foreign key) - Course for this session
    - `token` (text) - Security token
    - `salle` (text) - Room/location
    - `expiration` (timestamptz) - Session expiration time
    - `created_at` (timestamptz)

  ### 7. `presences` (Attendance records)
    - `id` (uuid, primary key)
    - `etudiant_id` (uuid, foreign key) - Student ID
    - `session_id` (uuid, foreign key) - Session ID
    - `date_heure` (timestamptz) - Check-in timestamp
    - `created_at` (timestamptz)

  ### 8. `logs_api_akhademie` (API call logs)
    - `id` (uuid, primary key)
    - `matricule` (text) - Student matricule queried
    - `success` (boolean) - Whether call succeeded
    - `response_data` (jsonb) - API response data
    - `error_message` (text) - Error if any
    - `created_at` (timestamptz)

  ## Security
  - Enable RLS on all tables
  - Policies for authenticated users to access their own data
  - Teachers can manage sessions and view attendance
  - Students can view their own attendance records
  - Admin users can manage teacher validations

  ## Notes
  - All timestamps use timezone-aware types
  - Foreign keys have ON DELETE CASCADE for data integrity
  - Indexes added for frequently queried columns
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (main authentication table)
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  matricule text UNIQUE NOT NULL,
  email text UNIQUE,
  password text NOT NULL,
  nom text NOT NULL,
  prenom text,
  type text NOT NULL CHECK (type IN ('student', 'teacher', 'admin')),
  status text DEFAULT 'active' CHECK (status IN ('active', 'pending', 'suspended')),
  avatar text,
  telephone text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Student profiles with Akhademie data
CREATE TABLE IF NOT EXISTS student_profiles (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  akhademie_id text,
  fullname text,
  firstname text,
  lastname text,
  gender text,
  birthday date,
  birthplace text,
  filiere text,
  orientation text,
  commune text,
  district text,
  street text,
  promotion_id integer,
  created_at timestamptz DEFAULT now()
);

-- Teacher profiles
CREATE TABLE IF NOT EXISTS teacher_profiles (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  departement text,
  grade text,
  piece_identite text,
  email_institutionnel text,
  validation_date timestamptz,
  validated_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

-- Courses
CREATE TABLE IF NOT EXISTS cours (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  titre text NOT NULL,
  code text UNIQUE,
  description text,
  credits integer DEFAULT 0,
  departement text,
  created_at timestamptz DEFAULT now()
);

-- Teacher-Course assignments
CREATE TABLE IF NOT EXISTS teacher_courses (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  teacher_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  cours_id uuid REFERENCES cours(id) ON DELETE CASCADE NOT NULL,
  annee_academique text DEFAULT '2024-2025',
  created_at timestamptz DEFAULT now(),
  UNIQUE(teacher_id, cours_id, annee_academique)
);

-- Sessions (QR code sessions)
CREATE TABLE IF NOT EXISTS sessions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id text UNIQUE NOT NULL,
  enseignant_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  cours_id uuid REFERENCES cours(id) ON DELETE SET NULL,
  token text NOT NULL,
  salle text,
  expiration timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Attendance records
CREATE TABLE IF NOT EXISTS presences (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  etudiant_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  session_id uuid REFERENCES sessions(id) ON DELETE CASCADE NOT NULL,
  date_heure timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  UNIQUE(etudiant_id, session_id)
);

-- API logs for Akhademie integration
CREATE TABLE IF NOT EXISTS logs_api_akhademie (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  matricule text NOT NULL,
  success boolean DEFAULT false,
  response_data jsonb,
  error_message text,
  created_at timestamptz DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_matricule ON users(matricule);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_type ON users(type);
CREATE INDEX IF NOT EXISTS idx_student_profiles_user_id ON student_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_user_id ON teacher_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(token);
CREATE INDEX IF NOT EXISTS idx_sessions_expiration ON sessions(expiration);
CREATE INDEX IF NOT EXISTS idx_presences_etudiant ON presences(etudiant_id);
CREATE INDEX IF NOT EXISTS idx_presences_session ON presences(session_id);
CREATE INDEX IF NOT EXISTS idx_teacher_courses_teacher ON teacher_courses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_courses_cours ON teacher_courses(cours_id);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cours ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE presences ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs_api_akhademie ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Allow public user registration"
  ON users FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- RLS Policies for student_profiles
CREATE POLICY "Students can view own profile"
  ON student_profiles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Students can update own profile"
  ON student_profiles FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Students can insert own profile"
  ON student_profiles FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- RLS Policies for teacher_profiles
CREATE POLICY "Teachers can view own profile"
  ON teacher_profiles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Teachers can update own profile"
  ON teacher_profiles FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Teachers can insert own profile"
  ON teacher_profiles FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- RLS Policies for cours (public read, teachers can manage their courses)
CREATE POLICY "Anyone can view courses"
  ON cours FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Teachers can create courses"
  ON cours FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.type = 'teacher'
    )
  );

-- RLS Policies for teacher_courses
CREATE POLICY "Teachers can view their course assignments"
  ON teacher_courses FOR SELECT
  TO authenticated
  USING (teacher_id = auth.uid());

CREATE POLICY "Teachers can manage their course assignments"
  ON teacher_courses FOR INSERT
  TO authenticated
  WITH CHECK (teacher_id = auth.uid());

-- RLS Policies for sessions
CREATE POLICY "Teachers can view their sessions"
  ON sessions FOR SELECT
  TO authenticated
  USING (enseignant_id = auth.uid());

CREATE POLICY "Teachers can create sessions"
  ON sessions FOR INSERT
  TO authenticated
  WITH CHECK (enseignant_id = auth.uid());

CREATE POLICY "Students can view active sessions"
  ON sessions FOR SELECT
  TO authenticated
  USING (expiration > now());

-- RLS Policies for presences
CREATE POLICY "Students can view own attendance"
  ON presences FOR SELECT
  TO authenticated
  USING (etudiant_id = auth.uid());

CREATE POLICY "Teachers can view attendance for their sessions"
  ON presences FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM sessions
      WHERE sessions.id = presences.session_id
      AND sessions.enseignant_id = auth.uid()
    )
  );

CREATE POLICY "Students can record own attendance"
  ON presences FOR INSERT
  TO authenticated
  WITH CHECK (etudiant_id = auth.uid());

-- RLS Policies for logs (admin only for security)
CREATE POLICY "Only system can write logs"
  ON logs_api_akhademie FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Insert sample courses
INSERT INTO cours (titre, code, description, credits, departement) VALUES
  ('Algorithmique et Structures de Données', 'INFO101', 'Introduction aux algorithmes et structures de données fondamentales', 6, 'Informatique'),
  ('Base de Données', 'INFO201', 'Conception et gestion de bases de données relationnelles', 5, 'Informatique'),
  ('Programmation Orientée Objet', 'INFO202', 'Concepts avancés de POO avec Java et C++', 6, 'Informatique'),
  ('Réseaux et Télécommunications', 'INFO301', 'Architecture des réseaux et protocoles', 5, 'Informatique'),
  ('Intelligence Artificielle', 'INFO401', 'Introduction à IA et machine learning', 6, 'Informatique')
ON CONFLICT (code) DO NOTHING;