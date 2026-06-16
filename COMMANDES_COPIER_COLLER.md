# ⚡ COMMANDES À COPIER/COLLER

## 📋 TABLE DES MATIÈRES
- Préparation
- Backend
- Frontend
- Vérification BDD
- Dépannage

---

## 🟢 PRÉPARATION

### 1. Vérifier que MySQL fonctionne

**Ouvrir navigateur et copier:**
```
http://localhost/phpmyadmin
```

**Vous devez voir phpMyAdmin**

### 2. Si bddiane_sp n'existe pas, l'importer

**Dans phpMyAdmin:**
1. Cliquer "Import"
2. Chercher: `C:\Users\SYST\Desktop\mon_application_job\bddiane_sp.sql`
3. Cliquer "Import"

---

## 🟢 BACKEND - POWERSHELL 1

### 1. Ouvrir PowerShell

**Clic droit bureau → Open with PowerShell**

### 2. Naviguer au dossier

**Copier/Coller cette commande:**
```powershell
cd "c:\Users\SYST\Desktop\mon_application_job\afrijob_backend"
```

Appuyer **ENTRÉE**

### 3. Installer (si jamais)

**Si le dossier `node_modules` n'existe pas:**
```powershell
npm install
```

Attendre la fin (1-2 minutes)

### 4. Démarrer

**Copier/Coller:**
```powershell
npm start
```

Appuyer **ENTRÉE**

**Attendre 3 secondes**

**Vous verrez:**
```
✅ Connecté à MySQL — base: bddiane_sp
✅ Serveur actif sur http://localhost:3001
```

✅ **Backend est PRÊT! Ne pas fermer cette fenêtre!**

### 5. Vérifier que ça marche

**Ouvrir Chrome et aller à:**
```
http://localhost:3001/health
```

**Résultat attendu:**
```json
{"status":"OK","message":"Serveur actif"}
```

✅ **Backend répond!**

---

## 🟢 FRONTEND - POWERSHELL 2 (NOUVELLE FENÊTRE)

### 1. Ouvrir PowerShell 2

**Clic droit bureau → Open with PowerShell (NOUVELLE FENÊTRE)**

### 2. Naviguer au dossier

**Copier/Coller:**
```powershell
cd "c:\Users\SYST\Desktop\mon_application_job"
```

Appuyer **ENTRÉE**

### 3. Lancer Flutter

**Copier/Coller:**
```powershell
flutter run -d chrome
```

Appuyer **ENTRÉE**

**Attendre 10-15 secondes**

**Chrome s'ouvre automatiquement avec l'app**

✅ **Frontend est PRÊT!**

---

## 🟢 TESTER - DANS CHROME

### 1. S'inscrire

**Cliquer "S'inscrire"**

**Remplir avec ces données exactes:**

```
Type: Candidat ✓

Email: test.candidat@gmail.com
Mot de passe: TestPass123
Confirmation: TestPass123

Nom Complet: Jean Dupont
Téléphone: 0123456789
Filière: Informatique
Âge: 25
Domicile: Dakar
Sexe: Masculin
```

**Cliquer "S'inscrire"**

**Attendre 3 secondes**

✅ **"Inscription réussie"**

### 2. Se connecter

**Cliquer "Se connecter"**

**Remplir:**
```
Email: test.candidat@gmail.com
Mot de passe: TestPass123
```

**Cliquer "Se connecter"**

✅ **Bienvenue Jean Dupont!**

### 3. Postuler

**Cliquer onglet "Offres"**

**Attendre 2 secondes (chargement)**

**Cliquer "Postuler" sur une offre**

**Cliquer "Postuler" (popup)**

✅ **"Candidature envoyée"**

---

## 🟢 VÉRIFICATION BDD - PHPMYADMIN

### 1. Ouvrir phpMyAdmin

**Aller à:**
```
http://localhost/phpmyadmin
```

### 2. Vérifier Utilisateurs

**Cliquer: bddiane_sp → utilisateurs**

**Exécuter cette requête SQL:**
```sql
SELECT * FROM utilisateurs WHERE email = 'test.candidat@gmail.com';
```

**Résultat attendu:**
```
id | email                    | type_utilisateur | mot_de_passe (hashé)
1  | test.candidat@gmail.com  | candidat         | $2a$10$...
```

✅ **Utilisateur existe!**

### 3. Vérifier Candidat

**Cliquer: bddiane_sp → candidats**

