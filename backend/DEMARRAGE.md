# 🚀 AfriJob — Guide de démarrage complet

## Architecture

```
Flutter (flutter run)
       │
       │  HTTP :3001
       ▼
  Node.js backend  (ce dossier)
       │
       │  SQL
       ▼
  MySQL → bddiane_sp
```

---

## ÉTAPE 1 — Préparer MySQL

1. Ouvre **phpMyAdmin** (http://localhost/phpmyadmin)
2. Importe le fichier `bddiane_sp.sql` si ce n'est pas déjà fait
3. Vérifie que la base `bddiane_sp` existe avec ses tables

---

## ÉTAPE 2 — Configurer le fichier `.env`

Ouvre `.env` et adapte si besoin :

```env
PORT=3001
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=          ← laisse vide si pas de mot de passe MySQL
DB_NAME=bddiane_sp
JWT_SECRET=afrijob_super_secret_key_2024_change_this_in_production
JWT_EXPIRE=30d
```

---

## ÉTAPE 3 — Installer les dépendances Node.js

Dans un terminal, dans ce dossier :

```bash
npm install
```

---

## ÉTAPE 4 — Démarrer le serveur

### Mode Développement (avec nodemon - redémarrage auto)
```bash
npm run dev
```

### Mode Production
```bash
npm start
```

✅ Vous devez voir :
```
✅ Connecté à MySQL — base: bddiane_sp
Serveur actif sur http://0.0.0.0:3001
```

---

## ÉTAPE 5 — Tester les routes (Optionnel avec Postman)

### 1. Inscription
```
POST http://localhost:3001/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "userType": "candidat",
  "nom": "Test User",
  "telephone": "+226 70 00 00 00",
  "filiere": "Informatique",
  "age": 25
}
```

### 2. Connexion
```
POST http://localhost:3001/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

---

## ⚠️ DÉPANNAGE

| Erreur | Solution |
|--------|----------|
| `Error: connect ECONNREFUSED 127.0.0.1:3306` | WampServer/MySQL n'est pas lancé |
| `ER_NO_DB_ERROR: No database selected` | Importer bddiane_sp.sql dans phpMyAdmin |
| `EADDRINUSE: address already in use :::3001` | Port 3001 déjà utilisé. Tuer le process: `netstat -ano \| find ":3001"` puis `taskkill /PID <PID> /F` |
| `Token invalide ou expiré` | JWT_SECRET dans .env ne correspond pas |
| `Erreur lors de l'inscription` | Vérifier les champs requis dans la requête |

---

## 📱 Connexion depuis Flutter

L'application Flutter doit utiliser :

**Windows/Web:**
```dart
static const String baseUrl = 'http://localhost:3001/api';
```

**Émulateur Android:**
```dart
static const String baseUrl = 'http://10.0.2.2:3001/api';
```

**Téléphone réel (même réseau):**
```dart
static const String baseUrl = 'http://192.168.X.X:3001/api'; // Remplacer par votre IP
```

---

## 🔐 Comptes de test inclus

Les données de test sont dans `data/users.json` (optionnel) ou à créer via l'API.

**Exemple:**
- Email: `test@example.com`
- Mot de passe: `password123`

---

## ✅ Toutes les routes sont disponibles et testées!

Routes principales:
- ✅ `/api/auth/*` — Authentification
- ✅ `/api/offers/*` — Offres d'emploi
- ✅ `/api/applications/*` — Candidatures
- ✅ `/api/messages/*` — Messagerie
- ✅ `/api/notifications/*` — Notifications
- ✅ `/api/upload` — Upload de fichiers

---

## ÉTAPE 4 — Démarrer le backend

```bash
node server.js
```

Tu dois voir :
```
╔══════════════════════════════════════════════╗
║         🚀  AFRIJOB BACKEND DÉMARRÉ          ║
╚══════════════════════════════════════════════╝
✅ Connecté à MySQL — base: bddiane_sp
```

> Pour relancer automatiquement à chaque modification :
> ```bash
> npx nodemon server.js
> ```

---

## ÉTAPE 5 — Tester que tout fonctionne (AVANT Flutter)

### Test rapide dans le navigateur
Ouvre : http://localhost:3001/api/health

Tu dois voir :
```json
{ "status": "OK", "message": "✅ AfriJob backend est en marche" }
```

### Tests avec curl (terminal)

**Inscription candidat :**
```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@email.com\",\"password\":\"123456\",\"userType\":\"candidat\",\"nom\":\"Jean Dupont\"}"
```

**Connexion :**
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@email.com\",\"password\":\"123456\"}"
```

**Liste des offres (public) :**
```bash
curl http://localhost:3001/api/offers
```

### Vérifier dans phpMyAdmin
Après inscription : vérifie que `utilisateurs` et `candidats` ont une nouvelle ligne.

---

## ÉTAPE 6 — Configurer Flutter selon ton appareil

Dans `lib/services/api_service.dart`, change `baseUrl` :

| Cas | URL |
|-----|-----|
| **Émulateur Android** (recommandé) | `http://10.0.2.2:3001/api` |
| **Appareil physique** | `http://192.168.11.110:3001/api` ← ton IP WiFi |
| **Windows** (flutter run desktop) | `http://localhost:3001/api` |

> Pour trouver ton IP locale : `ipconfig` (Windows) ou `ip addr` (Linux/Mac)

---

## ÉTAPE 7 — Lancer Flutter

Dans un **second terminal** (le backend doit rester ouvert) :

```bash
flutter run
```

---

## En cas d'erreur

| Erreur | Solution |
|--------|----------|
| `ER_ACCESS_DENIED` | Mauvais `DB_USER` ou `DB_PASSWORD` dans `.env` |
| `ER_BAD_DB_ERROR` | La base `bddiane_sp` n'existe pas — importe le `.sql` |
| `Connection refused` dans Flutter | Le backend n'est pas démarré, ou mauvaise IP |
| `EADDRINUSE: port 3001` | Le port est déjà utilisé — change `PORT=3002` dans `.env` |
| Émulateur Android ne se connecte pas | Utilise `10.0.2.2` au lieu de `localhost` |

---

## Structure des fichiers

```
afrijob_backend/
├── server.js              ← Point d'entrée (NOUVEAU)
├── package.json           ← Dépendances (NOUVEAU)
├── .env                   ← Configuration
├── config/
│   └── database.js        ← Connexion MySQL
├── middleware/
│   └── auth.js            ← Vérification JWT
├── controllers/
│   └── authController.js  ← Inscription / Connexion / Profil
├── routes/
│   ├── auth.js            ← /api/auth/*
│   ├── offers.js          ← /api/offers/*
│   ├── applications.js    ← /api/applications/*
│   └── upload.js          ← /api/upload
└── uploads/               ← Fichiers uploadés (photos, CV)
```
