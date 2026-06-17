# 🚀 DEMARRAGE RAPIDE - 5 MINUTES

## ⚡ TL;DR - Les 3 Commandes pour Tester

### Terminal 1 - Backend
```bash
cd c:\Users\SYST\Desktop\mon_application_job\afrijob_backend
npm start
```
✅ Attendez: `✅ Serveur actif sur http://localhost:3001`

### Terminal 2 - Frontend
```bash
cd c:\Users\SYST\Desktop\mon_application_job
flutter run -d chrome
```
✅ Attendez: Chrome s'ouvre automatiquement

### Utiliser l'App
1. Créer compte candidat → Données en BDD
2. Se connecter → Token sauvegardé
3. Voir les offres → Depuis la BDD
4. Postuler → Candidature en BDD

---

## 📋 PRÉ-REQUIS (5 min)

### ✅ Vérifier MySQL
```bash
# PhpMyAdmin (si WAMP):
http://localhost/phpmyadmin

# Vérifier que:
1. MySQL/WAMP est lancé
2. Base de données 'bddiane_sp' existe
```

### ✅ Vérifier Node.js
```bash
node --version  # Doit afficher v22.x.x
npm --version   # Doit afficher une version
```

### ✅ Vérifier Flutter
```bash
flutter --version
flutter config --no-analytics
```

---

## 🎯 LES 3 TESTS ESSENTIELS

### TEST 1: Inscription Candidat (2 min)
```
1. Ouvrir l'app dans Chrome
2. Cliquer "Candidat" (en haut)
3. Remplir:
   - Nom: Jean Dupont
   - Email: jean@test.com
   - Mot de passe: test123
   - Filière: Informatique
4. Cliquer "S'inscrire"
5. ✅ Vérifier en PhpMyAdmin:
   - Table: utilisateurs
   - Nouvelle ligne avec email jean@test.com
```

### TEST 2: Connexion (1 min)
```
1. Cliquer "Connexion"
2. Email: jean@test.com
3. Mot de passe: test123
4. Cliquer "Se connecter"
5. ✅ Devrait afficher le tableau de bord
```

### TEST 3: Candidature (2 min)
```
1. Cliquer "Mes Offres" (menu gauche)
2. Voir une offre et cliquer "Postuler"
3. Remplir le formulaire
4. Cliquer "Valider"
5. ✅ Vérifier en PhpMyAdmin:
   - Table: candidatures
   - Nouvelle ligne avec candidat_id + offre_id
```

---

## 🔧 SI ERREUR

### ❌ "Cannot POST /api/auth/register"
```
Cause: Backend ne démarre pas
Solution:
1. Vérifier que MySQL est actif
2. Vérifier Terminal 1: le backend doit dire "✅ Connecté à MySQL"
3. Relancer: npm start
```

### ❌ "Connection refused localhost:3001"
```
Cause: Backend arrêté
Solution:
1. Relancer Terminal 1
2. npm start
3. Attendre le message ✅
```

### ❌ Aucune offre n'apparaît
```
Cause: Pas d'offres en BDD
Solution:
1. Via PhpMyAdmin, table 'offres'
2. Cliquer "Insérer"
3. Ajouter une offre:
   - titre: "Dev Flutter"
   - description: "test"
   - type_contrat: "Stage"
   - lieu: "Ouagadougou"
   - entreprise_id: 1
4. Recharger l'app (F5)
```

### ❌ Les données ne sont pas en BDD
```
Cause: Erreur API
Solution:
1. Ouvrir DevTools (F12)
2. Onglet "Network"
3. Vérifier les réponses des POST
4. Regarder les "Error" en rouge
5. Cliquer dessus pour voir le détail
```

---

## 📊 VÉRIFIER LES DONNÉES

### Via PhpMyAdmin
```
1. Ouvrir http://localhost/phpmyadmin
2. Sélectionner base 'bddiane_sp'
3. Voir les tables:
   - utilisateurs (inscriptions)
   - candidats (info candidats)
   - entreprises (info entreprises)
   - offres (jobs publiés)
   - candidatures (postulations)
```

### Via MySQL CLI
```bash
mysql -u root -p
use bddiane_sp;
SELECT * FROM utilisateurs;
SELECT * FROM candidatures;
```

---

## ✨ FICHIERS MODIFIÉS

✅ **Tous les problèmes ont été corrigés:**

| Fichier | Problème | Solution |
|---------|----------|----------|
| `afrijob_backend/server.js` | Code dupliqué, pas CORS | ✅ Nettoyé, CORS ajouté |
| `lib/api_service.dart` | URL émulateur | ✅ Changé pour localhost |
| `lib/auth_screen.dart` | Token pas sauvegardé | ✅ saveToken() ajouté |
| `lib/candidate_dashboard.dart` | Offres en dur | ✅ Chargées depuis API |
| `lib/candidate_dashboard.dart` | Candidatures locales | ✅ Envoyées au serveur |

---

## 🎉 RÉSUMÉ

**Avant:** App locale, aucune donnée en BDD
**Après:** Toutes les données vont en BDD `bddiane_sp` 

**Pour utiliser:**
1. `npm start` (Terminal 1)
2. `flutter run -d chrome` (Terminal 2)
3. Créer compte → Voir en BDD
4. Postuler → Voir en BDD

**Questions?** Consulter:
- `CORRECTIONS_APPLIQUEES.md` - Détails techniques
- `LANCER_APP.md` - Guide complet
- `RESUME_CORRECTIONS.md` - Vue d'ensemble

