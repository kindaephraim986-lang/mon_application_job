# ✅ CHECKLIST PRE-LANCEMENT - AfriJob

## 📋 Avant de lancer l'application

### Phase 1: Base de Données ✓
- [ ] WampServer/XAMPP est lancé
- [ ] MySQL est actif
- [ ] phpMyAdmin est accessible: http://localhost/phpmyadmin
- [ ] Base de données `bddiane_sp` existe
- [ ] Fichier `bddiane_sp.sql` a été importé
- [ ] Tables créées:
  - [ ] utilisateurs
  - [ ] candidats
  - [ ] entreprises
  - [ ] offres
  - [ ] candidatures
  - [ ] conversations
  - [ ] messages
  - [ ] notifications
  - [ ] paiements
  - [ ] abonnements

### Phase 2: Backend (Node.js) ✓
- [ ] Node.js et npm sont installés
- [ ] Dans `afrijob_backend/`, taper: `npm install`
- [ ] Fichier `.env` existe et contient:
  ```
  PORT=3001
  DB_HOST=localhost
  DB_USER=root
  DB_PASSWORD=
  DB_NAME=bddiane_sp
  JWT_SECRET=afrijob_super_secret_key_2024_change_this_in_production
  JWT_EXPIRE=30d
  ```
- [ ] Fichiers de routes existent:
  - [ ] `routes/auth.js`
  - [ ] `routes/offers.js`
  - [ ] `routes/applications.js`
  - [ ] `routes/messages.js` ✅ (NOUVEAU)
  - [ ] `routes/notifications.js` ✅ (NOUVEAU)
  - [ ] `routes/upload.js`
- [ ] Port 3001 n'est pas utilisé
- [ ] Backend peut être lancé: `npm run dev`
- [ ] Message: ✅ "Connecté à MySQL" et "Serveur actif sur http://0.0.0.0:3001"

### Phase 3: Frontend (Flutter) ✓
- [ ] Flutter SDK est installé
- [ ] Dépendances Flutter à jour: `flutter pub get`
- [ ] Fichiers critiques existent:
  - [ ] `lib/main.dart`
  - [ ] `lib/auth_screen.dart`
  - [ ] `lib/services/api_service.dart` ✅ (REWRITTEN)
  - [ ] `lib/services/storage_service.dart`
  - [ ] `lib/config/app_config.dart` ✅ (NOUVEAU)
  - [ ] `lib/candidate_dashboard.dart`
  - [ ] `lib/company_dashboard.dart`
- [ ] AppConfig pointe vers le bon serveur:
  - Pour Windows: `http://localhost:3001/api`
  - Pour Android Émulateur: `http://10.0.2.2:3001/api`
  - Pour Téléphone: `http://[VotreIP]:3001/api`

### Phase 4: Configuration Finale ✓
- [ ] Backend lancé et testé ✅
- [ ] Base de données accessible ✅
- [ ] Flutter peut être compilé sans erreurs: `flutter build`
- [ ] Fichiers de documentation créés:
  - [ ] `README_COMPLET.md`
  - [ ] `SETUP_GUIDE.md`
  - [ ] `afrijob_backend/DEMARRAGE.md`

---

## 🚀 Commandes de Lancement

### Terminal 1 - Backend
```bash
cd afrijob_backend
npm run dev
# Voir: ✅ Connecté à MySQL — base: bddiane_sp
#       Serveur actif sur http://0.0.0.0:3001
```

### Terminal 2 - Frontend
```bash
cd ..
flutter run
# Sélectionner: chrome (web) ou android-emulator
```

### Terminal 3 - Test (optionnel)
```bash
# Tester une route avec curl
curl -X GET http://localhost:3001/api/offers

# Ou utiliser Postman
```

---

## 🧪 Test Rapide

### 1. Inscription
```
POST http://localhost:3001/api/auth/register
{
  "email": "test@example.com",
  "password": "password123",
  "userType": "candidat",
  "nom": "Test User"
}
```

### 2. Connexion
```
POST http://localhost:3001/api/auth/login
{
  "email": "test@example.com",
  "password": "password123"
}
```

### 3. Récupérer les offres
```
GET http://localhost:3001/api/offers
```

---

## ⚠️ Erreurs Couantes et Solutions

| Erreur | Cause | Solution |
|--------|-------|----------|
| `ECONNREFUSED` | MySQL n'est pas lancé | Lancer WampServer/XAMPP |
| `No database selected` | Base non importée | Importer `bddiane_sp.sql` |
| `EADDRINUSE :::3001` | Port 3001 utilisé | Tuer le processus Node.js |
| `Cannot find module` | Dépendances manquantes | `npm install` ou `flutter pub get` |
| `Token invalide` | JWT_SECRET différent | Vérifier `.env` |
| `Connexion refusée` | API non accessible | Vérifier AppConfig.baseUrl |

---

## ✨ APRÈS LE LANCEMENT

### Vérifier que tout fonctionne:
1. ✅ Écran de connexion s'affiche
2. ✅ Peut créer un compte
3. ✅ Peut se connecter
4. ✅ Dashboard s'affiche correctement
5. ✅ Peut voir les offres
6. ✅ Peut postuler (candidat)
7. ✅ Peut créer une offre (entreprise)
8. ✅ Peut envoyer des messages
9. ✅ Reçoit les notifications
10. ✅ Peut télécharger des fichiers

---

## 🎯 Résumé Final

Fichiers **créés ou corrigés** lors de cette mise à jour:

✅ **Backend Routes:**
- `afrijob_backend/routes/messages.js` (NOUVEAU)
- `afrijob_backend/routes/notifications.js` (NOUVEAU)
- `afrijob_backend/server.js` (mis à jour)
- `afrijob_backend/routes/offers.js` (ordre des routes corrigé)
- `afrijob_backend/routes/applications.js` (paramètre statut corrigé)

✅ **Frontend Services:**
- `lib/services/api_service.dart` (COMPLÈTEMENT REWRITTEN)
- `lib/config/app_config.dart` (NOUVEAU)

✅ **Documentation:**
- `README_COMPLET.md` (NOUVEAU)
- `SETUP_GUIDE.md` (NOUVEAU)
- `afrijob_backend/DEMARRAGE.md` (mis à jour)
- `CHECK.sh` (script de vérification)
- `CHECKLIST.md` (ce fichier)

---

## 📞 Support

En cas de problème:
1. Vérifier les logs dans le terminal
2. Consulter la console du navigateur (F12)
3. Lire `README_COMPLET.md` et `SETUP_GUIDE.md`
4. Vérifier phpMyAdmin pour la base de données

---

**✅ Vous êtes prêt à utiliser AfriJob!**
