# Guide de Configuration - Application AfriJob

## 🚀 DÉMARRAGE RAPIDE

### Prérequis
- WampServer (ou XAMPP) avec MySQL
- Node.js 14+ 
- Flutter SDK
- Visual Studio Code ou Android Studio

---

## 📦 CONFIGURATION BASE DE DONNÉES

### 1. Importer la base de données dans phpMyAdmin
```bash
1. Ouvrir http://localhost/phpmyadmin
2. Créer une nouvelle base: bddiane_sp
3. Importer le fichier: bddiane_sp.sql
4. Vérifier les tables: utilisateurs, candidats, entreprises, offres, candidatures, conversations, messages, notifications, paiements, abonnements
```

### 2. Vérifier la connexion MySQL
```bash
- Host: localhost
- Port: 3306
- User: root
- Password: (vide par défaut)
- Database: bddiane_sp
```

---

## 🔧 CONFIGURATION BACKEND (Node.js)

### 1. Installer les dépendances
```bash
cd afrijob_backend
npm install
```

### 2. Vérifier le fichier .env
```bash
# afrijob_backend/.env
PORT=3001
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=bddiane_sp
JWT_SECRET=afrijob_super_secret_key_2024_change_this_in_production
JWT_EXPIRE=30d
```

### 3. Démarrer le serveur
```bash
# Mode développement
npm run dev

# Mode production
npm start
```

✅ Vous devez voir: `Serveur actif sur http://0.0.0.0:3001`

---

## 📱 CONFIGURATION FRONTEND (Flutter)

### 1. Installer les dépendances
```bash
cd ..
flutter pub get
```

### 2. Configurer l'URL du serveur
**Fichier:** `lib/services/api_service.dart`

```dart
// Ligne ~4
static const String baseUrl = 'http://localhost:3001/api';
```

**Options selon votre environnement:**
- **Windows/Web:** `http://localhost:3001/api`
- **Émulateur Android:** `http://10.0.2.2:3001/api` (Android Studio)
- **Téléphone réel:** `http://192.168.X.X:3001/api` (votre IP locale)

### 3. Vérifier pubspec.yaml
```bash
flutter pub get
```

### 4. Lancer l'application
```bash
flutter run

# Ou spécifier un appareil
flutter run -d chrome          # Web
flutter run -d android-emulator # Émulateur
flutter run -d <device-id>      # Appareil spécifique
```

---

## 🔐 COMPTES DE TEST

### Candidat
- **Email:** ephraim@example.com
- **Mot de passe:** password123
- **Profil:** KINDA Ephraim

### Entreprise
- **Email:** contact@techcorp.com
- **Mot de passe:** password123
- **Entreprise:** TechCorp SAS

---

## 📋 FONCTIONNALITÉS IMPLÉMENTÉES

### ✅ Authentification
- ✓ Inscription candidat/entreprise
- ✓ Connexion avec JWT
- ✓ Persistance de session
- ✓ Déconnexion

### ✅ Offres d'emploi
- ✓ Créer une offre (entreprise)
- ✓ Lister toutes les offres
- ✓ Rechercher/filtrer les offres
- ✓ Consulter les offres de mon entreprise
- ✓ Supprimer une offre

### ✅ Candidatures
- ✓ Postuler à une offre
- ✓ Voir mes candidatures
- ✓ Voir les candidatures reçues (entreprise)
- ✓ Mettre à jour le statut (Acceptée/Refusée)

### ✅ Messagerie
- ✓ Créer une conversation
- ✓ Lister les conversations
- ✓ Envoyer des messages
- ✓ Historique des messages

### ✅ Notifications
- ✓ Recevoir les notifications
- ✓ Marquer comme lues
- ✓ Supprimer les notifications

### ✅ Upload
- ✓ Télécharger CV, photos, documents
- ✓ Gestion des fichiers

---

## 🐛 CORRECTION DES ERREURS COURANTES

