# 📊 GUIDE COMPLET - SAUVEGARDE DES DONNÉES DANS `bddiane_sp`

## 🎯 OBJECTIF
Vérifier que **TOUTES** les informations sont sauvegardées directement dans la base de données MySQL `bddiane_sp`.

---

## ✅ STATUT ACTUEL DE VOTRE APPLICATION

### Architecture
```
Frontend (Flutter/Chrome) 
    ↓ (API REST)
Backend (Node.js) 
    ↓ (MySQL Queries)
BDD (MySQL - bddiane_sp)
```

### Fichiers Clés Configurés
- ✅ `afrijob_backend/config/database.js` → Connecté à `bddiane_sp`
- ✅ `afrijob_backend/.env` → `DB_NAME=bddiane_sp`
- ✅ `lib/api_service.dart` → Envoie les données au backend
- ✅ Routes API → Sauvegardent en BDD

---

## 🚀 ÉTAPES DE DÉMARRAGE

### 1️⃣ Démarrer MySQL (WAMP)

**Sur Windows:**
```
1. Clic sur l'icône WAMP en bas à droite
2. Sélectionner "MySQL"
3. Cliquer "Start MySQL"
4. Attendre que l'icône devienne VERTE
```

**Vérifier la connexion:**
```
Ouvrir: http://localhost/phpmyadmin
Vous verrez la page phpMyAdmin = MySQL est actif ✅
```

### 2️⃣ Importer la Base de Données

**Via phpMyAdmin:**
```
1. Aller sur http://localhost/phpmyadmin
2. Cliquer "Import" en haut
3. Sélectionner le fichier: c:\Users\SYST\Desktop\mon_application_job\bddiane_sp.sql
4. Cliquer "Import"
5. Attendre le message de succès ✅
```

**Vérifier l'import:**
```sql
-- Exécuter dans phpMyAdmin → Onglet "SQL"
SHOW TABLES IN bddiane_sp;

-- Vous devez voir:
-- abonnements
-- candidats
-- candidatures
-- entreprises
-- offres
-- utilisateurs
-- (et autres tables)
```

### 3️⃣ Installer les Dépendances du Backend

```bash
cd c:\Users\SYST\Desktop\mon_application_job\afrijob_backend
npm install
```

### 4️⃣ Démarrer le Backend

```bash
cd c:\Users\SYST\Desktop\mon_application_job\afrijob_backend
npm start
```

**Succès = Vous verrez:**
```
✅ Connecté à MySQL — base: bddiane_sp
✅ Serveur actif sur http://localhost:3001
```

### 5️⃣ Démarrer le Frontend

Dans un nouveau terminal PowerShell:
```bash
cd c:\Users\SYST\Desktop\mon_application_job
flutter run -d chrome
```

---

## 🧪 TESTS DE VÉRIFICATION

### TEST 1: Inscription Candidat

**Actions:**
1. Cliquer "S'inscrire" (candidat)
2. Remplir:
   - Email: `test.candidat@gmail.com`
   - Mot de passe: `TestPass123`
   - Nom: `Jean Dupont`
   - Filière: `Informatique`
   - Téléphone: `0123456789`
   - Âge: `25`
   - Domicile: `Dakar`

3. Cliquer "S'inscrire"

**Vérifier en BDD (phpMyAdmin):**

```sql
-- Table: utilisateurs
SELECT * FROM utilisateurs WHERE email = 'test.candidat@gmail.com';
-- Doit voir: id, email, mot_de_passe (hashedé), type_utilisateur='candidat'

-- Table: candidats
SELECT * FROM candidats WHERE id = (SELECT id FROM utilisateurs WHERE email = 'test.candidat@gmail.com');
-- Doit voir: id, nom_complet='Jean Dupont', telephone='0123456789', filiere_specialite='Informatique', etc.
```

✅ **Résultat attendu:** 2 lignes créées (utilisateurs + candidats)

---

### TEST 2: Connexion et Token

**Actions:**
1. Cliquer "Se connecter"
2. Entrer:
   - Email: `test.candidat@gmail.com`
   - Mot de passe: `TestPass123`
3. Cliquer "Connexion"

**À vérifier dans Chrome DevTools (F12):**

