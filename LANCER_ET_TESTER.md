# 🚀 GUIDE COMPLET - LANCER ET TESTER AFRIJOB

## 📋 SOMMAIRE
1. ✅ Préparer MySQL/WAMP
2. ✅ Lancer le Backend
3. ✅ Lancer le Frontend
4. ✅ Tester Inscription
5. ✅ Tester Connexion
6. ✅ Tester Candidature
7. ✅ Vérifier les Données

**Durée totale: 15-20 minutes**

---

## ⏱️ ÉTAPE 1: PRÉPARER MYSQL/WAMP (2 minutes)

### A. Démarrer WAMP Server

**Localiser l'icône WAMP:**
- 👉 Regardez en bas à droite du bureau (Taskbar Windows)
- 🔍 Cherchez une icône verte ou rouge avec "W"

**Actions:**
1. Clic droit sur l'icône WAMP
2. Voir le menu:
   ```
   Start All
   MySQL
   Apache
   ...
   ```
3. Cliquer sur **"Start All"** (ou juste MySQL)

**Attendre que l'icône devienne VERTE** (30 secondes)

### B. Vérifier que MySQL Fonctionne

**Actions:**
1. Ouvrir navigateur (Chrome, Firefox, Edge)
2. Aller à: `http://localhost/phpmyadmin`
3. Vous devez voir la page phpMyAdmin

**Résultat attendu:**
```
phpMyAdmin interface
├─ localhost
├─ Databases
│  └─ bddiane_sp  ← DOIT EXISTER
└─ [Database list...]
```

✅ **Si vous voyez `bddiane_sp`, MySQL fonctionne!**

### C. Si bddiane_sp N'existe PAS

**Actions pour importer:**
1. Dans phpMyAdmin: cliquer "Import" (en haut)
2. Cliquer "Parcourir"
3. Sélectionner: `c:\Users\SYST\Desktop\mon_application_job\bddiane_sp.sql`
4. Cliquer "Import"
5. Attendre le message de succès

✅ **Maintenant `bddiane_sp` doit exister**

---

## ⏱️ ÉTAPE 2: LANCER LE BACKEND (3 minutes)

### A. Ouvrir PowerShell Première Fenêtre

**Actions:**
1. **Clic droit sur le bureau**
2. Chercher "PowerShell" ou "Terminal"
3. Cliquer "PowerShell" (pas "Git Bash")
4. Une fenêtre noire s'ouvre

### B. Naviguer vers le Backend

**Copier/Coller dans la fenêtre PowerShell:**

```powershell
cd "c:\Users\SYST\Desktop\mon_application_job\afrijob_backend"
```

Appuyez sur **ENTRÉE**

**Résultat attendu:**
```
PS c:\Users\SYST\Desktop\mon_application_job\afrijob_backend>
```

### C. Installer les Dépendances (SI JAMAIS)

**Si le dossier `node_modules` N'EXISTE PAS:**

```powershell
npm install
```

Appuyez sur **ENTRÉE**

⏳ **Attendre 1-2 minutes** (télécharge les packages)

**Résultat attendu:**
```
added X packages in Ys
```

### D. Démarrer le Backend

**Taper:**
```powershell
npm start
```

Appuyez sur **ENTRÉE**

**Attendre 2-3 secondes...**

**Résultat attendu (TRÈS IMPORTANT):**
```
✅ Connecté à MySQL — base: bddiane_sp
✅ Serveur actif sur http://localhost:3001
```

✅ **Le Backend est PRÊT!** Ne fermez pas cette fenêtre!

**Vérifier que le serveur répond:**
- Ouvrir Chrome
- Aller à: `http://localhost:3001/health`
- Vous devez voir: `{"status":"OK","message":"Serveur actif"}`

✅ **Backend fonctionne!**

---

## ⏱️ ÉTAPE 3: LANCER LE FRONTEND (3 minutes)

### A. Ouvrir PowerShell Deuxième Fenêtre

**Actions:**
1. **Clic droit sur le bureau** (à nouveau)
2. Cliquer "PowerShell" (nouvelle fenêtre)
3. Une deuxième fenêtre noire s'ouvre

### B. Naviguer vers le Frontend

**Copier/Coller:**

