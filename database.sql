-- ============================================
-- UCB BUKAVU - ATTENDANCE SYSTEM DATABASE
-- ============================================
-- Description: Complete MySQL database schema for the UCB Bukavu attendance management system
-- Version: 1.0
-- Date: 2025-10-29
-- ============================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS ucb_attendance CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ucb_attendance;

-- ============================================
-- TABLE: users (Main authentication table)
-- ============================================
-- Stores all users (students, teachers, admins)
CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  matricule VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE DEFAULT NULL,
  password VARCHAR(255) NOT NULL,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) DEFAULT NULL,
  type ENUM('student', 'teacher', 'admin') NOT NULL,
  status ENUM('active', 'pending', 'suspended') DEFAULT 'active',
  avatar VARCHAR(500) DEFAULT NULL,
  telephone VARCHAR(20) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_matricule (matricule),
  INDEX idx_email (email),
  INDEX idx_type (type),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: student_profiles (Extended student information)
-- ============================================
-- Stores additional information for students from Akhademie system
CREATE TABLE IF NOT EXISTS student_profiles (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL UNIQUE,
  akhademie_id VARCHAR(50) DEFAULT NULL,
  fullname VARCHAR(200) DEFAULT NULL,
  firstname VARCHAR(100) DEFAULT NULL,
  lastname VARCHAR(100) DEFAULT NULL,
  gender ENUM('M', 'F', 'Autre') DEFAULT NULL,
  birthday DATE DEFAULT NULL,
  birthplace VARCHAR(100) DEFAULT NULL,
  filiere VARCHAR(100) DEFAULT NULL,
  orientation VARCHAR(100) DEFAULT NULL,
  commune VARCHAR(100) DEFAULT NULL,
  district VARCHAR(100) DEFAULT NULL,
  street VARCHAR(200) DEFAULT NULL,
  promotion_id INT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_akhademie_id (akhademie_id),
  INDEX idx_promotion (promotion_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: teacher_profiles (Extended teacher information)
-- ============================================
-- Stores additional information for teachers
CREATE TABLE IF NOT EXISTS teacher_profiles (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL UNIQUE,
  departement VARCHAR(100) DEFAULT NULL,
  grade VARCHAR(100) DEFAULT NULL,
  piece_identite VARCHAR(500) DEFAULT NULL,
  email_institutionnel VARCHAR(255) DEFAULT NULL,
  validation_date TIMESTAMP NULL DEFAULT NULL,
  validated_by INT UNSIGNED DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (validated_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_departement (departement)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: cours (Courses)
-- ============================================
-- Stores all available courses
CREATE TABLE IF NOT EXISTS cours (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  titre VARCHAR(200) NOT NULL,
  code VARCHAR(20) UNIQUE DEFAULT NULL,
  description TEXT DEFAULT NULL,
  credits INT DEFAULT 0,
  departement VARCHAR(100) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_code (code),
  INDEX idx_departement (departement)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: teacher_courses (Teacher-Course assignments)
-- ============================================
-- Links teachers to their assigned courses
CREATE TABLE IF NOT EXISTS teacher_courses (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  teacher_id INT UNSIGNED NOT NULL,
  cours_id INT UNSIGNED NOT NULL,
  annee_academique VARCHAR(20) DEFAULT '2024-2025',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (cours_id) REFERENCES cours(id) ON DELETE CASCADE,
  UNIQUE KEY unique_teacher_course_year (teacher_id, cours_id, annee_academique),
  INDEX idx_teacher_id (teacher_id),
  INDEX idx_cours_id (cours_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: sessions (QR Code attendance sessions)
-- ============================================
-- Stores attendance sessions created by teachers
CREATE TABLE IF NOT EXISTS sessions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  session_id VARCHAR(100) UNIQUE NOT NULL,
  enseignant_id INT UNSIGNED NOT NULL,
  cours_id INT UNSIGNED DEFAULT NULL,
  token VARCHAR(64) NOT NULL,
  salle VARCHAR(100) DEFAULT NULL,
  expiration DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (enseignant_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (cours_id) REFERENCES cours(id) ON DELETE SET NULL,
  INDEX idx_session_id (session_id),
  INDEX idx_token (token),
  INDEX idx_expiration (expiration),
  INDEX idx_enseignant_id (enseignant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: presences (Attendance records)
-- ============================================
-- Stores student attendance records for sessions
CREATE TABLE IF NOT EXISTS presences (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  etudiant_id INT UNSIGNED NOT NULL,
  session_id INT UNSIGNED NOT NULL,
  date_heure DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (etudiant_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
  UNIQUE KEY unique_student_session (etudiant_id, session_id),
  INDEX idx_etudiant_id (etudiant_id),
  INDEX idx_session_id (session_id),
  INDEX idx_date_heure (date_heure)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: logs_api_akhademie (API call logs)
-- ============================================
-- Logs calls to Akhademie external API
CREATE TABLE IF NOT EXISTS logs_api_akhademie (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  matricule VARCHAR(50) NOT NULL,
  success BOOLEAN DEFAULT FALSE,
  response_data JSON DEFAULT NULL,
  error_message TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_matricule (matricule),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SAMPLE DATA: Courses
-- ============================================
INSERT INTO cours (titre, code, description, credits, departement) VALUES
  ('Algorithmique et Structures de Données', 'INFO101', 'Introduction aux algorithmes et structures de données fondamentales', 6, 'Informatique'),
  ('Base de Données', 'INFO201', 'Conception et gestion de bases de données relationnelles', 5, 'Informatique'),
  ('Programmation Orientée Objet', 'INFO202', 'Concepts avancés de POO avec Java et C++', 6, 'Informatique'),
  ('Réseaux et Télécommunications', 'INFO301', 'Architecture des réseaux et protocoles', 5, 'Informatique'),
  ('Intelligence Artificielle', 'INFO401', 'Introduction à IA et machine learning', 6, 'Informatique'),
  ('Développement Web', 'INFO301', 'HTML, CSS, JavaScript, PHP et frameworks modernes', 5, 'Informatique'),
  ('Génie Logiciel', 'INFO302', 'Méthodes de conception et développement de logiciels', 6, 'Informatique'),
  ('Sécurité Informatique', 'INFO402', 'Cryptographie, sécurité réseau et des applications', 5, 'Informatique')
ON DUPLICATE KEY UPDATE titre = VALUES(titre);

-- ============================================
-- SAMPLE DATA: Teachers
-- ============================================
-- Default password for all sample accounts: "password123"
-- Hash generated with bcrypt: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
INSERT INTO users (matricule, email, password, nom, prenom, type, status, telephone) VALUES
  ('ENS001', 'kalume@ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'KALUME', 'Martin', 'teacher', 'active', '+243999000001'),
  ('ENS002', 'mukamba@ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MUKAMBA', 'Sarah', 'teacher', 'active', '+243999000002'),
  ('ENS003', 'kahindo@ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'KAHINDO BALUME', 'David', 'teacher', 'active', '+243999000003')
ON DUPLICATE KEY UPDATE email = VALUES(email);

-- ============================================
-- SAMPLE DATA: Teacher Profiles
-- ============================================
INSERT INTO teacher_profiles (user_id, departement, grade, email_institutionnel)
SELECT
  u.id,
  'Informatique',
  CASE
    WHEN u.matricule = 'ENS001' THEN 'Professeur'
    WHEN u.matricule = 'ENS002' THEN 'Chef de Travaux'
    ELSE 'Assistant'
  END,
  u.email
FROM users u
WHERE u.type = 'teacher' AND u.matricule IN ('ENS001', 'ENS002', 'ENS003')
ON DUPLICATE KEY UPDATE departement = VALUES(departement);

-- ============================================
-- SAMPLE DATA: Students
-- ============================================
INSERT INTO users (matricule, email, password, nom, prenom, type, status, telephone) VALUES
  ('05/23.07433', 'mukozi@student.ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MUKOZI KAJABIKA', 'BUGUGU', 'student', 'active', '+243999000100'),
  ('05/23.07434', 'amani@student.ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'AMANI BAPOLISI', 'Jean', 'student', 'active', '+243999000101'),
  ('05/23.07435', 'catherine@student.ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MUMBERE', 'Catherine', 'student', 'active', '+243999000102')
ON DUPLICATE KEY UPDATE email = VALUES(email);

-- ============================================
-- SAMPLE DATA: Student Profiles
-- ============================================
INSERT INTO student_profiles (user_id, fullname, firstname, lastname, gender, filiere, orientation)
SELECT
  u.id,
  CONCAT(u.nom, ' ', COALESCE(u.prenom, '')),
  u.prenom,
  u.nom,
  CASE
    WHEN u.matricule = '05/23.07435' THEN 'F'
    ELSE 'M'
  END,
  'Informatique',
  'Génie Logiciel'
FROM users u
WHERE u.type = 'student' AND u.matricule IN ('05/23.07433', '05/23.07434', '05/23.07435')
ON DUPLICATE KEY UPDATE fullname = VALUES(fullname);

-- ============================================
-- SAMPLE DATA: Teacher Course Assignments
-- ============================================
INSERT INTO teacher_courses (teacher_id, cours_id, annee_academique)
SELECT
  u.id,
  c.id,
  '2024-2025'
FROM users u
CROSS JOIN cours c
WHERE u.type = 'teacher'
  AND u.matricule IN ('ENS001', 'ENS002', 'ENS003')
  AND c.code IN ('INFO101', 'INFO201', 'INFO202')
ON DUPLICATE KEY UPDATE annee_academique = VALUES(annee_academique);

-- ============================================
-- DATABASE INFORMATION
-- ============================================
-- Database: ucb_attendance
-- Tables: 8
-- Sample Data: 3 teachers, 3 students, 8 courses
-- Default Password: password123
--
-- To use this database:
-- 1. Import this file: mysql -u root -p < database.sql
-- 2. Configure api.php with database credentials
-- 3. Update .env file with API endpoint
-- ============================================
