# 🚀 DÉMARRAGE RAPIDE - 5 MINUTES

## Étape 1: WAMP - Démarrer MySQL
```
1. Clic icône WAMP → MySQL → Start
2. Attendre que l'icône devienne VERTE
3. Ouvrir http://localhost/phpmyadmin
4. Vous devez voir la page phpMyAdmin
```

## Étape 2: Backend - Démarrer le serveur

**OUVRIR PowerShell 1:**
```powershell
cd c:\Users\SYST\Desktop\mon_application_job\afrijob_backend
npm start
```

**SUCCÈS = Vous voyez:**
```
✅ Connecté à MySQL — base: bddiane_sp
✅ Serveur actif sur http://localhost:3001
```

## Étape 3: Frontend - Démarrer l'app

**OUVRIR PowerShell 2:**
```powershell
cd c:\Users\SYST\Desktop\mon_application_job
flutter run -d chrome
```

**SUCCÈS = Chrome s'ouvre avec l'app**

---

## 🧪 Test Rapide #1: Inscription

1. Cliquer "S'inscrire"
2. Email: `test@gmail.com`
3. Password: `Test123`
4. Nom: `Test User`
5. Cliquer "S'inscrire"

**Vérifier en BDD:**
- Ouvrir: http://localhost/phpmyadmin
- Base: `bddiane_sp`
- Table: `utilisateurs`
- Chercher: `test@gmail.com` → DOIT VOIR LA LIGNE ✅

---

## 🧪 Test Rapide #2: Connexion

1. Cliquer "Se connecter"
2. Email: `test@gmail.com`
3. Password: `Test123`
4. Cliquer "Connexion"

**Vérifier:**
- Chrome F12 → Application → Local Storage
- Doit voir `token` sauvegardé ✅

---

## 🧪 Test Rapide #3: Candidature

1. Aller à "Offres"
2. Sélectionner une offre
3. Cliquer "Postuler"

**Vérifier en BDD:**
- Table: `candidatures`
- Chercher votre user_id → DOIT VOIR LA LIGNE ✅

---

## ❌ Si ça ne marche pas

### Backend n'arrive pas à se connecter
```
❌ "Erreur connexion MySQL"
→ Vérifier MySQL WAMP est verte
→ Vérifier bddiane_sp existe en phpMyAdmin
→ Relancer backend
```

### Frontend ne se connecte pas au backend
```
❌ "Cannot GET /api/..."
→ Vérifier backend tourne sur localhost:3001
→ Chrome F12 → Network tab → voir erreur
→ Vérifier firewall ne bloque pas port 3001
```

### Les données ne vont pas en BDD
```
❌ Table bddiane_sp vide après inscription
→ Vérifier logs backend: "INSERT INTO..." visible?
→ Vérifier Chrome F12 → Network → réponse HTTP 200/201?
→ Vérifier console backend pour erreurs MySQL
```

---

## ✅ Quand tout fonctionne

**Vous verrez:**
- ✅ Données dans utilisateurs après inscription
- ✅ Données dans candidats/entreprises après profil complet
- ✅ Données dans offres quand l'app charge
- ✅ Données dans candidatures quand vous postulez
- ✅ Fichiers dans `afrijob_backend/uploads/` pour photos
- ✅ URLs dans colonnes `*_url` des tables

**Tout est SAUVEGARDÉ dans bddiane_sp!** 🎉

---

## 🛑 Terminal Ctrl+C pour arrêter

```
Backend: Ctrl+C dans PowerShell 1
Frontend: Ctrl+C dans PowerShell 2 ou fermer Chrome
```

Prêt? Commencez par Étape 1! 🚀