```powershell
cd "c:\Users\SYST\Desktop\mon_application_job"
```

Appuyez sur **ENTRÉE**

**Résultat attendu:**
```
PS c:\Users\SYST\Desktop\mon_application_job>
```

### C. Lancer Flutter en Chrome

**Taper:**

```powershell
flutter run -d chrome
```

Appuyez sur **ENTRÉE**

**Attendre 5-10 secondes...**

**Résultat attendu:**
```
Launching lib/main.dart on Chrome in debug mode...
[Compilation Output...]
Chrome will open in a moment...
```

✅ **Chrome s'ouvre automatiquement avec l'app!**

**Vous devez voir:**
```
AfriJob
┌─ S'inscrire
└─ Se connecter
```

✅ **Frontend est PRÊT!**

---

## ⏱️ ÉTAPE 4: TESTER INSCRIPTION (3 minutes)

### A. Remplir le Formulaire d'Inscription

**Dans la fenêtre Chrome:**

1. Cliquer **"S'inscrire"**

2. Sélectionner **"Candidat"** (radio button)

3. **Remplir les champs:**

| Champ | Valeur |
|-------|--------|
| Email | `test.candidat@gmail.com` |
| Mot de passe | `TestPass123` |
| Confirmation | `TestPass123` |
| Nom Complet | `Jean Dupont` |
| Téléphone | `0123456789` |
| Filière | `Informatique` |
| Âge | `25` |
| Domicile | `Dakar` |
| Sexe | `Masculin` |

### B. Cliquer "S'inscrire"

**Actions:**
1. Cliquer le bouton **"S'inscrire"**
2. **Attendre 2-3 secondes**

**Résultat attendu:**
```
✅ Inscription réussie!
Redirection vers la connexion...
```

✅ **Inscription fonctionne!**

### C. Vérifier en BDD

**Ouvrir phpMyAdmin:**
1. Chrome: `http://localhost/phpmyadmin`
2. Naviguer: **bddiane_sp** → **utilisateurs**
3. Chercher: `test.candidat@gmail.com`

**Vous devez voir:**
```
id  | email                    | type_utilisateur | mot_de_passe
1   | test.candidat@gmail.com  | candidat         | $2a$10$... (hashé)
```

✅ **Données créées en BDD!**

**Vérifier aussi table `candidats`:**
1. phpMyAdmin: **bddiane_sp** → **candidats**
2. Vous devez voir: `Jean Dupont`, `0123456789`, `Informatique`, etc.

✅ **Profil candidat créé!**

---

## ⏱️ ÉTAPE 5: TESTER CONNEXION (2 minutes)

### A. Se Connecter

