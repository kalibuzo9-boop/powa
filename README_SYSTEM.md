# Système de Gestion de Présence QR Code - UCB Bukavu

## Vue d'ensemble
Ce système permet aux enseignants de générer des QR codes pour les séances de cours et aux étudiants de scanner ces codes pour confirmer leur présence.

## Fonctionnalités

### Pour les Enseignants
- **Authentification** : Connexion avec matricule et mot de passe
- **Génération de QR Code** : Création de sessions avec QR codes temporaires (5 minutes)
- **Suivi en Temps Réel** : Visualisation des présences en temps réel
- **Historique** : Consultation des présences par session

### Pour les Étudiants
- **Authentification** : Connexion avec matricule et mot de passe
- **Scan QR Code** : Confirmation de présence via QR code
- **Profil Étudiant** : Récupération des informations officielles UCB
- **Historique** : Consultation de l'historique personnel des présences

## Technologies Utilisées

### Frontend
- **Vue.js 3** : Framework JavaScript réactif
- **Vuetify 3** : Framework UI Material Design
- **TypeScript** : Typage statique pour JavaScript
- **Vue Router** : Navigation entre les pages
- **Axios** : Client HTTP pour les appels API
- **QRCode.js** : Génération de QR codes

### Backend
- **PHP** : Langage serveur
- **MySQL** : Base de données relationnelle
- **API REST** : Architecture d'API unifiée dans api.php

## Installation

### Prérequis
- Node.js 16+
- PHP 7.4+
- MySQL 5.7+
- Serveur web (Apache/Nginx)

### Configuration Frontend
```bash
npm install
npm run dev
```

### Configuration Backend
1. Placez `api.php` dans votre répertoire web
2. Créez la base de données MySQL :
```bash
mysql -u root -p < database_setup.sql
```
3. Configurez les paramètres de base de données dans `api.php`

## Comptes de Test

### Enseignants
- **Matricule** : ENS001 | **Mot de passe** : password123
- **Matricule** : ENS002 | **Mot de passe** : password123

### Étudiants
- **Matricule** : 05/23.07433 | **Mot de passe** : password123
- **Matricule** : 05/23.07434 | **Mot de passe** : password123
- **Matricule** : 05/23.07435 | **Mot de passe** : password123

## Flux d'Utilisation

### Processus Enseignant
1. Connexion avec matricule et mot de passe
2. Génération d'un QR code pour la séance
3. Affichage du QR code aux étudiants (5 minutes de validité)
4. Consultation des présences en temps réel

### Processus Étudiant
1. Connexion avec matricule et mot de passe
2. Scan du QR code affiché par l'enseignant
3. Confirmation automatique de la présence
4. Consultation de l'historique personnel

## API Endpoints

### Authentification
- `POST /api.php?action=login` : Connexion utilisateur

### Gestion des Sessions (Enseignant)
- `POST /api.php?action=generate_qr` : Génération de QR code
- `GET /api.php?action=list_presences` : Liste des présences

### Enregistrement Présence (Étudiant)
- `POST /api.php?action=check_attendance` : Enregistrement présence
- `GET /api.php?action=my_presences` : Historique personnel

### Intégration UCB
- `GET /api.php?action=getStudent` : Informations étudiant officiel
- `GET /api.php?action=getStructure` : Structure académique

## Sécurité

### Mesures Implémentées
- **Expiration des Tokens** : QR codes valides 5 minutes seulement
- **Hash des Mots de Passe** : Utilisation de `password_hash()` PHP
- **Validation des Sessions** : Vérification token + expiration
- **Unicité des Présences** : Un étudiant = une présence par session
- **CORS Sécurisé** : Headers appropriés pour les appels cross-origin

### Recommandations Production
- Utiliser HTTPS pour toutes les communications
- Implémenter une limitation du taux de requêtes
- Ajouter des logs de sécurité
- Utiliser des tokens JWT pour l'authentification
- Chiffrer les données sensibles en base

## Structure de Base de Données

```sql
enseignants (id, matricule, nom, password)
etudiants (id, matricule, nom, password)
sessions (id, session_id, enseignant_id, token, expiration)
presences (id, etudiant_id, session_id, date_heure)
```

## Maintenance

### Nettoyage Automatique
Exécutez périodiquement pour nettoyer les sessions expirées :
```sql
DELETE FROM sessions WHERE expiration < NOW();
```

### Monitoring
Surveillez les métriques suivantes :
- Nombre de sessions actives
- Taux de participation par cours
- Temps de réponse de l'API UCB
- Erreurs de connexion base de données

## Support
Pour toute question technique, consultez la documentation complète ou contactez l'équipe de développement.