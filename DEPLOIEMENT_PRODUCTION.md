# Déploiement de AfriJob

## Objectif
Ce guide permet de déployer le frontend Flutter et le backend Node.js en production.

---

## 1) Backend Node.js

### Prérequis
- Node.js installé
- MySQL accessible en production
- Variables d'environnement configurées

### Étapes de déploiement
1. Copier le dossier `afrijob_backend/` sur le serveur ou la plateforme cloud.
2. Installer les dépendances :
   ```bash
   cd afrijob_backend
   npm install
   ```
3. Configurer les variables d'environnement du serveur :
   - `PORT=3001`
   - `DB_HOST=<hôte_mysql>`
   - `DB_USER=<utilisateur_mysql>`
   - `DB_PASSWORD=<mot_de_passe_mysql>`
   - `DB_NAME=bddiane_sp`
   - `JWT_SECRET=<cle_secrete_prod>`
   - `JWT_EXPIRE=30d`
4. Démarrer le backend :
   ```bash
   node server.js
   ```
   Ou en développement :
   ```bash
   npx nodemon server.js
   ```

### Vérification
- Ouvrir `https://<ton-backend>/health`
- Tu dois obtenir :
  ```json
  { "status": "OK", "message": "Serveur actif" }
  ```

### Notes
- Si le stockage de fichiers uploadés (`/uploads`) est nécessaire en production, utilise un stockage persistant (S3, DigitalOcean Spaces, Azure Blob Storage, etc.).
- En production, le backend doit être accessible via HTTPS.

---

## 2) Frontend Flutter Web

### Préparer la production
Le frontend utilise `lib/services/api_service.dart` pour appeler le backend.

### Commande de build
Dans le dossier racine du projet Flutter :
```bash
flutter build web --release --dart-define=API_BASE_URL=https://<ton-backend>/api
```

### Déploiement
Déployer le contenu du dossier `build/web` sur une plateforme de hosting statique :
- Netlify
- Vercel
- Firebase Hosting
- Azure Static Web Apps
- GitHub Pages

### Exemple avec Netlify
1. Créer un site sur Netlify.
2. Choisir le dossier `build/web` comme site statique.
3. Déployer.

---

## 3) Frontend Flutter Android

### Commande de build
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://<ton-backend>/api
```

### Résultat
- Le fichier se trouve dans `build/app/outputs/flutter-apk/app-release.apk`
- Installer sur un appareil Android ou distribuer via Play Store.

---

## 4) Frontend Flutter iOS

### Commande de build
```bash
flutter build ios --release --dart-define=API_BASE_URL=https://<ton-backend>/api
```

### Notes iOS
- Ouvrir `ios/Runner.xcworkspace` dans Xcode.
- Configurer les certificats et le provisioning profile.

---

## 5) Variables d'environnement Flutter

### Mode développement local
Le frontend utilisera automatiquement :
- `http://localhost:3001/api` pour web
- `http://10.0.2.2:3001/api` pour Android
- `http://localhost:3001/api` pour desktop

### Mode production
Utiliser `--dart-define=API_BASE_URL=https://<ton-backend>/api` pour remplacer l'URL.

---

## 6) Paiement YengaPay

### Configuration de production
Dans `lib/services/utils/constants.dart`, les variables sont lues via `String.fromEnvironment` :
- `YENGAPAY_API_KEY`
- `YENGAPAY_API_SECRET`
- `YENGAPAY_BASE_URL`
- `YENGAPAY_RETURN_URL`
- `YENGAPAY_WEBHOOK_URL`

### Exemple de build prod avec YengaPay
```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://<ton-backend>/api \
  --dart-define=YENGAPAY_API_KEY=<ta_cle> \
  --dart-define=YENGAPAY_API_SECRET=<ton_secret> \
  --dart-define=YENGAPAY_BASE_URL=https://api.yengapay.com/v1 \
  --dart-define=YENGAPAY_RETURN_URL=https://<ton-domaine>/payment/return \
  --dart-define=YENGAPAY_WEBHOOK_URL=https://<ton-domaine>/api/webhook/yengapay
```

---

## 7) Résumé rapide

- Backend Node.js : déployé avec `node server.js` et variables d'environnement.
- MySQL : base `bddiane_sp` importée.
- Frontend : builder avec `API_BASE_URL` en production.
- Paiement : configurer les clés YengaPay réelles.

---

## 8) Checklist de déploiement

- [ ] Backend déployé et `/health` OK
- [ ] Base MySQL disponible et `bddiane_sp` importée
- [ ] Frontend web animé avec `build/web`
- [ ] Backend API accessible en HTTPS
- [ ] API_BASE_URL configuré avec le bon domaine
- [ ] YengaPay clés de production configurées
- [ ] Tests fonctionnels réalisés sur auth, offres, candidatures, chat, upload
