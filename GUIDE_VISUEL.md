# 📸 GUIDE VISUEL - ÉTAPE PAR ÉTAPE

## 🟢 ÉTAPE 1: DÉMARRER WAMP

### Étape 1.1: Chercher l'icône WAMP

**Votre écran ressemble à ça:**
```
┌─────────────────────────────────────────┐
│                BUREAU                   │
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
└─────────────────────────────────────────┘

TASKBAR (en bas à droite):
[Windows] [Other Programs] ... [🟢 W] ← WAMP est ici!
                                   ^
                                   Cliquez ici
```

### Étape 1.2: Clic sur WAMP

**Vous verrez ce menu:**
```
┌──────────────────────────┐
│ Start All                │ ← Cliquez ICI (le plus rapide)
│ Stop All                 │
│ ─────────────────        │
│ Apache                   │
│   ├─ Start/Stop          │
│   └─ Restart             │
│ MySQL                    │
│   ├─ Start/Stop          │
│   └─ Restart             │
│ PHP                      │
│ ─────────────────        │
│ Tools                    │
│ Help                     │
└──────────────────────────┘
```

**Cliquer "Start All"**

### Étape 1.3: Attendre que l'icône devienne VERTE

**Avant:**
```
🔴 W (rouge)
↓
Traitement...
↓
🟢 W (vert) ← Maintenant, c'est bon!
```

---

## 🟢 ÉTAPE 2: VÉRIFIER MYSQL

### Étape 2.1: Ouvrir Chrome

**Actions:**
1. Double-clic sur l'icône Chrome (sur le bureau)
2. Attendre que Chrome s'ouvre

**Vous verrez:**
```
┌─────────────────────────────────────────┐
│  Chrome                          [_][□][X]
├─────────────────────────────────────────┤
│ https://www.google.com       [Search Bar]
├─────────────────────────────────────────┤
│                                         │
│           Google Homepage               │
│                                         │
└─────────────────────────────────────────┘
```

### Étape 2.2: Aller à phpMyAdmin

**Actions:**
1. Cliquer dans la barre d'adresse
2. Taper: `localhost/phpmyadmin`
3. Appuyer ENTRÉE

