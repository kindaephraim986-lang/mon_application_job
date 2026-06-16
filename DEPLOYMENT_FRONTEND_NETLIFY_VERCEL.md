# Déploiement frontend Flutter Web sur Netlify / Vercel

Ce guide explique comment déployer le frontend Flutter de `mon_application_job` sur une plateforme d'hébergement statique comme Netlify ou Vercel.

## 1) Préparer le backend avant le déploiement

Avant de déployer le frontend, ton backend doit être déjà déployé et accessible via HTTPS.

- Exemple d'URL backend : `https://mon-backend.onrender.com/api`
- L'API doit répondre sur `/health` et `/api/offers`.

## 2) Vérifier la configuration frontend

Le code dans `lib/services/api_service.dart` est configuré pour utiliser une variable d'environnement Dart :

```dart
static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

static String get baseUrl {
  if (_envApiBaseUrl.isNotEmpty) {
    return _envApiBaseUrl;
  }
  if (kIsWeb) {
    return 'http://localhost:3001/api';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:3001/api';
    default:
      return 'http://localhost:3001/api';
  }
}
```

### Important
Pour le déploiement web, il faut définir `API_BASE_URL` à l'URL de production du backend.

## 3) Construire le frontend pour production

Ouvre un terminal dans le dossier racine du projet Flutter et exécute :

```bash
flutter build web --release --dart-define=API_BASE_URL=https://<ton-backend>/api
```

Remplace `https://<ton-backend>/api` par ton URL backend finale.

### Résultat
- Le contenu à déployer se trouve dans `build/web`

## 4) Déployer sur Netlify

### Option A : Déposer manuellement
1. Connecte-toi sur https://app.netlify.com
2. Clique sur `Sites` → `Add new site` → `Deploy manually`
3. Glisse-dépose le dossier `build/web`
4. Attends la fin du déploiement
5. Ouvre l'URL fournie par Netlify

### Option B : Déployer depuis Git
1. Connecte ton dépôt GitHub à Netlify
2. Crée un nouveau site
3. Choisis ta branche principale
4. Configure les `Build settings` :
   - `Build command` : `flutter build web --release --dart-define=API_BASE_URL=https://<ton-backend>/api`
   - `Publish directory` : `build/web`
5. Ajoute un `Environment variable` si besoin :
   - Nom : `API_BASE_URL`
   - Valeur : `https://<ton-backend>/api`
6. Déploie

> Note : sur Netlify, `flutter` doit être installé ou disponible dans l'environnement de build. Si l'environnement ne le contient pas, il faut utiliser un build local puis déployer le dossier `build/web` manuellement.

## 5) Déployer sur Vercel

### Option A : Déployer manuellement
1. Connecte-toi sur https://vercel.com
2. Clique sur `New Project`
3. Associe ton dépôt GitHub
4. Sélectionne le dossier racine du projet
5. Configure le `Build Command` :
   - `flutter build web --release --dart-define=API_BASE_URL=https://<ton-backend>/api`
6. Configure le `Output Directory` :
   - `build/web`
7. Ajoute la variable d'environnement si besoin :
   - `API_BASE_URL=https://<ton-backend>/api`
8. Déploie

### Option B : Déploiement simple avec build local
1. Exécute `flutter build web --release --dart-define=API_BASE_URL=https://<ton-backend>/api`
2. Dans Vercel, déploie manuellement le dossier `build/web`

## 6) Vérifier le déploiement

- Ouvre le site web hébergé
- Vérifie que l'application charge
- Teste une route de backend, par exemple :
  - connexion
  - affichage des offres
  - candidate / entreprise

## 7) Variables d'environnement complémentaires

Si tu utilises YengaPay en production et que tu veux définir les clés au moment du build, ajoute les variables :

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://<ton-backend>/api \
  --dart-define=YENGAPAY_API_KEY=<ta_cle> \
  --dart-define=YENGAPAY_API_SECRET=<ton_secret> \
  --dart-define=YENGAPAY_BASE_URL=https://api.yengapay.com/v1 \
  --dart-define=YENGAPAY_RETURN_URL=https://<ton-frontend>/payment/return \
  --dart-define=YENGAPAY_WEBHOOK_URL=https://<ton-backend>/api/webhook/yengapay
```

## 8) Remarques importantes

- L’URL de backend doit être en HTTPS en production.
- Le frontend web ne doit pas pointer vers `localhost` en production.
- Si la plateforme d’hébergement ne possède pas Flutter, fais le build local puis déploie le dossier `build/web`.

---

## 9) Résumé

- Build production : `flutter build web --release --dart-define=API_BASE_URL=https://<ton-backend>/api`
- Dossier à déployer : `build/web`
- Hébergeur recommandé : Netlify ou Vercel
- Backend prod : `https://<ton-backend>/api`