**Exécuter:**
```sql
SELECT * FROM candidats WHERE id = 1;
```

**Résultat attendu:**
```
id | nom_complet | telephone    | filiere_specialite | age | domicile
1  | Jean Dupont | 0123456789   | Informatique       | 25  | Dakar
```

✅ **Profil candidat existe!**

### 4. Vérifier Candidatures (LE PLUS IMPORTANT)

**Cliquer: bddiane_sp → candidatures**

**Exécuter:**
```sql
SELECT * FROM candidatures;
```

**Résultat attendu:**
```
id | candidat_id | offre_id | statut    | date_postulation
1  | 1           | 1        | En cours  | 2026-06-15 14:30:00
```

✅ **CANDIDATURE EST EN BDD! 🎉**

### 5. Résumé Complet

**Exécuter:**
```sql
SELECT 
    (SELECT COUNT(*) FROM utilisateurs) as 'Utilisateurs',
    (SELECT COUNT(*) FROM candidats) as 'Candidats',
    (SELECT COUNT(*) FROM offres) as 'Offres',
    (SELECT COUNT(*) FROM candidatures) as 'Candidatures';
```

**Résultat attendu:**
```
Utilisateurs | Candidats | Offres | Candidatures
1            | 1         | 2+     | 1+
```

✅ **TOUT FONCTIONNE!**

---

## 🟢 TESTER AVEC UN 2ème CANDIDAT

### Répéter le test avec différentes données:

**Nouvelle inscription:**
```
Email: test2@gmail.com
Mot de passe: TestPass123
Nom: Marie Dupont
Téléphone: 0987654321
Filière: Gestion
Âge: 28
Domicile: Dakar
Sexe: Féminin
```

**Vérifier en BDD:**
```sql
SELECT COUNT(*) FROM utilisateurs;  -- Doit voir: 2
SELECT COUNT(*) FROM candidats;     -- Doit voir: 2
SELECT COUNT(*) FROM candidatures;  -- Doit voir: 2+
```

✅ **Les compteurs augmentent!**

---

## ❌ DÉPANNAGE - COMMANDES À ESSAYER

### Si Backend ne démarre pas

**Tester la connexion MySQL:**
```powershell
mysql -u root -p
```

(Appuyer ENTRÉE si pas de mot de passe)

**Vous devez voir:**
```
mysql> _
```

**Taper:**
```sql
USE bddiane_sp;
SHOW TABLES;
```

✅ **Si vous voyez les tables, MySQL fonctionne**

### Si Frontend ne se connecte pas

**Ouvrir Chrome F12 (DevTools):**
```
Appuyer F12
```

**Aller à:**
```
Application → Local Storage → http://localhost:3000
```

**Vous devez voir un `token` après connexion**

### Si les données ne vont pas en BDD

**Vérifier les logs backend:**

Dans la fenêtre PowerShell du backend, vous verrez:
```
POST /api/auth/register
POST /api/applications
...
```

Si vous ne voyez pas ces lignes, la requête n'a pas atteint le backend.

### Si les offres ne s'affichent pas

**Exécuter en phpMyAdmin:**
```sql
SELECT COUNT(*) FROM offres;
```

Si le résultat est 0, importer les données:
```sql
INSERT INTO offres (titre, description, entreprise_id, lieu, type_contrat, salaire)
VALUES ('Développeur', 'Description...', 1, 'Dakar', 'CDI', 500000);
```

---

## 🛑 ARRÊTER TOUT

### Arrêter Backend

**Dans PowerShell 1:**
```
Appuyer Ctrl+C
```

**Répondre:**
```
Y
```

Appuyer **ENTRÉE**

### Arrêter Frontend

**Dans PowerShell 2:**
```
Appuyer Ctrl+C
```

**Répondre:**
```
Y
```

Appuyer **ENTRÉE**

### Arrêter WAMP

**Clic droit icône WAMP:**
```
Stop All
```

✅ **Tout est arrêté proprement**

---

## 📊 RÉSUMÉ

| Étape | Commande | Résultat |
|-------|----------|----------|
| Backend | `npm start` | ✅ Serveur sur localhost:3001 |
| Frontend | `flutter run -d chrome` | ✅ Chrome s'ouvre |
| Test 1 | S'inscrire | ✅ Données en BDD |
| Test 2 | Se connecter | ✅ Token sauvegardé |
| Test 3 | Postuler | ✅ Candidature en BDD |

---

**✅ Vous êtes prêt! Commencez par le Backend!** 🚀
