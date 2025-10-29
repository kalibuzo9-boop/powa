/*
  # Add Sample Data for Testing

  ## Overview
  This migration adds sample users and test data to help with development and testing.

  ## Data Added
  1. Sample teachers with hashed passwords
  2. Sample students with hashed passwords
  3. Teacher-course assignments
  
  ## Notes
  - All passwords are hashed using bcrypt
  - Default password for all test accounts: "password123"
  - Sample courses already exist from previous migration
*/

-- Insert sample teachers
-- Password: password123 (hashed)
INSERT INTO users (matricule, email, password, nom, prenom, type, status, telephone) VALUES
  ('ENS001', 'kalume@ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'KALUME', 'Martin', 'teacher', 'active', '+243999000001'),
  ('ENS002', 'mukamba@ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MUKAMBA', 'Sarah', 'teacher', 'active', '+243999000002'),
  ('ENS003', 'kahindo@ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'KAHINDO BALUME', 'David', 'teacher', 'active', '+243999000003')
ON CONFLICT (matricule) DO NOTHING;

-- Insert teacher profiles
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
ON CONFLICT (user_id) DO NOTHING;

-- Insert sample students
INSERT INTO users (matricule, email, password, nom, prenom, type, status, telephone) VALUES
  ('05/23.07433', 'mukozi@student.ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MUKOZI KAJABIKA', 'BUGUGU', 'student', 'active', '+243999000100'),
  ('05/23.07434', 'amani@student.ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'AMANI BAPOLISI', 'Jean', 'student', 'active', '+243999000101'),
  ('05/23.07435', 'catherine@student.ucbukavu.ac.cd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MUMBERE', 'Catherine', 'student', 'active', '+243999000102')
ON CONFLICT (matricule) DO NOTHING;

-- Insert student profiles
INSERT INTO student_profiles (user_id, fullname, firstname, lastname, gender, filiere, orientation)
SELECT 
  u.id,
  u.nom || ' ' || COALESCE(u.prenom, ''),
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
ON CONFLICT (user_id) DO NOTHING;

-- Assign courses to teachers
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
ON CONFLICT (teacher_id, cours_id, annee_academique) DO NOTHING;

-- Assign specific courses to specific teachers
INSERT INTO teacher_courses (teacher_id, cours_id, annee_academique)
SELECT 
  (SELECT id FROM users WHERE matricule = 'ENS001'),
  (SELECT id FROM cours WHERE code = 'INFO301'),
  '2024-2025'
WHERE NOT EXISTS (
  SELECT 1 FROM teacher_courses tc
  WHERE tc.teacher_id = (SELECT id FROM users WHERE matricule = 'ENS001')
  AND tc.cours_id = (SELECT id FROM cours WHERE code = 'INFO301')
);

INSERT INTO teacher_courses (teacher_id, cours_id, annee_academique)
SELECT 
  (SELECT id FROM users WHERE matricule = 'ENS002'),
  (SELECT id FROM cours WHERE code = 'INFO401'),
  '2024-2025'
WHERE NOT EXISTS (
  SELECT 1 FROM teacher_courses tc
  WHERE tc.teacher_id = (SELECT id FROM users WHERE matricule = 'ENS002')
  AND tc.cours_id = (SELECT id FROM cours WHERE code = 'INFO401')
);