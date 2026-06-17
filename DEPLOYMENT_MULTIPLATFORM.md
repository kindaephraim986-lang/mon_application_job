# 🚀 GUIDE DE DÉPLOIEMENT MULTI-PLATEFORME

**Application:** AfriJob (Flutter + Node.js)  
**Plateformes:** Windows/Mac/Linux (Desktop) + Android + iOS/iPad  
**Date:** 2026-06-17

---

## 📋 TABLE DES MATIÈRES
1. [Prérequis](#prérequis)
2. [Backend (Node.js)](#backend)
3. [Frontend - Ordinateur/Desktop](#desktop)
4. [Frontend - Android](#android)
5. [Frontend - iOS/iPad](#ios--ipad)
6. [Configuration Production](#production)
7. [Troubleshooting](#troubleshooting)

---

## ✅ Prérequis

### Outils Requis
```bash
# Vérifier Flutter
flutter --version       # Minimum 3.0.0

# Vérifier Dart
dart --version

# Vérifier Node.js
node --version          # Minimum 14.0
npm --version

# Pour iOS (Mac uniquement)
xcode-select --install  # Install Xcode Command Line Tools
pod --version
```

### Configuration
```bash
# Se placer au dossier racine
cd c:\Users\SYST\Documents\mon_application_job

# Mettre à jour Flutter
flutter upgrade
flutter pub get

# Vérifier la configuration
flutter doctor          # ✅ Voir les erreurs éventuelles
```

---

## 🖥️ BACKEND - Node.js Server

### Installation & Démarrage
```bash
# Terminal 1 - Backend
cd backend
npm install
npm run dev             # ou 'npm start' pour production

# Vous devriez voir:
# ✅ Connecté à MySQL — base: bddiane_sp
# Serveur actif sur http://0.0.0.0:3001
```

### Vérifier le Backend
```bash
# Dans un autre terminal, tester l'API
curl http://localhost:3001/api/health

# Résultat attendu:
# {"message":"Server is running"}
```

### Configuration Production
- Créer un fichier `.env` dans `backend/`:
```
DATABASE_HOST=votre_serveur
DATABASE_USER=votre_user
DATABASE_PASSWORD=votre_password
DATABASE_NAME=bddiane_sp
PORT=3001
JWT_SECRET=votre_secret_jwt
NODE_ENV=production
```

---

## 💻 DESKTOP (Windows/Mac/Linux)

### 1️⃣ Configuration Flutter Desktop
```bash
cd frontend

# Activer les plateformes desktop (si pas encore activé)
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# Vérifier la configuration
flutter doctor
```

### 2️⃣ Build pour Windows
```bash
cd frontend

# Développement
flutter run -d windows

# Build Release
flutter build windows --release

# Exécutable se trouvera dans:
# build/windows/x64/runner/Release/
```

### 3️⃣ Build pour macOS
```bash
cd frontend

# Développement
flutter run -d macos

# Build Release
flutter build macos --release

# App se trouvera dans:
# build/macos/Build/Products/Release/job_research.app
```

### 4️⃣ Build pour Linux
```bash
cd frontend

# Développement
flutter run -d linux

# Build Release
flutter build linux --release

# Exécutable se trouvera dans:
# build/linux/x64/release/bundle/
```

---

## 📱 ANDROID

### 1️⃣ Configuration Android Studio
```bash
# Télécharger Android Studio: https://developer.android.com/studio

# Installer le SDK:
# - Android Emulator
# - Android SDK 30+ (minimum)
# - Android Virtual Device (AVD)
```

### 2️⃣ Configurer l'Émulateur
```bash
# Lancer l'émulateur Android
emulator -avd <NOM_DE_VOTRE_AVD>

# Ou depuis Android Studio: Tools → Device Manager
```

### 3️⃣ Build et Run en Développement
```bash
cd frontend

# Lancer l'app sur l'émulateur
flutter run

# Sélectionner l'appareil Android
```

### 4️⃣ Build APK (Développement)
```bash
cd frontend

flutter build apk --debug

# APK se trouvera dans:
# build/app/outputs/apk/debug/app-debug.apk
```

### 5️⃣ Build APK Release (Production)
```bash
cd frontend

# ⚠️ Avant: Créer/Générer une clé de signature
# Voir section "Signing Android App" ci-dessous

flutter build apk --release

# APK Release se trouvera dans:
# build/app/outputs/apk/release/app-release.apk
```

### 6️⃣ Installer l'APK sur Téléphone
```bash
# Connecter le téléphone via USB (USB Debugging activé)
adb install -r build/app/outputs/apk/release/app-release.apk

# ou via Flutter:
flutter install
```

### 📝 Signing Android App (Obligatoire pour Play Store)
```bash
# Générer une clé de signature
cd frontend/android/app

keytool -genkey -v -keystore release-key.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload-key

# Remplir les informations demandées

# Créer/modifier android/key.properties:
storeFile=release-key.keystore
storePassword=<VOTRE_PASSWORD>
keyAlias=upload-key
keyPassword=<VOTRE_PASSWORD>
```

---

## 🍎 iOS & iPad

### 1️⃣ Prérequis (macOS uniquement)
```bash
# Installer Xcode
xcode-select --install

# Installer CocoaPods
sudo gem install cocoapods

# Vérifier l'installation
flutter doctor
```

### 2️⃣ Configurer le Provisioning
```bash
# Ouvrir Xcode
cd frontend
open ios/Runner.xcworkspace

# Dans Xcode:
# 1. Sélectionner "Runner"
# 2. Aller dans "Signing & Capabilities"
# 3. Choisir votre Apple ID (ou créer un team)
# 4. Mettre à jour le Bundle ID si nécessaire
```

### 3️⃣ Build et Run en Développement
```bash
cd frontend

# Lancer sur simulator
flutter run -d <device_id>

# Voir les simulateurs disponibles
flutter devices

# Ou via Xcode:
open ios/Runner.xcworkspace
# Cliquer sur "Run" ou cmd+R
```

### 4️⃣ Build IPA pour TestFlight/App Store
```bash
cd frontend

# Build pour iOS
flutter build ios --release

# Ouvrir Xcode pour archiving
open ios/Runner.xcworkspace

# Dans Xcode:
# 1. Product → Archive
# 2. Distribute App
# 3. Suivre les instructions pour App Store ou TestFlight
```

### 5️⃣ iPad (Même processus que iOS)
```bash
# iPad est supporté nativement par Flutter iOS
# Utiliser le même processus de build qu'iOS

# Vérifier la compatibilité iPad dans Xcode:
# Runner → General → Supported Destinations → iPad
```

---

## ⚙️ PRODUCTION - Configuration & Distribution

### API Endpoint Production
**Modifier `frontend/lib/services/api_service.dart`:**
```dart
// Pour Production:
static const String baseUrl = 'https://votre-domaine.com/api';

// Pour Développement:
// static const String baseUrl = 'http://localhost:3001/api';
```

### Play Store (Android)
1. Créer compte Google Play Console
2. Build signed APK (voir section Android Release)
3. Uploader l'APK
4. Remplir les informations de l'app
5. Soumettre pour review

### App Store (iOS)
1. Créer Apple Developer Account
2. Build l'app avec Xcode (voir section iOS)
3. Uploader via Xcode ou Transporter
4. Remplir les informations de l'app
5. Soumettre pour review

### Hébergement Backend
Pour un hébergeur gratuit, nous recommandons Render ou Heroku.

- Frontend web gratuit: GitHub Pages
- Backend gratuit: Render free tier avec `render.yaml`

### Exemple Render
1. Créez un compte sur https://render.com
2. Importez ce dépôt GitHub
3. Créez un nouveau service Web
4. Render détecte `render.yaml` et configure automatiquement le build
5. Ajoutez les variables d'environnement depuis `backend/.env.example`

### Exemple Heroku
```bash
heroku login
heroku create mon-app-backend
git push heroku main
```

---

## 🐛 Troubleshooting

### Flutter Issues
```bash
# Nettoyer le cache
flutter clean
flutter pub get

# Reconstruire
flutter pub cache repair

# Vérifier les erreurs
flutter analyze
flutter doctor -v
```

### Android Issues
```bash
# Vérifier les appareils
adb devices

# Relancer l'émulateur
adb kill-server
adb start-server
emulator -avd <NOM_AVD>
```

### iOS Issues
```bash
# Nettoyer Pod cache
cd ios
rm -rf Pods
rm -rf Podfile.lock
cd ..
flutter clean
flutter pub get
```

### API Connection Issues
```bash
# Vérifier que le backend fonctionne
curl -X GET http://localhost:3001/api/health

# Pour Android/Émulateur:
# Utiliser http://10.0.2.2:3001 au lieu de localhost
```

---

## 📊 Résumé - Checklist de Déploiement

### ✅ Avant Déploiement
- [ ] Backend: `npm run dev` fonctionne
- [ ] Database: `bddiane_sp` importée
- [ ] Flutter: `flutter doctor` sans erreurs critiques
- [ ] Tests: App fonctionne en développement
- [ ] API Endpoint: Correct dans `api_service.dart`

### ✅ Desktop
- [ ] Windows Build compilé
- [ ] Mac Build compilé
- [ ] Linux Build compilé

### ✅ Android
- [ ] APK Debug testé
- [ ] APK Release signé
- [ ] Installé sur téléphone

### ✅ iOS/iPad
- [ ] Build iOS successful
- [ ] Provisioning profiles configurés
- [ ] Testé sur simulator/device

---

## 📞 Commandes Rapides

```bash
# Développement Multi-Plateforme
flutter pub get                    # Get dependencies
flutter analyze                    # Check errors
flutter run -d all                 # Run on all devices
flutter devices                    # List devices

# Build Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release

# Build Mobile
flutter build apk --release
flutter build ios --release

# Backend
cd backend && npm run dev          # Dev server
cd backend && npm start            # Production server
```

---

**Besoin d'aide?** Consultez:
- [Flutter Documentation](https://flutter.dev/docs)
- [Android Development](https://developer.android.com)
- [iOS Development](https://developer.apple.com)
- [Node.js Documentation](https://nodejs.org/docs)
