# Déploiement automatique sur Render via GitHub

## Prérequis

- dépôt GitHub connecté à Render
- une application Render configurée avec `render.yaml`
- les secrets GitHub suivants définis dans le repository:
  - `RENDER_API_KEY`
  - `RENDER_SERVICE_ID`

## Fonctionnement

1. Un push sur `main` déclenche le workflow GitHub Actions.
2. Le workflow installe Flutter, construit le frontend web, puis demande à Render de créer un nouveau déploiement.
3. Render utilise le `Dockerfile` à la racine et le `render.yaml` pour déployer l’application.

## Variables Render requises

Dans Render, ajoutez ces variables d'environnement:

- `NODE_ENV=production`
- `PORT=3000`
- `CORS_ORIGIN=https://your-app.onrender.com`
- `FRONTEND_URL=https://your-app.onrender.com`
- `DB_HOST=your-mysql-host`
- `DB_PORT=3306`
- `DB_USER=your-mysql-user`
- `DB_PASSWORD=your-mysql-password`
- `DB_NAME=bddiane_sp`
- `DB_SSL=false`  # Set to `true` only if your MySQL provider requires SSL/TLS
- `JWT_SECRET=your-jwt-secret`
- `FILE_SIGNATURE_SECRET=your-file-signature-secret`

## Notes

- L’application Flutter web utilise désormais l’origine du site (`Uri.base.origin`) pour appeler l’API en production Web.
- Si vous voulez forcer une URL API différente, utilisez `--dart-define=API_BASE_URL=https://api.your-domain.com`.
