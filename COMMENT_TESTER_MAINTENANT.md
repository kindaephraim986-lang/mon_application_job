# 🧪 COMMENT TESTER MAINTENANT

## 📋 RÉSUMÉ DES CORRECTIONS FAITES
✅ CORS du Backend corrigé
✅ api_service.dart amélioré
✅ Gestion d'erreur meilleure

---

## 🎯 ÉTAPES POUR TESTER (10 minutes)

### **ÉTAPE 1: Redémarrer le Backend (2 min)**

**Dans PowerShell 1:**

```powershell
# Arrêter si en cours
Ctrl+C

# Redémarrer
npm start
```

**Attendre 3 secondes**

**Vous DEVEZ voir:**
```
✅ Base de données configurée
✅ Connecté à MySQL — base: bddiane_sp
✅ Serveur actif sur http://localhost:3001
```

✅ **Si vous voyez ces 3 lignes = Backend OK!**

---

### **ÉTAPE 2: Redémarrer le Frontend (3 min)**

**Dans PowerShell 2:**

```powershell
# Arrêter si en cours
Ctrl+C

# Nettoyer le cache
flutter clean

# Relancer
flutter run -d chrome
```

**Attendre 15-20 secondes**

**Chrome s'ouvre automatiquement**

✅ **Si Chrome ouvre avec l'app = Frontend OK!**

---

### **ÉTAPE 3: Tester l'Inscription (3 min)**

**Dans Chrome:**

1. **Cliquer "S'inscrire"**

2. **Sélectionner "Candidat"**

3. **Remplir le formulaire:**

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

4. **Cliquer "S'inscrire"**

5. **Attendre 3 secondes**

**Résultat attendu:**
```
✅ Inscription réussie!
Redirection vers connexion...
```

---

### **ÉTAPE 4: Vérifier en BDD (2 min)**

**Ouvrir phpMyAdmin:**

```
http://localhost/phpmyadmin
```

**Cliquer: bddiane_sp → utilisateurs**

**Chercher l'email: `test.candidat@gmail.com`**

**Vous devez voir:**
```
id | email                    | type_utilisateur | mot_de_passe
1  | test.candidat@gmail.com  | candidat         | $2a$10$...
```

✅ **DONNÉES EN BDD! SUCCESS!**

---

## ❌ SI ÇA NE MARCHE TOUJOURS PAS

### **Vérification 1: Vérifier le message de Backend**

**Regardez PowerShell 1 quand vous cliquez "S'inscrire"**

**Vous DEVEZ voir:**
```
POST /api/auth/register
```

❌ **Si vous ne voyez pas:** Le frontend ne contacte toujours pas le backend
- Vérifier Chrome F12 → Console
- Chercher des erreurs en rouge

---

### **Vérification 2: Vérifier Chrome Console**

**Actions:**

1. **Appuyer F12** (ouvrir DevTools)
2. **Cliquer onglet "Console"**
3. **Essayer l'inscription**
4. **Regarder les messages**

**Vous devez voir:**
- ✅ Succès: Pas de message d'erreur
- ❌ Erreur: Message d'erreur détaillé

**Si erreur, copiez-la et envoyez-moi!**

---

### **Vérification 3: Tester la connexion Backend directement**

**Dans PowerShell 3 (nouveau):**

```powershell
curl -X POST http://localhost:3001/api/auth/register `
  -Header "Content-Type: application/json" `
  -Body '{"email":"test@test.com","password":"Test123","userType":"candidat"}'
```

**Si le Backend répond, vous verrez le JSON de réponse**

---

## ✅ RÉSUMÉ - À FAIRE MAINTENANT

```
1. PowerShell 1: Ctrl+C puis npm start
2. PowerShell 2: Ctrl+C puis flutter clean puis flutter run -d chrome
3. Chrome: S'inscrire
4. phpMyAdmin: Vérifier que l'utilisateur existe
```

**Durée: 10 minutes**

---

## 📸 SI ERREUR

**Envoyez-moi:**
1. Screenshot PowerShell 1 (Backend logs)
2. Screenshot Chrome F12 Console (Erreurs)
3. Screenshot de l'erreur exacte

**Ça devrait marcher maintenant! 💪**
