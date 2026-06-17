# 🚀 DÉMARRAGE ULTRA RAPIDE - JOB RESEARCH

## ⏱️ 5 minutes pour avoir l'app en marche

### ÉTAPE 1: Base de Données (1 min)
```
1. Ouvrir: http://localhost/phpmyadmin
2. Créer base: bddiane_sp
3. Importer: bddiane_sp.sql (depuis le dossier racine)
✅ Fait!
```

### ÉTAPE 2: Backend (2 min)
```bash
# Terminal 1
cd afrijob_backend
npm install
npm run dev

# ✅ Vous devriez voir:
# "✅ Connecté à MySQL — base: bddiane_sp"
# "Serveur actif sur http://0.0.0.0:3001"
```

### ÉTAPE 3: Frontend (2 min)
```bash
# Terminal 2
flutter pub get
flutter run

# Sélectionner: chrome ou android-emulator
```

### ÉTAPE 4: Utiliser l'App
```
📧 Email: ephraim@example.com
🔐 Password: password123
✅ Connecté!
```

---

## 📁 Fichiers Importants

### Consultation Rapide
| Besoin | Fichier |
|--------|---------|
| Voir tout | `README_COMPLET.md` |
| Setup détaillé | `SETUP_GUIDE.md` |
| Tester API | `API_TEST.md` |
| Checklist | `CHECKLIST.md` |
| Résumé corrections | `RESUME_CORRECTIONS.md` |

### Backend
| Fichier | Statut |
|---------|--------|
| `server.js` | ✅ Corrigé |
| `routes/messages.js` | ✅ Nouveau |
| `routes/notifications.js` | ✅ Nouveau |

### Frontend
| Fichier | Statut |
|---------|--------|
| `lib/services/api_service.dart` | ✅ Rewritten |
| `lib/config/app_config.dart` | ✅ Nouveau |

---

## 🆘 Erreurs Couantes

| Erreur | Fixer |
|--------|-------|
| MySQL connection refused | Lancer WampServer |
| Database not found | Importer SQL dans phpMyAdmin |
| Port 3001 used | Tuer node: `taskkill /F /IM node.exe` |
| API not responding | Vérifier URL dans `app_config.dart` |

---

## ✅ Vérifier que tout marche

1. ✅ Écran de connexion s'affiche
2. ✅ Peut créer un compte
3. ✅ Peut se connecter
4. ✅ Dashboard s'affiche
5. ✅ Peut voir les offres

**Si les 5 points sont OK → TOUT MARCHE! 🎉**

---

## 🔗 Routes Utiles

```
Offers:      GET http://localhost:3001/api/offers
Auth:        POST http://localhost:3001/api/auth/login
Messages:    GET http://localhost:3001/api/messages/conversations
```

---

## 💾 Configuration Modifiable

**Fichier:** `lib/config/app_config.dart` (ligne ~15)

```dart
// Windows/Web
'http://localhost:3001/api'

// Android Émulateur
'http://10.0.2.2:3001/api'

// Téléphone réel
'http://192.168.X.X:3001/api' // Votre IP locale
```

---

## 📞 En cas de problème

1. Consulter `README_COMPLET.md` (section troubleshooting)
2. Vérifier les logs du terminal
3. Consulter `API_TEST.md` pour tester manuellement

---

**✅ Vous êtes prêt! Lancez l'app et amusez-vous! 🎉**