```
DevTools → Application → Local Storage
Vous verrez un token JWT sauvegardé ✅
Format: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

✅ **Résultat attendu:** Token sauvegardé localement + connexion réussie

---

### TEST 3: Affichage des Offres (depuis BDD)

**Actions:**
1. Être connecté
2. Aller à l'onglet "Offres"
3. Les offres doivent s'afficher

**Vérifier en BDD:**

```sql
-- Table: offres
SELECT * FROM offres LIMIT 5;
-- Doit voir: id, titre, description, entreprise_id, lieu, type_contrat, salaire, etc.

-- Offres par entreprise:
SELECT o.titre, o.lieu, e.nom_societe 
FROM offres o 
JOIN entreprises e ON o.entreprise_id = e.id 
LIMIT 5;
```

✅ **Résultat attendu:** Les offres dans l'app = Les offres dans BDD

---

### TEST 4: Candidature (Sauvegarde Principale)

**Actions:**
1. Être connecté en tant que candidat
2. Trouver une offre
3. Cliquer "Postuler"
4. Confirmez

**Vérifier en BDD - C'EST LA LIGNE MAÎTRESSE:**

```sql
-- Table: candidatures
SELECT * FROM candidatures 
WHERE candidat_id = (SELECT id FROM utilisateurs WHERE email = 'test.candidat@gmail.com');

-- Ou vue simplifiée:
SELECT 
    c.id,
    c.candidat_id,
    c.offre_id,
    c.statut,
    c.date_postulation,
    cand.nom_complet,
    o.titre as offre_titre
FROM candidatures c
JOIN candidats cand ON c.candidat_id = cand.id
JOIN offres o ON c.offre_id = o.id
ORDER BY c.date_postulation DESC;
```

✅ **Résultat attendu:**
```
id    candidat_id  offre_id  statut     date_postulation         nom_complet    offre_titre
123   2            5         En cours   2026-06-15 14:30:00      Jean Dupont    Développeur JS
```

---

### TEST 5: Upload de Photo/CV (Fichiers)

**Actions:**
1. Aller au profil
2. Cliquer "Ajouter Photo"
3. Sélectionner une image
4. Attendre le succès

**Vérifier:**

```
1. Fichier sauvegardé sur disque: 
   Parcourir: c:\Users\SYST\Desktop\mon_application_job\afrijob_backend\uploads
   Vous verrez: 1623845678-123456789.jpg

2. URL sauvegardée en BDD:
   SELECT photo_profil_url FROM candidats 
   WHERE id = 2;
   Doit voir: http://localhost:3001/uploads/1623845678-123456789.jpg
```

✅ **Résultat attendu:** Fichier sur disque + URL en BDD + Image affichée dans l'app

---

### TEST 6: Offre Créée par Entreprise

**Actions (si vous avez compte entreprise):**
1. Se connecter en tant qu'entreprise
2. Aller à "Mes Offres"
3. Cliquer "Créer une Offre"
4. Remplir:
   - Titre: `Développeur Python`
   - Description: `Rejoignez notre équipe...`
   - Type: `CDI`
   - Lieu: `Dakar`
   - Salaire: `500000`
5. Publier

**Vérifier en BDD:**

```sql
-- Voir l'offre créée:
SELECT * FROM offres 
WHERE titre = 'Développeur Python'
AND entreprise_id = (SELECT id FROM utilisateurs WHERE email = 'votre-email-entreprise');

-- Voir avec l'entreprise:
SELECT o.titre, o.lieu, e.nom_societe, o.date_publication
FROM offres o
JOIN entreprises e ON o.entreprise_id = e.id
WHERE e.id = 1;
```

✅ **Résultat attendu:** Offre visible en BDD + Visible dans l'app publique

---

## 🔗 FLUX DE DONNÉES COMPLET

```
┌─ INSCRIPTION ─┐
│ Frontend      │
│  (Form)       │ → POST /api/auth/register
│               │   {email, password, nom, ...}
└─ Envoi ───────┘
                   ↓
         ┌─────────────────────┐
         │ Backend (Node.js)   │
         │ server.js/auth.js   │
         │ - Hash password     │
         │ - Crée JWT token    │
         └─────────────────────┘
                   ↓
         ┌─────────────────────┐
         │ MySQL Queries       │
         │ INSERT utilisateurs │
         │ INSERT candidats    │
         └─────────────────────┘
                   ↓
         ┌─────────────────────┐
         │ bddiane_sp BDD      │
         │ Lignes créées ✅    │
         └─────────────────────┘
