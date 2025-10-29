# UCB Bukavu - Système de Gestion des Présences

Système de gestion des présences avec QR Code pour l'Université Catholique de Bukavu.

## Technologies

- **Frontend**: Vue 3 + TypeScript + Vite + Vuetify
- **Backend**: PHP + MySQL
- **Authentification**: Système personnalisé avec bcrypt
- **Fonctionnalités**: Génération QR Code, Scan de présences, Export PDF

## Installation

### Prérequis

- Node.js (v18 ou supérieur)
- PHP 7.4+ avec PDO MySQL
- MySQL 5.7+ ou MariaDB 10.3+
- Serveur web (Apache ou Nginx recommandé)

### 1. Configuration de la Base de Données

Importez le fichier `database.sql` dans votre base MySQL:

```bash
mysql -u root -p < database.sql
```

Ou via phpMyAdmin:
1. Créez une base de données nommée `ucb_attendance`
2. Importez le fichier `database.sql`

Le fichier SQL contient:
- Toutes les tables nécessaires
- 8 cours d'exemple
- 3 enseignants de test
- 3 étudiants de test
- Mot de passe par défaut: `password123`

### 2. Configuration du Backend PHP

Éditez le fichier `api.php` (lignes 27-30) avec vos informations de connexion MySQL:

```php
$host = 'localhost';
$dbname = 'ucb_attendance';
$username = 'root';
$password = '';
```

Placez le fichier `api.php` dans le répertoire de votre serveur web:
- XAMPP/WAMP: `C:\xampp\htdocs\`
- Linux: `/var/www/html/`

### 3. Configuration du Frontend

Créez un fichier `.env` à la racine du projet:

```env
VITE_API_URL=http://localhost/api.php
```

Ajustez l'URL selon votre configuration serveur.

### 4. Installation des Dépendances

```bash
npm install
```

### 5. Développement

```bash
npm run dev
```

L'application sera accessible sur `http://localhost:5173`

### 6. Build Production

```bash
npm run build
```

Les fichiers de production seront générés dans le dossier `dist/`

## Comptes de Test

### Enseignants
- Matricule: `ENS001` / Password: `password123` - Prof. KALUME Martin
- Matricule: `ENS002` / Password: `password123` - CT. MUKAMBA Sarah
- Matricule: `ENS003` / Password: `password123` - Ass. KAHINDO BALUME David

### Étudiants
- Matricule: `05/23.07433` / Password: `password123` - MUKOZI KAJABIKA BUGUGU
- Matricule: `05/23.07434` / Password: `password123` - AMANI BAPOLISI Jean
- Matricule: `05/23.07435` / Password: `password123` - MUMBERE Catherine

## Fonctionnalités

### Pour les Enseignants
- Génération de QR Code de présence (durée: 5 minutes)
- Sélection du cours et de la salle
- Visualisation en temps réel des présences
- Export PDF des présences par date ou cours
- Gestion de plusieurs cours

### Pour les Étudiants
- Scan du QR Code pour enregistrer la présence
- Consultation de l'historique des présences
- Profil avec informations Akhademie (si disponible)

### Inscription
- **Étudiants**: Intégration avec l'API Akhademie UCB pour validation du matricule
- **Enseignants**: Inscription avec email institutionnel (validation admin requise)

## Structure de la Base de Données

### Tables Principales
- `users` - Utilisateurs (étudiants, enseignants, admins)
- `student_profiles` - Profils étendus étudiants
- `teacher_profiles` - Profils étendus enseignants
- `cours` - Liste des cours
- `teacher_courses` - Attribution cours-enseignants
- `sessions` - Sessions QR Code de présence
- `presences` - Enregistrements de présences
- `logs_api_akhademie` - Logs d'appels API Akhademie

## API Endpoints

### Authentification
- `POST /auth/login` - Connexion
- `POST /auth/register/student` - Inscription étudiant
- `POST /auth/register/teacher` - Inscription enseignant
- `GET /auth/check-matricule` - Vérification matricule

### Cours
- `GET /courses` - Liste de tous les cours
- `GET /courses/teacher?teacher_id={id}` - Cours d'un enseignant

### Sessions
- `POST /sessions` - Créer une session QR
- `GET /sessions/validate?session_id={id}&token={token}` - Valider session

### Présences
- `POST /attendance/record` - Enregistrer présence
- `GET /attendance/session?session_id={id}` - Présences d'une session
- `GET /attendance/student?student_id={id}` - Présences d'un étudiant
- `GET /attendance/teacher/date?teacher_id={id}&date={date}` - Par date
- `GET /attendance/teacher/course?teacher_id={id}&cours_id={id}&start_date={date}&end_date={date}` - Par cours

### Proxy API Externe
- `GET /external/student?matricule={mat}` - Info étudiant Akhademie
- `GET /external/structure` - Structure académique UCB

## Sécurité

- Mots de passe hashés avec bcrypt (cost: 10)
- Prepared statements pour prévenir les injections SQL
- Validation des tokens de session avec expiration
- CORS configuré pour accepter toutes les origines (à restreindre en production)
- Vérification de l'unicité des présences (un étudiant = une présence par session)

## Support Navigateurs

- Chrome/Edge (recommandé)
- Firefox
- Safari
- Opera

## Contribution

Développé pour l'UCB Bukavu - Faculté d'Informatique

## License

MIT License
