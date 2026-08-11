# Render Deployment Checklist

## 1) Valider la base de données
- Assure-toi que la base MySQL externe existe et est accessible depuis Render.
- La base doit s'appeler `bddiane_sp`.
- Vérifie que les tables principales sont déjà créées (`utilisateurs`, `candidats`, `entreprises`, `offres`, `candidatures`, etc.).

## 2) Configurer Render
Dans Render Dashboard, configure ces variables d'environnement pour le service `job-research` :
- `NODE_ENV=production`
- `PORT=3000`
- `CORS_ORIGIN=https://job-research-tl8g.onrender.com`
- `FRONTEND_URL=https://job-research-tl8g.onrender.com`
- `DB_HOST=...`
- `DB_PORT=3306`
- `DB_USER=...`
- `DB_PASSWORD=...`
- `DB_NAME=bddiane_sp`
- `DB_SSL=false`
- `JWT_SECRET=...`
- `FILE_SIGNATURE_SECRET=...`
- `LOG_LEVEL=info`
- `UPLOAD_DIR=/tmp/uploads`
- `REDIS_URL=redis://redis:6379`

> Remplace les valeurs placeholder par tes vraies informations de production. Ne publie pas les secrets.

## 3) Configurer GitHub Actions (si tu utilises le workflow)
Ajoute ces secrets dans GitHub repository settings :
- `RENDER_API_KEY`
- `RENDER_SERVICE_ID`

## 4) Automatiser la configuration Render
Tu peux synchroniser automatiquement les variables d'environnement Render et déclencher un déploiement avec le script PowerShell :
```powershell
$env:RENDER_API_KEY = '<your-render-api-key>'
$env:RENDER_SERVICE_ID = '<your-render-service-id>'
.\set-render-secrets.ps1 -EnvFile .env.production
```
Si tu veux uniquement synchroniser les variables sans lancer de déploiement, ajoute `-NoDeploy`.

## 5) Vérifier les fichiers modifiés
Les fichiers de code suivants ont été ajustés et doivent être commités :
- `Dockerfile`
- `backend/server.js`
- `backend/routes/files.js`
- `backend/routes/ocr.js`
- `backend/routes/upload.js`
- `backend/services/profilePhotoService.js`
- `render.yaml`

## 5) Ne pas commit `node_modules`
- `backend/node_modules` est présent localement après `npm ci`.
- Ne pas l'ajouter au dépôt.

## 6) Committer et pousser
```powershell
cd c:\Users\SYST\Desktop\Job_Research_main_tmp
git add Dockerfile backend/server.js backend/routes/files.js backend/routes/ocr.js backend/routes/upload.js backend/services/profilePhotoService.js render.yaml
git commit -m "Prépare le déploiement Render : fix Docker, upload dir et config production"
git push origin main
```

## 7) Déployer
- Si Render est connecté au dépôt, le push sur `main` doit lancer le build automatiquement.
- Si tu utilises le workflow GitHub Actions, vérifie que les secrets `RENDER_API_KEY` et `RENDER_SERVICE_ID` sont configurés.

## 8) Vérifier l'état après déploiement
- Ouvre le dashboard Render et regarde les logs du build et du déploiement.
- Vérifie le health check sur `/api/health`.
- Si l’application démarre, teste une route API simple, par exemple :
  - `GET https://job-research-tl8g.onrender.com/api/health`

## 9) En cas d'erreur courante
- Si l’accès MySQL échoue : vérifie `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` et la connectivité.
- Si l’app n’arrive pas à servir le frontend : vérifie que le build Flutter web existe dans `public/`.
- Si CORS bloque : ajoute `https://job-research-tl8g.onrender.com` à `CORS_ORIGIN`.
