## 🚀 DÉPLOIEMENT OPTION B - ÉTAPES DÉTAILLÉES

### 📋 Checklist avant de commencer

- [ ] ✅ Node.js, npm, Git installés (vérifiés)
- [ ] ✅ Fichiers Dockerfile créés (backend + frontend)
- [ ] ✅ Fichier `.env.railway` préparé
- [ ] ⬜ Code source pushé sur GitHub
- [ ] ⬜ Compte Railway créé
- [ ] ⬜ Compte Vercel créé
- [ ] ⬜ Backend déployé sur Railway
- [ ] ⬜ Frontend déployé sur Vercel
- [ ] ⬜ URLs configurées
- [ ] ⬜ Tests passés

---

## ÉTAPE A: Préparer le code pour GitHub

### A1. Initialiser Git (si pas déjà fait)

```bash
cd c:\Users\SYST\Desktop\mon_application_job

# Vérifier si Git est déjà initialisé
git status

# Si erreur "not a git repository", initialiser:
git init

# Ajouter tout le code
git add .
git commit -m "Init: Préparation pour déploiement Railway+Vercel"
```

### A2. Créer un repo GitHub

1. Aller à https://github.com/new
2. Créer un repo: `mon_application_job` (public ou private)
3. Copier l'URL du repo
4. Pusher le code:

```bash
# Remplacer YOUR_USERNAME par votre username GitHub
git remote add origin https://github.com/YOUR_USERNAME/mon_application_job.git
git branch -M main
git push -u origin main
```

### A3. Vérifier que tout est pushé

```bash
# Voir le statut
git status

# Devrait afficher:
# On branch main
# nothing to commit, working tree clean
```

---

## ÉTAPE B: Déployer le BACKEND sur Railway

### B1. Créer un compte Railway

1. Aller à https://railway.app
2. Cliquer "Start Free"
3. Se connecter avec **GitHub** (important!)
4. Autoriser Railway à accéder à GitHub

### B1 bis. Alternative : déployer sur Render

Render peut construire et déployer ce dépôt avec le `Dockerfile` à la racine et le fichier `render.yaml`.

1. Aller à https://render.com
2. Cliquer "Start Free"
3. Se connecter avec GitHub
4. Importer le repo `mon_application_job`
5. Ajouter les variables d'environnement suivantes:

```
NODE_ENV=production
PORT=3000
CORS_ORIGIN=https://your-app.onrender.com
FRONTEND_URL=https://your-app.onrender.com
DB_HOST=your-mysql-host
DB_PORT=3306
DB_USER=your-mysql-user
DB_PASSWORD=your-mysql-password
DB_NAME=bddiane_sp
JWT_SECRET=your-jwt-secret
FILE_SIGNATURE_SECRET=your-file-signature-secret
```

6. Render ne crée pas de base MySQL automatiquement pour ce dépôt. Utilisez un service MySQL externe ou un hôte compatible.

7. Déployer le service Render.

> Render va construire le backend Node.js et le frontend Flutter web ensemble dans un seul service.

### B2. Créer un nouveau projet

1. Dans Railway dashboard, cliquer "New Project"
2. Choisir "Deploy from GitHub repo"
3. Chercher: `mon_application_job`
4. Sélectionner et autoriser
5. Railway détecte automatiquement `Node.js`

### B3. Ajouter la base de données MySQL

1. Dans le projet Railway, cliquer "Add" (en haut à droite)
2. Choisir "Add Service"
3. Chercher: `MySQL`
4. Cliquer "MySQL"
5. Railway crée le service automatiquement

**Important:** Railway crée automatiquement les variables `DATABASE_URL` et autres. ✅

### B4. Configurer les variables d'environnement

1. Dans le projet Railway
2. Cliquer l'onglet "Variables"
3. Ajouter manuellement:

```
NODE_ENV=production
JWT_SECRET=64090b5f425545094d0913a66f94f6f095e876d199721ab4d440a5ccae3c4ca0
FILE_SIGNATURE_SECRET=75ae132d58dde3fca1a4b34c97d33ca0d6b2b1efb6422ce550bbcc7680c83aae
CORS_ORIGIN=https://YOUR_VERCEL_URL.vercel.app
FRONTEND_URL=https://YOUR_VERCEL_URL.vercel.app
```

**Important:** Le `DATABASE_URL` est créé automatiquement par MySQL service! ✅

### B5. Configurer le déploiement

1. Cliquer l'onglet "Deployments"
2. Railway **devrait** auto-déployer
3. Attendre que le déploiement soit vert ✅

**Si ça reste bleu/orange:**

1. Cliquer l'onglet "Settings"
2. Chercher "Root Directory"
3. Mettre: `backend`
4. Sauvegarder
5. Cliquer "Trigger Deploy" ou pusher un commit

### B6. Obtenir l'URL du backend

1. Aller à "Deployments"
2. Cliquer le déploiement vert
3. Chercher "Public URL" ou "Railway URL"
4. Copier l'URL (ressemble à: `https://YOUR_PROJECT.up.railway.app`)

**Garder cette URL pour plus tard!** 📝

### B7. Vérifier que ça marche

```bash
# Remplacer YOUR_URL par l'URL obtenue
curl https://YOUR_PROJECT.up.railway.app/health

# Devrait retourner:
# {"status":"ok"}
```

Si erreur, voir "Troubleshooting" en bas.

---

## ÉTAPE C: Exécuter les migrations de base de données

### C1. Accéder à MySQL sur Railway