**Dans Chrome (l'app):**

1. Vous êtes sur la page **"Se connecter"** (après inscription)

2. **Remplir:**
   - Email: `test.candidat@gmail.com`
   - Mot de passe: `TestPass123`

3. Cliquer **"Se connecter"**

4. **Attendre 2-3 secondes**

**Résultat attendu:**
```
✅ Connexion réussie!
Bienvenue Jean Dupont!
Redirection vers le dashboard...
```

✅ **Connexion fonctionne!**

### B. Vérifier le Token JWT

**Ouvrir Chrome DevTools:**

1. Appuyer sur **F12** (ou Ctrl+Shift+I)
2. Aller à l'onglet **"Application"**
3. Dans la gauche: **"Local Storage"**
4. Cliquer **"http://localhost"**

**Vous devez voir:**
```
Key: token
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

✅ **Token sauvegardé!**

---

## ⏱️ ÉTAPE 6: TESTER CANDIDATURE (5 minutes)

### A. Accéder aux Offres

**Dans la fenêtre Chrome:**

1. Vous êtes sur le **Dashboard Candidat**
2. Voir les onglets:
   ```
   ├─ Offres
   ├─ Mes Candidatures
   └─ Profil
   ```

3. Cliquer **"Offres"**

4. **Attendre 2-3 secondes** (chargement des offres)

**Résultat attendu:**
```
Liste des offres
├─ Titre: Développeur Python
│  Entreprise: TechStart
│  Lieu: Dakar
│  Salaire: 500000
│  [Postuler]
│
└─ Titre: Designer UX
   Entreprise: Digital Agency
   Lieu: Dakar
   Salaire: 400000
   [Postuler]
```

✅ **Les offres se chargent depuis la BDD!**

### B. Postuler à Une Offre

**Actions:**

1. Choisir une offre (par exemple "Développeur Python")

2. Cliquer **"Postuler"**

3. **Confirmation popup:**
   ```
   ✅ Êtes-vous sûr de postuler à cette offre?
   [Annuler] [Postuler]
   ```

4. Cliquer **"Postuler"** (dans la popup)

5. **Attendre 1-2 secondes**

**Résultat attendu:**
```
✅ Candidature envoyée avec succès!
L'offre s'ajoute à "Mes Candidatures"
```

✅ **Candidature fonctionne!**

### C. Vérifier en BDD (TRÈS IMPORTANT!)

**Ouvrir phpMyAdmin:**
1. Chrome: `http://localhost/phpmyadmin`
2. **bddiane_sp** → **candidatures**

**Vous devez voir:**
```
id | candidat_id | offre_id | statut    | date_postulation
1  | 1           | 1        | En cours  | 2026-06-15 14:30:00
```

✅ **Candidature sauvegardée en BDD!**

### D. Vérifier "Mes Candidatures"

**Dans l'app Chrome:**

1. Cliquer onglet **"Mes Candidatures"**

2. **Attendre 2 secondes** (chargement)

**Résultat attendu:**
```
Mes candidatures
├─ Développeur Python
│  TechStart - Dakar
│  Status: En cours
│  Date: 15/06/2026
│
└─ (Autres candidatures si présentes)
```

✅ **Candidatures affichées correctement!**

---

## ⏱️ ÉTAPE 7: VÉRIFICATION COMPLÈTE EN BDD (2 minutes)

### A. Résumé des Données Créées

**Ouvrir phpMyAdmin et vérifier chaque table:**

**1️⃣ Table: utilisateurs**
```
SELECT * FROM utilisateurs;
```

**Résultat:**
```
id | email                    | type_utilisateur | date_inscription
1  | test.candidat@gmail.com  | candidat         | 2026-06-15 11:30:00
```

✅ Utilisateur créé

---

**2️⃣ Table: candidats**
```
SELECT * FROM candidats WHERE id = 1;
```

**Résultat:**
```
id | nom_complet | telephone    | filiere_specialite | age | domicile
1  | Jean Dupont | 0123456789   | Informatique       | 25  | Dakar
```

✅ Profil candidat créé

---

**3️⃣ Table: offres**
```
SELECT * FROM offres;
```

**Résultat:**
```
id | titre              | entreprise_id | lieu  | salaire | type_contrat
1  | Développeur Python | 1             | Dakar | 500000  | CDI
2  | Designer UX        | 2             | Dakar | 400000  | CDI
...
```

✅ Offres existent

---

**4️⃣ Table: candidatures (LA PLUS IMPORTANTE)**
```
SELECT 
    c.id, 
    c.candidat_id, 
    c.offre_id, 
    c.statut, 
    c.date_postulation,
    cand.nom_complet,
    o.titre
FROM candidatures c
JOIN candidats cand ON c.candidat_id = cand.id
JOIN offres o ON c.offre_id = o.id;
```

**Résultat:**
```
id | candidat_id | offre_id | statut    | date_postulation     | nom_complet | titre
1  | 1           | 1        | En cours  | 2026-06-15 14:30:00  | Jean Dupont | Développeur Python
```

✅ **CANDIDATURE SAUVEGARDÉE EN BDD!** 🎉

---

### B. Résumé Complet

**Résumé rapide:**
```sql
SELECT 
    (SELECT COUNT(*) FROM utilisateurs) as "Utilisateurs",
    (SELECT COUNT(*) FROM candidats) as "Candidats",
    (SELECT COUNT(*) FROM entreprises) as "Entreprises",
    (SELECT COUNT(*) FROM offres) as "Offres",
    (SELECT COUNT(*) FROM candidatures) as "Candidatures";
```

**Résultat attendu:**
```
Utilisateurs | Candidats | Entreprises | Offres | Candidatures
1            | 1         | 2+          | 2+     | 1+
```

✅ **Tous les compteurs augmentent!**

---

## 🎯 RÉSUMÉ DES TESTS

| Test | Résultat | Status |
|------|----------|--------|
| WAMP MySQL | ✅ phpMyAdmin accessible | ✅ OK |
| Backend | ✅ `http://localhost:3001/health` répond | ✅ OK |
| Frontend | ✅ Chrome s'ouvre avec l'app | ✅ OK |
| Inscription | ✅ Données en table `utilisateurs` | ✅ OK |
| Connexion | ✅ Token en Local Storage | ✅ OK |
| Offres | ✅ Chargées depuis table `offres` | ✅ OK |
| Candidature | ✅ Données en table `candidatures` | ✅ OK |
| **GLOBAL** | ✅ **TOUT FONCTIONNE** | ✅ **OK** |

---

## 🔄 TESTER PLUSIEURS FOIS

### Créer un Deuxième Candidat

**Répéter ÉTAPE 4 avec:**
- Email: `test.candidat2@gmail.com`
- Nom: `Marie Dupont`

**Vérifier:**
- Deux lignes en `utilisateurs`
- Deux lignes en `candidats`

---

### Tester Connexion Entre Deux Candidats

1. **Première candidat:** Se connecter
2. Postuler
3. Se déconnecter
4. **Deuxième candidat:** Se connecter
5. Postuler à une autre offre
6. Vérifier en BDD: 2 candidatures différentes

---

## 💡 TIPS & TRICKS

### Afficher la Console du Backend

**Dans la fenêtre PowerShell du Backend, vous verrez:**
```
GET /api/offers
POST /api/applications
...
```

Ça montre les requêtes reçues ✅

---

### Afficher la Console Frontend

**Chrome F12 → Console:**

Vous verrez:
```
✓ Offres chargées
✓ Candidature envoyée
```

Ça montre ce qui se passe côté app ✅

---

### Rafraîchir l'App

**Si l'app freeze ou buggue:**

1. Chrome: Appuyer **F5** (ou Ctrl+R)
2. Vous resterez connecté (token sauvegardé)

---

## ❌ DÉPANNAGE RAPIDE

### Problème: "Cannot GET /health"

**Solution:**
1. Vérifier Backend tourne (`npm start` dans PowerShell 1)
2. Vérifier pas de message d'erreur en rouge
3. Relancer: `Ctrl+C` puis `npm start`

---

### Problème: "Failed to connect to server"

**Solution:**
1. Vérifier Backend sur `http://localhost:3001`
2. Vérifier api_service.dart a bon baseUrl
3. Vérifier pas de firewall bloquant

---

### Problème: "Table bddiane_sp not found"

**Solution:**
1. Vérifier MySQL WAMP est vert
2. Vérifier bddiane_sp existe en phpMyAdmin
3. Si absent: Importer bddiane_sp.sql (voir ÉTAPE 1.C)

---

### Problème: "Cannot INSERT... Duplicate entry"

**Solution:**
- C'est normal! Ça veut dire vous avez déjà postulé
- Essayer une autre offre
- Ou créer un nouveau candidat

---

## ✅ CHECKLIST FINALE

Quand tous les tests passent:

- [ ] ✅ WAMP MySQL vert
- [ ] ✅ phpMyAdmin accessible
- [ ] ✅ bddiane_sp importée
- [ ] ✅ Backend démarre sans erreur
- [ ] ✅ Frontend s'ouvre dans Chrome
- [ ] ✅ Inscription crée données en BDD
- [ ] ✅ Connexion sauvegarde token
- [ ] ✅ Offres chargées depuis BDD
- [ ] ✅ Candidatures créées en BDD
- [ ] ✅ Pas d'erreur en Chrome F12
- [ ] ✅ Pas d'erreur en PowerShell Backend

**TOUS ✅ = APPLICATION COMPLÈTEMENT FONCTIONNELLE!** 🎉

---

## 🎓 PROCHAINES ÉTAPES (Optionnel)

Une fois tout fonctionnant:

1. **Tester avec plusieurs candidats**
2. **Tester compte entreprise**
3. **Créer des offres d'emploi**
4. **Tester upload de photos/CV**
5. **Vérifier paiement** (si implémenté)

---

**✨ Vous êtes prêt! Commencez par ÉTAPE 1!** 🚀