```

---

## ❌ DÉPANNAGE

### Problème: "Erreur de connexion à la base de données"

**Solutions:**
1. ✅ Vérifier MySQL est démarré (WAMP vert)
2. ✅ Vérifier `bddiane_sp` existe en phpMyAdmin
3. ✅ Vérifier `.env` a bon `.DB_NAME=bddiane_sp`
4. ✅ Redémarrer backend: `npm start`

### Problème: "Frontend ne se connecte pas au backend"

**Vérifier:**
1. ✅ Backend tourne sur http://localhost:3001
2. ✅ Pas de firewall bloquant
3. ✅ `api_service.dart` a bon baseUrl: `http://localhost:3001/api`
4. ✅ Console Chrome (F12) pour voir erreurs réseau

### Problème: "Les offres ne s'affichent pas"

**Vérifier:**
1. ✅ Table `offres` a des données: `SELECT COUNT(*) FROM offres;`
2. ✅ Route API `/api/offers` fonctionne
3. ✅ Console backend: `GET /api/offers` visible
4. ✅ Console Chrome (F12) pour voir réponse HTTP

### Problème: "Les candidatures ne sont pas en BDD"

**Vérifier:**
1. ✅ Token JWT est envoyé: `Authorization: Bearer <token>`
2. ✅ Backend reçoit token: Console backend log de la requête
3. ✅ Vérifier erreur: `SELECT * FROM candidatures;` vide?
4. ✅ Logs backend pour voir erreur MySQL

---

## 📋 CHECKLIST FINALE

Quand vous avez terminé les tests, cette checklist doit être 100% ✅:

- [ ] **MySQL** démarré (WAMP vert)
- [ ] **bddiane_sp** importée et visible en phpMyAdmin
- [ ] **Backend** démarre sans erreur (`✅ Connecté à MySQL`)
- [ ] **Frontend** s'ouvre dans Chrome
- [ ] **Inscription** crée lignes en `utilisateurs` + `candidats`
- [ ] **Connexion** fonctionne et sauvegarde token
- [ ] **Offres** chargées depuis `offres` table
- [ ] **Candidature** crée ligne en `candidatures` table
- [ ] **Photos/CV** sauvegardés en dossier `uploads/`
- [ ] **URLs des fichiers** en BDD dans les colonnes `*_url`
- [ ] **Pas d'erreur** en Chrome DevTools (F12 → Console)
- [ ] **Pas d'erreur** dans la console du terminal Backend

---

## 🎓 RÉSUMÉ POUR CHAQUE TABLE

| Table | Quand? | Qui crée? | Vérifier |
|-------|--------|-----------|----------|
| **utilisateurs** | Inscription | `/auth/register` | Email unique, mot_de_passe hashedé |
| **candidats** | Inscription (candidat) | `/auth/register` | Lié à utilisateurs.id |
| **entreprises** | Inscription (entreprise) | `/auth/register` | Lié à utilisateurs.id |
| **offres** | Entreprise crée offre | `/offers POST` | entreprise_id valide |
| **candidatures** | Candidat postule | `/applications POST` | candidat_id + offre_id uniques |
| **abonnements** | Paiement effectué | Service paiement | date_fin, statut |

---

## 🆘 BESOIN D'AIDE?

Si vous avez des erreurs spécifiques:

1. **Copiez le message d'erreur exact**
2. **Vérifiez le fichier d'erreur:**
   - Backend console: `npm start` output
   - Frontend console: Chrome F12 → Console tab
   - BDD: phpMyAdmin query results
3. **Vérifiez les logs MySQL** pour les SQL errors

---

**✅ Dernière vérification: Testez d'une couche à l'autre**

```bash
# Terminal 1: Backend
cd afrijob_backend
npm start

# Terminal 2: Frontend
flutter run -d chrome

# Terminal 3: MySQL Checker
mysql -u root bddiane_sp -e "SELECT COUNT(*) FROM utilisateurs;"
```

Quand tout fonctionne, vous verrez les données croître dans les tables en temps réel! 🚀