1. Dans Railway, cliquer le service MySQL
2. Chercher "Connect" → "MySQL CLI"
3. Copier la commande (ressemble à: `mysql -h railway.app -u root...`)

### C2. Exécuter les migrations

```bash
# Première migration
mysql -h host -u user -p password bddiane_sp < backend/migrations/001_add_candidature_paiements_table.sql

# Deuxième migration (nos 4 nouvelles features)
mysql -h host -u user -p password bddiane_sp < backend/migrations/002_add_features.sql
```

Si vous ne pouvez pas utiliser MySQL CLI, Railway a une interface web:

1. Railway Dashboard → MySQL service → Data
2. Cliquer "+ Create Table" ou importer SQL
3. Copier/coller le contenu des fichiers `.sql`

---

## ÉTAPE D: Déployer le FRONTEND sur Vercel

### D1. Installer Vercel CLI

```bash
npm install -g vercel
```

### D2. Créer un compte Vercel

1. Aller à https://vercel.com/signup
2. Se connecter avec **GitHub**
3. Autoriser Vercel

### D3. Configurer le frontend

Dans `frontend/lib/services/api_service.dart`, remplacer:

```dart
// AVANT:
static const String baseUrl = 'http://localhost:5000';

// APRÈS: (mettre l'URL du backend Railway)
static const String baseUrl = 'https://YOUR_PROJECT.up.railway.app';
```

Puis commiter:

```bash
git add frontend/lib/services/api_service.dart
git commit -m "Fix: Update backend URL for production"
git push origin main
```

### D4. Déployer le frontend

```bash
# Aller dans le dossier frontend
cd frontend

# Déployer
vercel

# Répondre aux questions:
# ? Set up and deploy "..." [Y/n] Y
# ? Which scope? (Sélectionner votre compte)
# ? Link to existing project? [y/N] N
# ? What's your project's name? afrijob-frontend
# ? In which directory is your code? . (appuyer Enter)
# ? Want to modify these settings? [y/N] N

# Vercel build et déploie automatiquement!
# Attendre la fin...

# À la fin, vous verrez:
# ✓ Production: https://afrijob-frontend.vercel.app
```

Copier cette URL de production! 📝

### D5. Mettre à jour les URLs

Retourner dans le backend Railway:

1. Variables
2. Mettre à jour:
```
FRONTEND_URL=https://afrijob-frontend.vercel.app
CORS_ORIGIN=https://afrijob-frontend.vercel.app
```
3. Sauvegarder → Railway redéploie automatiquement

---

## ÉTAPE E: Tester le déploiement

### E1. Tester le backend

```bash
curl https://YOUR_RAILWAY_URL.up.railway.app/health

# Devrait retourner:
# {"status":"ok"}
```

### E2. Tester le frontend

1. Ouvrir dans navigateur: `https://afrijob-frontend.vercel.app`
2. Vérifier que ça charge
3. Ouvrir la console (F12) pour voir les erreurs

### E3. Tester les features

- [ ] Essayer de se connecter
- [ ] Essayer d'uploader une photo
- [ ] Vérifier les notifications
- [ ] Tester le dashboard entreprise

---

## 🚨 TROUBLESHOOTING

### ❌ "Backend deployment failed"

**Cause possible:** Root directory mal configuré

**Solution:**
1. Railway → Settings → Root Directory
2. Mettre: `backend`
3. Cliquer "Trigger Deploy"

### ❌ "CORS error" dans le frontend

**Cause:** `CORS_ORIGIN` pas configuré correctement

**Solution:**
1. Railway → Variables
2. Vérifier: `CORS_ORIGIN=https://YOUR_VERCEL_URL.vercel.app`
3. Sauvegarder → Redéployer

### ❌ "DATABASE_URL not found"

**Cause:** MySQL pas encore créé

**Solution:**
1. Railway → Add Service → MySQL
2. Attendre 1-2 min
3. Cliquer "Trigger Deploy" sur le backend

### ❌ "Cannot connect to database"

**Cause:** Migrations pas exécutées

**Solution:**
1. Exécuter les migrations SQL (voir ÉTAPE C)
2. Cliquer "Trigger Deploy" sur le backend

### ❌ "Frontend builds but says 'Backend unreachable'"

**Cause:** `api_service.dart` pointe pas sur le bon URL

**Solution:**
1. Vérifier `api_service.dart` pointe sur Railway URL
2. Commiter: `git commit -am "Fix: Backend URL"`
3. Vercel redéploie automatiquement

---

## ✅ Checklist de succès

- [ ] ✅ Backend en vert sur Railway
- [ ] ✅ `https://YOUR_RAILWAY_URL/health` retourne 200 OK
- [ ] ✅ Frontend en vert sur Vercel
- [ ] ✅ `https://YOUR_VERCEL_URL.vercel.app` charge sans erreurs
- [ ] ✅ Console (F12) sans erreurs CORS
- [ ] ✅ Base de données accessible (migrations exécutées)
- [ ] ✅ Login fonctionne
- [ ] ✅ Upload de photos fonctionne
- [ ] ✅ Notifications s'affichent

**Si tout est vert: 🎉 DÉPLOIEMENT RÉUSSI!**

---

## 📞 Besoin d'aide?

- **Railway:** https://railway.app/docs
- **Vercel:** https://vercel.com/docs
- **Docker:** Images utilisées dans les Dockerfiles
- **Flutter Web:** https://flutter.dev/docs/deployment/web

---

**Prochaine étape:** Suivez les étapes A → B → C → D → E ci-dessus! 🚀
