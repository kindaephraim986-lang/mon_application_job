# Déploiement du backend AfriJob sur Railway / Render

Ce guide explique comment déployer le backend Node.js `afrijob_backend/` en production sur Railway ou Render.

## 1) Préparer la base de données

Le backend utilise MySQL. Avant toute chose :

1. Installer ou activer une base MySQL distante.
2. Importer le fichier `bddiane_sp.sql` dans la base.
3. Vérifier que la base `bddiane_sp` existe et contient les tables attendues.

## 2) Configuration de l'application backend

Le backend lit les variables d'environnement depuis `process.env` :

- `PORT` (par défaut `3001`)
- `DB_HOST`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `JWT_SECRET`
- `JWT_EXPIRE`

### Exemple de configuration

```env
PORT=3001
DB_HOST=host.mysql.example.com
DB_USER=afrijob_user
DB_PASSWORD=motdepasse123
DB_NAME=bddiane_sp
JWT_SECRET=une-cle-secrete-de-production
JWT_EXPIRE=30d
```

> Ne pousse jamais ce fichier `.env` dans Git. Utilise les variables d'environnement de la plateforme.

## 3) Déploiement sur Render

### Étape 1 : Créer un service Web

1. Connecte ton dépôt GitHub/GitLab/Bitbucket à Render.
2. Crée un nouveau service de type `Web Service`.
3. Sélectionne le dossier racine `afrijob_backend`.
4. Choisis `Node`.
5. Valeur du `Build Command` :

```bash
npm install
```

6. Valeur du `Start Command` :

```bash
npm start
```

7. Définis `PORT` dans les variables d'environnement Render.

### Étape 2 : Configurer les variables d'environnement

Dans Render, ajoute :

- `PORT` = `3001`
- `DB_HOST` = ton hôte MySQL
- `DB_USER` = ton utilisateur MySQL
- `DB_PASSWORD` = ton mot de passe MySQL
- `DB_NAME` = `bddiane_sp`
- `JWT_SECRET` = `une-cle-secrete` 
- `JWT_EXPIRE` = `30d`

### Étape 3 : Déployer

- Render construira et lancera automatiquement l'application.
- Vérifie les logs pour confirmer que la connexion MySQL est réussie.

### Étape 4 : Vérifier le service

Ouvre :

```text
https://<ton-service>.onrender.com/health
```

Tu dois voir une réponse JSON valide.

## 4) Déploiement sur Railway

### Étape 1 : Créer un projet

1. Connecte ton dépôt Git.
2. Crée un projet Railway.
3. Choisis `Deploy from GitHub repo`.
4. Sélectionne le dossier `afrijob_backend` comme racine de service.
5. Railway détectera `package.json`.

### Étape 2 : Configurer la base de données

- Ajoute un plugin MySQL Railway ou renseigne une base externe.
- Note l'hôte, le port, l'utilisateur, le mot de passe et le nom de la base.

### Étape 3 : Définir les variables d'environnement

Ajoute les mêmes variables qu'à la section Render.

Railway utilisera généralement :
- `PORT = 3001`
- Configuration MySQL du plugin ou externe

### Étape 4 : Lancer le déploiement

Railway construira automatiquement avec `npm install` puis `npm start`.

## 5) Spécificités de production

### Stockage des uploads

Le backend sert les fichiers `uploads` localement :

```js
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
```

Sur Railway/Render, le disque local est éphémère. Si tes fichiers doivent persister, tu devras :

- utiliser un stockage externe (S3, DigitalOcean Spaces, Azure Blob, etc.), ou
- accepter que les fichiers soient temporaires et réinitialisés à chaque redémarrage.

### Sécuriser JWT

Choisis une valeur forte pour `JWT_SECRET` et ne partage jamais la clé.

### HTTPS

Les plateformes Railway et Render offrent HTTPS automatique. Utilise l’URL `https://` fournie.

## 6) Instructions de test post-déploiement

1. Vérifie `https://<ton-backend>/health`.
2. Teste une route simple :
   - `https://<ton-backend>/api/offers`
3. Assure-toi que le frontend utilise l’URL correcte du backend.

## 7) Points importants

- `server.js` est déjà prêt pour le déploiement.
- `package.json` contient le script :
  ```json
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  }
  ```
- La configuration MySQL du backend est dynamique via `process.env`.

---

## 8) Résumé rapide

- Render : `npm install`, `npm start`, variables d’environnement configurées.
- Railway : connecte le repo, ajoute MySQL, configure les variables.
- Vérifie `/health` et `/api/offers`.
- Attention aux uploads locaux.