### Erreur: "Connection refused"
```
Vérifier que:
1. WampServer est démarré ✓
2. MySQL est actif ✓
3. Node.js serveur est lancé ✓
4. Port 3001 n'est pas utilisé: netstat -ano | find ":3001"
```

### Erreur: "Database not found"
```
1. Vérifier que bddiane_sp existe dans MySQL
2. Importer le fichier SQL:
   - phpMyAdmin → bddiane_sp → Importer
```

### Erreur: "API not responding"
```
1. Vérifier l'URL dans api_service.dart
2. Vérifier les logs du serveur Node.js
3. Vérifier CORS dans server.js
```

### Erreur: "Token invalide"
```
1. Vérifier JWT_SECRET dans .env
2. Vérifier que le token est correctement sauvegardé
3. Effacer les SharedPreferences et se reconnecter
```

---

## 📊 STRUCTURE DES FICHIERS

```
mon_application_job/
├── afrijob_backend/          # Backend Node.js
│   ├── server.js
│   ├── package.json
│   ├── .env
│   ├── config/
│   │   └── database.js       # Connexion MySQL
│   ├── controllers/
│   │   └── authController.js
│   ├── middleware/
│   │   └── auth.js           # Authentification JWT
│   ├── routes/
│   │   ├── auth.js
│   │   ├── offers.js
│   │   ├── applications.js
│   │   ├── messages.js
│   │   ├── notifications.js
│   │   └── upload.js
│   └── uploads/              # Dossier pour les fichiers
│
├── lib/                      # Frontend Flutter
│   ├── main.dart
│   ├── auth_screen.dart
│   ├── candidate_dashboard.dart
│   ├── company_dashboard.dart
│   ├── services/
│   │   ├── api_service.dart  # Requêtes HTTP
│   │   └── storage_service.dart
│   └── models/
│
└── bddiane_sp.sql           # Schéma base de données
```

---

## 🌐 ROUTES API DISPONIBLES

### Authentication
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `GET /api/auth/me` - Profil actuel
- `PUT /api/auth/profile` - Modifier le profil

### Offres
- `GET /api/offers` - Lister toutes les offres
- `GET /api/offers/my-offers` - Mes offres (entreprise)
- `GET /api/offers/:id` - Détail d'une offre
- `POST /api/offers` - Créer une offre
- `DELETE /api/offers/:id` - Supprimer une offre

### Candidatures
- `GET /api/applications/my-applications` - Mes candidatures
- `GET /api/applications/company-applications` - Candidatures reçues
- `POST /api/applications` - Postuler
- `PUT /api/applications/:id` - Mettre à jour le statut

### Messages
- `GET /api/messages/conversations` - Mes conversations
- `GET /api/messages/conversations/:id` - Messages d'une conversation
- `POST /api/messages` - Envoyer un message
- `POST /api/messages/start` - Démarrer une conversation

### Notifications
- `GET /api/notifications` - Lister
- `PUT /api/notifications/:id/read` - Marquer comme lu
- `PUT /api/notifications/mark/all` - Marquer tous comme lus
- `DELETE /api/notifications/:id` - Supprimer

### Upload
- `POST /api/upload` - Télécharger un fichier

---

## 💡 CONSEILS

1. **Développement:** Utilisez `npm run dev` pour avoir nodemon (redémarrage auto)
2. **Debugging:** Activez les logs dans les contrôleurs
3. **Testing:** Utilisez Postman pour tester les routes API
4. **Production:** Changez JWT_SECRET et configurez les variables d'environnement
5. **Mobile:** Testez avec un vrai téléphone avant la publication

---

## 📞 SUPPORT

Pour les erreurs ou questions:
1. Vérifier les logs du terminal (frontend et backend)
2. Consulter la console du navigateur (F12)
3. Vérifier le fichier de base de données dans phpMyAdmin

---

**✅ L'application est maintenant opérationnelle et prête à l'emploi!**
