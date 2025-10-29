# Guide d'Utilisation - Système de Présence UCB Bukavu

## Vue d'Ensemble

Système moderne de gestion des présences pour l'Université Catholique de Bukavu utilisant des QR codes dynamiques.

## Fonctionnalités Principales

### Pour les Étudiants

1. **Inscription Automatique via API Akhademie**
   - Saisie du matricule (ex: 05/23.07433)
   - Récupération automatique des informations depuis l'API UCB
   - Validation et complétion des données
   - Création instantanée du compte

2. **Scan QR et Enregistrement de Présence**
   - Scan du QR code généré par le professeur
   - Redirection intelligente vers inscription si non connecté
   - Enregistrement automatique de la présence

3. **Historique des Présences**
   - Consultation de toutes les présences
   - Filtrage par cours
   - Export de données

### Pour les Enseignants

1. **Inscription avec Validation Admin**
   - Formulaire complet avec informations professionnelles
   - Statut "en attente" jusqu'à validation
   - Notification par email après validation

2. **Création de Sessions avec Cours**
   - Sélection du cours enseigné
   - Indication de la salle (optionnel)
   - Génération de QR code valide 5 minutes
   - Timer de session en temps réel

3. **Suivi des Présences en Direct**
   - Liste actualisée automatiquement toutes les 10 secondes
   - Compteur de présences
   - Informations détaillées par étudiant

4. **Export PDF des Présences**
   - Sélection du cours
   - Choix de la date
   - Génération PDF professionnel avec en-tête UCB
   - Tableau complet avec signatures

## Architecture Technique

### Base de Données (Supabase)

#### Tables Principales
- `users` : Utilisateurs (étudiants, professeurs, admin)
- `student_profiles` : Profils étudiants étendus
- `teacher_profiles` : Profils enseignants
- `cours` : Catalogue des cours
- `teacher_courses` : Assignations professeur-cours
- `sessions` : Sessions QR avec expiration
- `presences` : Enregistrements de présence
- `logs_api_akhademie` : Logs des appels API

#### Sécurité (RLS)
- Politiques strictes Row Level Security
- Accès limité aux données personnelles
- Validation des permissions par type d'utilisateur

### Frontend (Vue 3 + TypeScript + Vuetify)

#### Services
- `auth.service.ts` : Authentification et inscription
- `attendance.service.ts` : Gestion des sessions et présences
- `pdf.service.ts` : Génération de PDF
- `supabase.ts` : Client Supabase configuré

#### Pages
- `/login` : Connexion
- `/signup-student` : Inscription étudiant
- `/signup-teacher` : Inscription enseignant
- `/scan` : Page de scan QR (avec redirection)
- `/student-dashboard` : Tableau de bord étudiant
- `/teacher-dashboard` : Tableau de bord enseignant

## Comptes de Test

### Enseignants
- **Matricule:** ENS001 | **Mot de passe:** password123
- **Matricule:** ENS002 | **Mot de passe:** password123
- **Matricule:** ENS003 | **Mot de passe:** password123

### Étudiants
- **Matricule:** 05/23.07433 | **Mot de passe:** password123
- **Matricule:** 05/23.07434 | **Mot de passe:** password123
- **Matricule:** 05/23.07435 | **Mot de passe:** password123

## Workflow Principal

### Scénario 1: Étudiant avec Compte

1. Professeur se connecte
2. Professeur sélectionne un cours
3. Professeur génère un QR code
4. Étudiant scanne le QR code
5. Étudiant se connecte si nécessaire
6. Présence enregistrée automatiquement

### Scénario 2: Nouvel Étudiant

1. Professeur génère un QR code
2. Étudiant scanne le QR code
3. Système détecte l'absence de compte
4. Redirection vers inscription
5. Étudiant saisit son matricule
6. Données récupérées depuis API Akhademie
7. Étudiant complète et valide
8. Compte créé → Connexion automatique
9. Retour au scan → Présence enregistrée

### Scénario 3: Export PDF

1. Professeur va dans "Exporter les Présences"
2. Sélectionne un cours
3. Choisit une date
4. Clique sur "Exporter PDF"
5. PDF généré avec en-tête UCB et tableau complet

## Design et UX

### Palette de Couleurs UCB
- **Primaire:** #003366 (Bleu UCB)
- **Secondaire:** #1abc9c (Vert émeraude)
- **Accent:** #f39c12 (Orange)
- **Succès:** #27ae60
- **Erreur:** #e74c3c

### Animations
- Transitions fluides entre les vues
- Hover effects sur les cartes
- Loading states animés
- Toasts de notifications

### Responsive Design
- Optimisé mobile, tablette et desktop
- Breakpoints Vuetify standard
- Interface adaptative

## Configuration Environnement

Variables dans `.env`:
```
VITE_SUPABASE_URL=https://votre-projet.supabase.co
VITE_SUPABASE_ANON_KEY=votre-cle-anon
```

## Commandes

```bash
# Installation
npm install

# Développement
npm run dev

# Build production
npm run build

# Preview
npm run preview
```

## Sécurité

- Mots de passe hashés avec bcrypt (10 rounds)
- Tokens de session sécurisés
- Validation côté serveur (RLS)
- Protection CORS
- Expiration automatique des sessions QR

## Support et Contact

Pour toute question technique ou fonctionnelle, contactez l'équipe de développement.

---

**Université Catholique de Bukavu**
*Système de Présence par QR Code - 2025*
