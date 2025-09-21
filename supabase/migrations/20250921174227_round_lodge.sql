-- Database setup for UCB Attendance System
-- Run this script in your MySQL database

CREATE DATABASE IF NOT EXISTS ucb_attendance;
USE ucb_attendance;

-- Table for teachers
CREATE TABLE IF NOT EXISTS enseignants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    matricule VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for students
CREATE TABLE IF NOT EXISTS etudiants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    matricule VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for QR code sessions
CREATE TABLE IF NOT EXISTS sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(100) UNIQUE NOT NULL,
    enseignant_id INT NOT NULL,
    token VARCHAR(100) NOT NULL,
    expiration DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enseignant_id) REFERENCES enseignants(id) ON DELETE CASCADE
);

-- Table for attendance records
CREATE TABLE IF NOT EXISTS presences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    etudiant_id INT NOT NULL,
    session_id VARCHAR(100) NOT NULL,
    date_heure DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (etudiant_id) REFERENCES etudiants(id) ON DELETE CASCADE
);

-- Insert sample data for testing

-- Sample teachers (password is "password123" hashed)
INSERT INTO enseignants (matricule, nom, password) VALUES 
('ENS001', 'Professeur Martin KALUME', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('ENS002', 'Professeur Sarah MUKAMBA', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi')
ON DUPLICATE KEY UPDATE id=id;

-- Sample students (password is "password123" hashed)
INSERT INTO etudiants (matricule, nom, password) VALUES 
('05/23.07433', 'MUKOZI KAJABIKA BUGUGU', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('05/23.07434', 'AMANI BAPOLISI JEAN', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('05/23.07435', 'CATHERINE MUMBERE', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi')
ON DUPLICATE KEY UPDATE id=id;

-- Create indexes for better performance
CREATE INDEX idx_sessions_token ON sessions(token);
CREATE INDEX idx_sessions_expiration ON sessions(expiration);
CREATE INDEX idx_presences_session ON presences(session_id);
CREATE INDEX idx_presences_etudiant ON presences(etudiant_id);