**Vous verrez:**
```
┌─────────────────────────────────────────────────┐
│ http://localhost/phpmyadmin  [Address Bar]      
├─────────────────────────────────────────────────┤
│                                                 │
│            phpMyAdmin Dashboard                 │
│                                                 │
│  Databases:                                     │
│  ├─ information_schema                          │
│  ├─ mysql                                       │
│  ├─ performance_schema                          │
│  ├─ phpmyadmin                                  │
│  ├─ bddiane_sp  ← C'EST BON! ✅                 │
│  └─ (autres...)                                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

✅ **Si vous voyez `bddiane_sp`, continuez!**

❌ **Si vous ne voyez PAS `bddiane_sp`:**
   - Cliquer "Import" en haut
   - Chercher: `c:\Users\SYST\Desktop\mon_application_job\bddiane_sp.sql`
   - Importer

---

## 🟢 ÉTAPE 3: OUVRIR POWERSHELL 1

### Étape 3.1: Clic Droit sur le Bureau

**Actions:**
1. **Clic droit sur le bureau** (sur une zone vide)
2. Voir le menu contextuel

**Vous verrez:**
```
┌────────────────────────────────────┐
│ New                                │
│ Paste                              │
│ Paste shortcut                     │
│ ─────────────────                  │
│ Refresh                            │
│ Personalize                        │
│ New folder                         │
│ ─────────────────                  │
│ Open in Terminal ← Cliquez ICI    │
│ Open in Windows Terminal           │
│ Open with PowerShell               │
│ Open Git Bash                      │
│ ─────────────────                  │
│ Properties                         │
└────────────────────────────────────┘
```

**Cherchez "PowerShell" ou "Terminal"**
Cliquez sur **"Open in Terminal"** ou **"Open with PowerShell"**

### Étape 3.2: Une Fenêtre Noire s'Ouvre

**Vous verrez:**
```
PowerShell ─────────────────────────────────────
│
│ Windows PowerShell
│ Copyright (C) Microsoft Corporation.
│ 
│ PS C:\Users\SYST\Desktop> _
│
│ (Curseur clignotant ici)
│
└─────────────────────────────────────────────
```

---

## 🟢 ÉTAPE 4: NAVIGUER AU BACKEND

### Étape 4.1: Copier la Commande

**Vous voyez cette commande:**
```powershell
cd "c:\Users\SYST\Desktop\mon_application_job\afrijob_backend"
```

**Actions:**
1. **Sélectionner** toute la commande (Ctrl+A sur ce texte)
2. **Copier** (Ctrl+C)
3. **Cliquer** dans la fenêtre PowerShell
4. **Coller** (Ctrl+V)
5. **Appuyer ENTRÉE**

### Étape 4.2: Vous Êtes dans le Bon Répertoire

**Avant:**
```
PS C:\Users\SYST\Desktop> _
```

**Après (ce que vous verrez):**
```
PS C:\Users\SYST\Desktop\mon_application_job\afrijob_backend> _
```

✅ **Vous êtes au bon endroit!**

---

## 🟢 ÉTAPE 5: DÉMARRER LE BACKEND

### Étape 5.1: Taper npm start

**Actions:**
1. **Taper:** `npm start`
2. **Appuyer ENTRÉE**

### Étape 5.2: Attendre le Démarrage

**Vous verrez (pendant 2-3 secondes):**
```
PowerShell ─────────────────────────────────────
│
│ PS C:\Users\...\afrijob_backend> npm start
│
│ > afrijob-backend@1.0.0 start
│ > node server.js
│
│ (Traitement...)
│ (Traitement...)
│
└─────────────────────────────────────────────
```

### Étape 5.3: SUCCESS! ✅

**Quand c'est bon, vous verrez:**
```
PowerShell ─────────────────────────────────────
│
│ ✅ Connecté à MySQL — base: bddiane_sp
│ ✅ Serveur actif sur http://localhost:3001
│
│ PS C:\Users\...\afrijob_backend> _
│
│ (Le curseur est actif)
│
└─────────────────────────────────────────────
```

✅ **SUPER! Le Backend fonctionne!**

**NE PAS FERMER CETTE FENÊTRE!** (Laisser ouvert)

---

## 🟢 ÉTAPE 6: OUVRIR POWERSHELL 2 (Nouvelle Fenêtre)

### Étape 6.1: Clic Droit Bureau ENCORE

**Actions:**
1. **Clic droit sur le bureau** (à nouveau)
2. Cliquer "Open in Terminal" ou "Open with PowerShell"
3. **Une deuxième fenêtre noire s'ouvre**

**Maintenant vous avez 2 fenêtres:**
```
Fenêtre 1 (Backend):          Fenêtre 2 (Frontend):
┌──────────────────┐          ┌──────────────────┐
│ npm start actif  │          │ Vide pour l'instant
│ ✅ Connected     │          │
└──────────────────┘          └──────────────────┘
```

---

## 🟢 ÉTAPE 7: NAVIGUER AU FRONTEND

### Dans la Fenêtre 2, Taper:

```powershell
cd "c:\Users\SYST\Desktop\mon_application_job"
```

**Appuyer ENTRÉE**

**Résultat:**
```
PS C:\Users\SYST\Desktop\mon_application_job> _
```

✅ **Vous êtes dans le bon répertoire!**

---

## 🟢 ÉTAPE 8: LANCER FLUTTER

### Étape 8.1: Taper la Commande

**Taper:**
```powershell
flutter run -d chrome
```

**Appuyer ENTRÉE**

### Étape 8.2: Flutter Compile l'App

**Vous verrez (10-15 secondes):**
```
PowerShell ─────────────────────────────────────
│
│ flutter run -d chrome
│
│ Launching lib/main.dart on Chrome in debug mode...
│ Building flutter app...
│ [Compilation messages...]
│ 
│ Chrome will open shortly...
│
└─────────────────────────────────────────────
```

⏳ **Attendre 10-15 secondes...**

### Étape 8.3: Chrome S'Ouvre Automatiquement!

**Résultat - Chrome avec l'app:**
```
┌─────────────────────────────────────────┐
│ localhost:PORT/      [Address Bar]      │
├─────────────────────────────────────────┤
│                                         │
│           AFRIJOB                       │
│                                         │
│      ┌─────────────────────────┐        │
│      │   S'inscrire            │        │
│      └─────────────────────────┘        │
│                                         │
│      ┌─────────────────────────┐        │
│      │   Se connecter          │        │
│      └─────────────────────────┘        │
│                                         │
└─────────────────────────────────────────┘
```

✅ **L'App est PRÊTE!**

---

## 🟢 ÉTAPE 9: TESTER INSCRIPTION

### Étape 9.1: Cliquer "S'inscrire"

**Dans Chrome, cliquer le bouton "S'inscrire"**

**Vous verrez:**
```
┌─────────────────────────────────────────┐
│ AFRIJOB - Inscription                   │
├─────────────────────────────────────────┤
│                                         │
│  Type de compte:                        │
│  ○ Candidat  ● Entreprise              │
│                                         │
│  Email: [________________]              │
│  Mot de passe: [________________]       │
│  Confirmation: [________________]       │
│                                         │
│  ─── CANDIDAT ───                       │
│  Nom Complet: [________________]        │
│  Téléphone: [________________]          │
│  Filière: [________________]            │
│  Âge: [____]                            │
│  Domicile: [________________]           │
│  Sexe: [Sélectionner]                   │
│                                         │
│  [S'inscrire]                           │
│                                         │
└─────────────────────────────────────────┘
```

### Étape 9.2: Remplir le Formulaire

**À remplir:**

```
Type: Candidat (○ Candidat activé)

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

**Après avoir rempli:**
```
┌─────────────────────────────────────────┐
│ AFRIJOB - Inscription                   │
├─────────────────────────────────────────┤
│                                         │
│  Type: ● Candidat                       │
│  Email: test.candidat@gmail.com ✓       │
│  Password: ••••••••• ✓                  │
│  Nom: Jean Dupont ✓                     │
│  Tel: 0123456789 ✓                      │
│  Filière: Informatique ✓                │
│  Âge: 25 ✓                              │
│  Domicile: Dakar ✓                      │
│  Sexe: Masculin ✓                       │
│                                         │
│  [S'inscrire]                           │
│                                         │
└─────────────────────────────────────────┘
```

### Étape 9.3: Cliquer "S'inscrire"

**Actions:**
1. **Cliquer le bouton "S'inscrire"**
2. **Attendre 2-3 secondes**

**Résultat - SUCCESS:**
```
┌─────────────────────────────────────────┐
│                                         │
│  ✅ Inscription réussie!                │
│                                         │
│  Redirection vers la connexion...       │
│                                         │
└─────────────────────────────────────────┘

(Après 3 secondes)

┌─────────────────────────────────────────┐
│ AFRIJOB - Connexion                     │
├─────────────────────────────────────────┤
│                                         │
│  Email: [________________]              │
│  Mot de passe: [________________]       │
│                                         │
│  [Se connecter]                         │
│                                         │
└─────────────────────────────────────────┘
```

✅ **Inscription réussie!**

---

## 🟢 ÉTAPE 10: VÉRIFIER EN BDDIANE_SP

### Étape 10.1: Ouvrir phpMyAdmin

**Actions:**
1. Dans Chrome, **ouvrir un nouvel onglet** (Ctrl+T)
2. Taper: `localhost/phpmyadmin`
3. Appuyer ENTRÉE

### Étape 10.2: Chercher la Table "utilisateurs"

**Actions:**
1. Cliquer **"bddiane_sp"** (en gauche)
2. Cliquer **"utilisateurs"** (liste des tables)

**Vous verrez:**
```
┌──────────────────────────────────────────────┐
│ phpMyAdmin - bddiane_sp > utilisateurs       │
├──────────────────────────────────────────────┤
│                                              │
│ Table: utilisateurs                          │
│                                              │
│ id | email                   | type_utilisateur
│ ───┼─────────────────────────┼──────────────
│ 1  | test.candidat@gmail.com | candidat
│                                              │
│ ✅ Ligne créée!                              │
│                                              │
└──────────────────────────────────────────────┘
```

✅ **Les données sont en BDD!**

---

## 🟢 ÉTAPE 11: TESTER CONNEXION

### Étape 11.1: Retour à l'App (Chrome)

**Actions:**
1. Cliquer l'onglet où est l'app (onglet Chrome)
2. Vous êtes sur la page "Se connecter"

### Étape 11.2: Remplir et Se Connecter

**Taper:**
```
Email: test.candidat@gmail.com
Mot de passe: TestPass123
```

**Cliquer "Se connecter"**

### Étape 11.3: SUCCESS! ✅

**Vous verrez:**
```
┌─────────────────────────────────────────┐
│ AFRIJOB - Dashboard Candidat            │
├─────────────────────────────────────────┤
│                                         │
│ Bienvenue, Jean Dupont! ✅              │
│                                         │
│ ┌─ Offres ─┬─ Mes Candidatures ─┐      │
│ │           │                    │      │
│ │ [Rechercher...]                │      │
│ │                                │      │
│ │ Offre 1: Développeur Python    │      │
│ │ Offre 2: Designer UX           │      │
│ │ ...                            │      │
│ │                                │      │
│ └────────────────────────────────┘      │
│                                         │
└─────────────────────────────────────────┘
```

✅ **Connexion réussie!**

---

## 🟢 ÉTAPE 12: TESTER CANDIDATURE

### Étape 12.1: Voir les Offres

**Vous êtes sur l'onglet "Offres"**

**Vous verrez:**
```
┌─────────────────────────────────────────┐
│ Offres d'emploi                         │
├─────────────────────────────────────────┤
│                                         │
│ ┌─ Offre 1 ────────────────────────────┐│
│ │ Titre: Développeur Python            ││
│ │ Entreprise: TechStart                 ││
│ │ Lieu: Dakar                           ││
│ │ Salaire: 500000 FCFA                  ││
│ │ [Postuler]                            ││
│ └──────────────────────────────────────┘│
│                                         │
│ ┌─ Offre 2 ────────────────────────────┐│
│ │ Titre: Designer UX                    ││
│ │ Entreprise: Digital Agency            ││
│ │ Lieu: Dakar                           ││
│ │ Salaire: 400000 FCFA                  ││
│ │ [Postuler]                            ││
│ └──────────────────────────────────────┘│
│                                         │
│ ┌─ Offre 3 ────────────────────────────┐│
│ │ Titre: ...                            ││
│ │ ...                                   ││
│ └──────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

✅ **Les offres chargent depuis la BDD!**

### Étape 12.2: Cliquer "Postuler"

**Actions:**
1. Cliquer **"Postuler"** sur une offre

**Popup s'affiche:**
```
┌─────────────────────────────────────┐
│  Confirmation                       │
│                                     │
│  Êtes-vous sûr de postuler à cette  │
│  offre?                             │
│                                     │
│  [Annuler]  [Postuler]              │
│                                     │
└─────────────────────────────────────┘
```

**Cliquer "Postuler" (dans la popup)**

### Étape 12.3: SUCCESS! ✅

**Vous verrez:**
```
┌─────────────────────────────────────┐
│                                     │
│  ✅ Candidature envoyée             │
│     avec succès!                    │
│                                     │
│  Redirection...                     │
│                                     │
└─────────────────────────────────────┘
```

**L'offre s'ajoute à "Mes Candidatures"**

✅ **Candidature créée!**

---

## 🟢 ÉTAPE 13: VÉRIFIER CANDIDATURE EN BDD

### Étape 13.1: phpMyAdmin

**Actions:**
1. Cliquer l'onglet phpMyAdmin
2. Cliquer **"candidatures"** (table)

### Étape 13.2: Voir la Candidature

**Vous verrez:**
```
┌──────────────────────────────────────────────┐
│ phpMyAdmin - bddiane_sp > candidatures       │
├──────────────────────────────────────────────┤
│                                              │
│ id | candidat_id | offre_id | statut | date
│ ───┼─────────────┼──────────┼────────┼─────
│ 1  | 1           | 1        | En     | 2026-
│    |             |          | cours  | 06-15
│                                              │
│ ✅ Ligne créée!                              │
│                                              │
└──────────────────────────────────────────────┘
```

✅ **LA CANDIDATURE EST EN BDD!** 🎉

---

## 🎉 RÉSULTAT FINAL

**Vous avez confirmé que:**

```
✅ Inscription → Données en table "utilisateurs"
✅ Connexion → Token sauvegardé
✅ Affichage offres → Depuis table "offres"  
✅ Candidature → Données en table "candidatures"
✅ Tout marche! 🎉
```

**BRAVO! L'application fonctionne parfaitement!**

---

## 🛑 QUAND VOUS AVEZ FINI

**Arrêter les services:**

1. **Fenêtre PowerShell 1 (Backend):**
   - Appuyer **Ctrl+C**
   - Taper: `Y` et ENTRÉE
   - Fermer la fenêtre

2. **Fenêtre PowerShell 2 (Frontend):**
   - Appuyer **Ctrl+C**
   - Taper: `Y` et ENTRÉE
   - Fermer la fenêtre

3. **WAMP:**
   - Clic droit icône WAMP → Stop All

✅ **Tout est fermé proprement!**

---

**Vous avez réussi! 🎉🚀**
