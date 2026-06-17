# 🔧 Configuration de Déploiement Multi-Plateforme

## Environnement Actuel: DÉVELOPPEMENT

### 🔗 URLs Backend

**Développement (Local)**
```
API URL: http://localhost:3001
WebSocket: ws://localhost:3001
```

**Production (À configurer)**
```
API URL: https://votre-domaine.com/api
WebSocket: wss://votre-domaine.com
```

---

## 📱 Configuration par Plateforme

### 💻 DESKTOP (Windows/Mac/Linux)
- **Bundle ID**: com.mon_app.job_research
- **Version Minimum**: Flutter 3.0.0
- **Target Architecture**: x86_64
- **Statut**: ✅ Prêt pour déploiement

### 📱 ANDROID
- **Package Name**: com.mon_app.job_research
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Architecture**: arm64-v8a, armeabi-v7a
- **Signature**: ❌ À créer (voir `DEPLOYMENT_MULTIPLATFORM.md`)
- **Statut**: ⚠️ En attente de signature

### 🍎 iOS/iPAD
- **Bundle ID**: com.monjob.JobResearch
- **Min iOS**: 12.0
- **Supported Devices**: iPhone, iPad
- **Architecture**: arm64
- **Provisioning Profile**: ❌ À configurer
- **Statut**: ⚠️ En attente de configuration Xcode

---

## 🚀 Commandes Rapides de Déploiement

### Développement Rapide (Tous Appareils)
```powershell
# Windows
.\deploy.ps1 -Target all

# Mac/Linux
./deploy.ps1 -Target all
```

### Desktop Uniquement
```powershell
.\deploy.ps1 -Target desktop-windows
.\deploy.ps1 -Target desktop-mac
.\deploy.ps1 -Target desktop-linux
```

### Android
```powershell
# Debug (développement)
.\deploy.ps1 -Target android-debug -Test

# Release (production/Play Store)
.\deploy.ps1 -Target android-release
```

### iOS/iPad
```powershell
# Debug (développement)
.\deploy.ps1 -Target ios-debug -Test

# Release (App Store)
.\deploy.ps1 -Target ios-release
```

### Backend Seul
```powershell
.\deploy.ps1 -Target backend
```

---

## 📋 Étapes de Configuration Requises

### ✅ AVANT TOUT DÉPLOIEMENT

#### 1. Backend (Node.js)
```bash
cd backend
npm install
npm run dev
# Vérifier: http://localhost:3001/api/health
```

#### 2. Database (MySQL)
```bash
# Importer le schéma
mysql -u root < ../bddiane_sp.sql

# Vérifier
mysql -u root bddiane_sp -e "SHOW TABLES;"
```

#### 3. Flutter Doctor
```bash
flutter doctor
# Résoudre tous les ⚠️ (warn) critiques
```

#### 4. API Endpoint dans le Code
**Fichier**: `frontend/lib/services/api_service.dart`
```dart
// DÉVELOPPEMENT
static const String baseUrl = 'http://localhost:3001/api';

// PRODUCTION (à remplacer)
// static const String baseUrl = 'https://votre-domaine.com/api';
```

---

## 🔐 Sécurité & Production

### Avant Production:
- [ ] API Endpoint changé vers domaine HTTPS
- [ ] JWT Secret généré et sécurisé
- [ ] Database credentials sécurisées
- [ ] CORS bien configuré
- [ ] SSL Certificate installé

### Android Release:
```
Clé de signature: ✅ Créée
Alias: upload-key
Validité: 10000 jours
```

### iOS Release:
```
Team ID: À obtenir de Apple Developer
Bundle ID: com.monjob.JobResearch
Provisioning: À configurer dans Xcode
```

---

## 📊 Checklist de Déploiement

### ✅ Phase 1 - Préparation
- [ ] Backend démarre sans erreurs
- [ ] Database connectée
- [ ] API accessible: `http://localhost:3001/api/health`
- [ ] Flutter doctor sans erreurs critiques

### ✅ Phase 2 - Tests
- [ ] App fonctionne en local (flutter run)
- [ ] Login marche
- [ ] Upload fichiers marche
- [ ] API calls fonctionnent

### ✅ Phase 3 - Build Desktop
- [ ] Build Windows compilé
- [ ] Build Mac compilé
- [ ] Build Linux compilé

### ✅ Phase 4 - Build Android
- [ ] APK Debug installé sur téléphone
- [ ] Fonctionnement OK
- [ ] APK Release signé

### ✅ Phase 5 - Build iOS
- [ ] Provisioning profiles configurés
- [ ] Build iOS successful
- [ ] Testé sur simulator
- [ ] IPA préparé pour App Store

---

## 🎯 Tableau de Déploiement Final

| Plateforme | Fichier | Localisation | Statut |
|-----------|---------|------------|--------|
| **Backend** | server.js | Produit/Hébergé | ⏳ À héberger |
| **Windows** | app-release.exe | build/windows/x64/runner/Release | ✅ Prêt |
| **macOS** | job_research.app | build/macos/Build/Products/Release | ✅ Prêt |
| **Linux** | job_research | build/linux/x64/release/bundle | ✅ Prêt |
| **Android** | app-release.apk | build/app/outputs/apk/release | ⏳ À signer |
| **iOS** | Runner.ipa | build/ios | ⏳ À préparer |
| **iPad** | (même que iOS) | build/ios | ⏳ À préparer |

---

## 🌐 Distribution

### Desktop
- **Windows**: Distribuer `.exe` ou ZIP compilé
- **macOS**: Distribuer `.app` ou `.dmg`
- **Linux**: Distribuer binary ou via snap/flatpak

### Android
- **APK Direct**: Envoyer `app-release.apk`
- **Google Play Store**: Uploader depuis Play Console

### iOS/iPad
- **App Store**: Uploader via App Store Connect
- **TestFlight**: Beta testing pour utilisateurs sélectionnés

---

## 📞 Support & Ressources

- [Flutter Deployment Guide](https://flutter.dev/docs/deployment)
- [Android App Publishing](https://developer.android.com/studio/publish)
- [iOS App Publishing](https://developer.apple.com/app-store)
- [Node.js Deployment](https://nodejs.org/en/docs/guides)

---

**Dernière mise à jour**: 2026-06-17
