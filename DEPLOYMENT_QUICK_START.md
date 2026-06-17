# ⚡ DÉPLOIEMENT RAPIDE - 10 MINUTES

**Déployer l'application sur Ordinateur, Android, iOS, iPad**

---

## 🚀 Démarrage Immédiat (Développement)

### Terminal 1 - Backend
```bash
cd backend
npm install
npm run dev
```
✅ Devrait voir: `Serveur actif sur http://0.0.0.0:3001`

### Terminal 2 - Frontend (Développement Rapide)
```bash
cd frontend
flutter pub get
flutter run      # Choisir l'appareil (Chrome, Android, iOS, etc.)
```

---

## 💻 ORDINATEUR (Desktop)

### Windows
```bash
cd frontend
flutter build windows --release
# Exécutable: build/windows/x64/runner/Release/job_research.exe
```

### macOS
```bash
cd frontend
flutter build macos --release
# App: build/macos/Build/Products/Release/job_research.app
```

### Linux
```bash
cd frontend
flutter build linux --release
# Binary: build/linux/x64/release/bundle/job_research
```

---

## 📱 ANDROID

### Développement Rapide
```bash
cd frontend
flutter run
# Sélectionner appareil/émulateur Android
```

### Build Debug APK
```bash
cd frontend
flutter build apk --debug
# APK: build/app/outputs/apk/debug/app-debug.apk
adb install -r build/app/outputs/apk/debug/app-debug.apk
```

### Build Release APK (Google Play Store)
```bash
cd frontend
flutter build apk --release
# APK: build/app/outputs/apk/release/app-release.apk
```

---

## 🍎 iOS & iPAD

### Développement Rapide (macOS)
```bash
cd frontend
flutter run -d ios
# Sélectionner le simulator
```

### Build Release (macOS)
```bash
cd frontend
flutter build ios --release
# Ouvrir Xcode: open ios/Runner.xcworkspace
# Faire: Product → Archive → Distribute App
```

---

## 🤖 Script Automatisé

```powershell
# Windows/PowerShell uniquement
.\deploy.ps1 -Target all          # Build tout

# Ou plateforme spécifique:
.\deploy.ps1 -Target backend
.\deploy.ps1 -Target desktop-windows
.\deploy.ps1 -Target android-debug
.\deploy.ps1 -Target ios-release
```

---

## ✅ Vérifications Rapides

```bash
# Prérequis OK?
flutter doctor

# API Backend fonctionne?
curl http://localhost:3001/api/health

# Appareil connecté?
adb devices          # Android
flutter devices      # Tous
```

---

## 📋 Étapes Essentielles AVANT Production

1. **Database**: Importer `bddiane_sp.sql`
   ```bash
   mysql -u root < bddiane_sp.sql
   ```

2. **Backend**: Démarrer et tester
   ```bash
   cd backend && npm run dev
   ```

3. **API Endpoint**: Vérifier dans `frontend/lib/services/api_service.dart`
   ```dart
   static const String baseUrl = 'http://localhost:3001/api';
   ```

4. **Flutter Clean** (si problèmes)
   ```bash
   cd frontend
   flutter clean
   flutter pub get
   ```

---

## 🎯 Résumé Rapide des Fichiers

| Besoin | Fichier |
|--------|---------|
| Guide complet | `DEPLOYMENT_MULTIPLATFORM.md` |
| Configuration | `DEPLOYMENT_CONFIG.md` |
| Script auto | `deploy.ps1` |
| CI/CD + frontend | `.github/workflows/build-and-deploy.yml` |
| Backend host config | `render.yaml` |
| Exemple d'environnement | `backend/.env.example` |
| Cette page | `DEPLOYMENT_QUICK_START.md` |

---

## 🌐 Hébergement Gratuit Choisi

- Frontend web: GitHub Pages (auto-déployé depuis `main`)
- Backend: Render free tier via `render.yaml`

> Après push sur `main`, GitHub Actions génère `frontend/build/web` puis publie sur `gh-pages`.
> Pour Backend, importez le repo dans Render et activez le déploiement automatique.

---

## 🆘 Problèmes Courants

### "flutter not found"
```bash
# Ajouter Flutter au PATH:
# Sur Windows: Ajouter C:\flutter\bin au PATH
flutter doctor
```

### "Connection refused" (Backend)
```bash
# Vérifier que le backend fonctionne:
npm run dev   # Dans le dossier backend/
```

### Android Émulateur ne démarre pas
```bash
emulator -avd <NOM_AVD> &    # Ou utiliser Android Studio
flutter devices              # Vérifier qu'il apparaît
```

### iOS: "Xcode not found"
```bash
xcode-select --install
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

---

## 💡 Tips

- **Développement**: `flutter run` suffit pour tester
- **APK Debug**: Rapide à builder, bon pour les tests
- **APK Release**: Nécessite signature, plus lent mais pour stores
- **iOS**: Nécessite Mac + Xcode + Apple Developer Account
- **Production**: Changer API URL vers https://votre-domaine.com

---

**C'est prêt! Commencez par le Terminal 1 (Backend) + Terminal 2 (Frontend)** ✨
