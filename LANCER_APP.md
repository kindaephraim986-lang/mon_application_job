# 🚀 Lancer l'Application AfriJob - Mode Web Chrome

## Prérequis
- ✅ MySQL démarré (WAMP/XAMPP)
- ✅ Base de données `bddiane_sp` créée
- ✅ Node.js installé
- ✅ Flutter installé

## Étape 1: Vérifier/Créer la Base de Données

### Via PhpMyAdmin (WAMP)
1. Ouvrir http://localhost/phpmyadmin
2. Créer une nouvelle base de données: `bddiane_sp`
3. Importer le fichier SQL (si disponible)

### Ou via MySQL CLI
```bash
mysql -u root -p
CREATE DATABASE bddiane_sp;
# Importer les tables depuis le fichier SQL
mysql -u root -p bddiane_sp < bddiane_sp.sql
```

## Étape 2: Démarrer le Backend

### Terminal 1 - Backend
```bash
cd c:\Users\SYST\Desktop\mon_application_job\afrijob_backend
npm install        # Déjà fait, mais peut être nécessaire
npm start          # Démarre le serveur sur http://localhost:3001
# ou
npm run dev        # Avec hot-reload (si nodemon est installé)
```

✅ Vous devriez voir:
```
✅ Connecté à MySQL — base: bddiane_sp
✅ Serveur actif sur http://localhost:3001
```

## Étape 3: Démarrer le Frontend

### Terminal 2 - Frontend Web
```bash
cd c:\Users\SYST\Desktop\mon_application_job
flutter run -d chrome
```

✅ Chrome s'ouvrira automatiquement sur http://localhost:XXXXX

## Étape 4: Tester l'Application

### 🧪 Test 1: Inscription Candidat
1. Cliquer "Candidat"
2. Remplir le formulaire:
   - Nom: Jean Dupont
   - Email: jean@example.com
   - Mot de passe: test123
   - Filière: Développement
3. Cliquer "S'inscrire"
4. ✅ Vérifier que le compte est créé dans la BDD
   - Ouvrir http://localhost/phpmyadmin
   - Table `utilisateurs` → doit voir la nouvelle ligne
   - Table `candidats` → doit voir les données du candidat

### 🧪 Test 2: Connexion
1. Cliquer "Connexion"
2. Entrer email et mot de passe
3. ✅ Devrait rediriger vers le tableau de bord candidat

### 🧪 Test 3: Voir les Offres
1. Cliquer sur "Mes Offres" (dans le menu à gauche)
2. ✅ Les offres de la base de données s'affichent
   - Si aucune offre, il faut en créer (voir Test 5)

### 🧪 Test 4: Postuler à une Offre
1. Voir une offre dans "Mes Offres"
2. Cliquer "Postuler"
3. Remplir le formulaire et valider
4. ✅ Vérifier que la candidature est créée en BD
   - Ouvrir http://localhost/phpmyadmin
   - Table `candidatures` → doit voir la nouvelle ligne

### 🧪 Test 5: Inscription Entreprise
1. Aller à l'écran d'inscription
2. Cliquer "Entreprise"
3. Remplir le formulaire:
   - Nom Société: TechCorp
   - Email: info@techcorp.com
   - Mot de passe: test123
   - Domaine: Informatique
4. S'inscrire

### 🧪 Test 6: Créer une Offre (Entreprise)
1. Connexion en tant que l'entreprise
2. Cliquer "Créer Offre" (dans le tableau de bord)
3. Remplir:
   - Titre: Développeur Flutter
   - Description: Nous cherchons...
   - Type contrat: CDI/Stage/CDD
   - Lieu: Ouagadougou
4. Cliquer "Publier"
5. ✅ Vérifier que l'offre apparaît dans la table `offres`

## 🔍 Vérifier les Données en BD

### Voir toutes les inscriptions
```sql
SELECT * FROM utilisateurs;
SELECT * FROM candidats;
SELECT * FROM entreprises;
```

### Voir toutes les candidatures
```sql
SELECT * FROM candidatures;
```

### Voir toutes les offres
```sql
SELECT * FROM offres;
```

## 🐛 Dépannage

### Erreur: "Cannot POST /api/auth/register"
- ❌ Backend ne démarre pas
- ✅ Solution: 
  1. Vérifier que MySQL est actif
  2. Vérifier la variable d'environnement DB_NAME
  3. Relancer `npm start` dans le terminal backend

### Erreur: "ERR_CONNECTION_REFUSED localhost:3001"
- ❌ Backend ne répond pas
- ✅ Solution:
  1. Vérifier que `npm start` a démarré
  2. Vérifier http://localhost:3001/health
  3. Relancer le serveur

### Aucune offre n'apparaît
- ❌ Pas d'offres en BD
- ✅ Solution:
  1. Créer une offre via le dashboard entreprise
  2. Ou insérer directement: 
     ```sql
     INSERT INTO offres (titre, description, type_contrat, lieu, entreprise_id) 
     VALUES ('Dev Flutter', 'Description', 'Stage', 'Ouaga', 1);
     ```

### Les données ne sont pas sauvegardées
- ❌ Erreur réseau/API
- ✅ Debug:
  1. Ouvrir DevTools (F12) → Network
  2. Voir le statut des requêtes POST
  3. Vérifier les réponses d'erreur
  4. Vérifier les logs du backend

## 📊 Vérification Complète

Checklist d'une session test réussie:
- [ ] Backend démarre avec message "✅ Connecté à MySQL"
- [ ] Frontend s'ouvre dans Chrome
- [ ] Inscription candidat crée une ligne dans `utilisateurs` et `candidats`
- [ ] Connexion fonctionne et affiche le dashboard
- [ ] Offres s'affichent depuis la BD
- [ ] Candidature crée une ligne dans `candidatures`
- [ ] Aucune erreur JavaScript dans console (F12)
- [ ] DevTools → Network montre des réponses 200/201 pour POST

## ✅ Modifications Apportées

Toutes les corrections ont été appliquées:
- ✅ Server.js nettoyé et CORS configuré
- ✅ API URLs changées pour localhost web
- ✅ Candidatures envoyées au serveur
- ✅ Offres chargées depuis le serveur
- ✅ Tokens sauvegardés après connexion

**L'application est prête à être testée sur Chrome!**

