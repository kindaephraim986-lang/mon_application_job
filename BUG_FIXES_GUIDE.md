# 🔧 GUIDE DE DÉMARRAGE - Corrections de Bugs

## ✅ Bugs Corrigés

### Frontend (Flutter/Dart)

1. **❌ auth_service.dart** → ✅ **CONSOLIDÉ dans ApiService**
   - Problème: URL hardcodée, duplication de code
   - Solution: Le service est maintenant un lien vers ApiService
   - Migration: Utilisez `ApiService.login()` au lieu de `AuthService.loginUser()`

2. **❌ subscription_service.dart** → ✅ **CONNECTÉ À LA BASE DE DONNÉES**
   - Problème: Utilisait SharedPreferences au lieu de la BDD
   - Solution: Communique maintenant avec `ApiService` qui accède à `bddiane_sp`
   - Tous les abonnements sont stockés dans `table abonnements`

3. **❌ chat_service.dart** → ✅ **CONNECTÉ À LA BASE DE DONNÉES**
   - Problème: Stockait les messages en mémoire (perdu au redémarrage)
   - Solution: Utilise maintenant `ApiService` pour les conversations/messages
   - Les données sont stockées dans `table messages` et `table conversations`

4. **❌ candidature_service.dart** → ✅ **CONNECTÉ À LA BASE DE DONNÉES**
   - Problème: Stockait les candidatures en mémoire
   - Solution: Utilise `ApiService` pour récupérer les candidatures depuis `table candidatures`
   - Les candidatures sont persistantes dans la BDD

5. **❌ notification_service.dart** → ✅ **CONNECTÉ À LA BASE DE DONNÉES**
   - Problème: Notifications seulement en mémoire
   - Solution: Récupère les notifications depuis `table notifications` via `ApiService`

### Backend (Node.js)

6. **❌ messages.js** → ✅ **CORRIGÉ BUG COLONNE**
   - Problème: Référençait `expedition_id` au lieu de `expediteur_id`
   - Solution: Colonne corrigée dans la requête SELECT

7. ✅ **authController.js** - Correctement configuré
   - Les fonctions login/register sont bien structurées
   - Les réponses incluent les tokens JWT

### Configuration

8. **❌ .env** → ✅ **WAMPSERVER CONFIGURÉ**
   - Ajout de configurations locales pour WampServer
   - Ports: 3001 (Node.js backend), 3306 (MySQL)
   - Base de données: `bddiane_sp`

---

## 🚀 DÉMARRAGE

### 1. Démarrer WampServer

1. Ouvrez WampServer (icône en bas à droite)
2. Vérifiez que les services MySQL et Apache sont ✅ **Verts**
3. L'URL par défaut: `http://localhost/phpmyadmin`

### 2. Importer la base de données

```bash
# Option 1: Via phpMyAdmin
1. Ouvrez http://localhost/phpmyadmin
2. Créez une nouvelle base: "bddiane_sp"
3. Importez le fichier: bddiane_sp.sql
4. Cliquez sur "Importer"

# Option 2: Via ligne de commande MySQL
mysql -u root -p < bddiane_sp.sql
```

### 3. Démarrer le backend Node.js

```bash
cd afrijob_backend
npm install
node server.js
```

Vous devriez voir:
```
✅ Connecté à MySQL — base: bddiane_sp
Server running on port 3001
```

### 4. Configurer le frontend Flutter

L'URL est automatiquement configurée dans `lib/config/app_config.dart`:
- **Android Emulator**: `http://10.0.2.2:3001/api`
- **Web**: `http://192.168.11.123:3001/api`
- **iOS/Mac/Windows**: `http://localhost:3001/api`

### 5. Lancer l'application Flutter

```bash
flutter run
```

---

## 🧪 TEST DE CONNEXION

### 1. Tester la base de données

```bash
# Vérifier que MySQL fonctionne
mysql -u root -p -e "SELECT * FROM bddiane_sp.utilisateurs LIMIT 1;"

# Vérifier les tables critiques
mysql -u root -p bddiane_sp -e "SHOW TABLES;"
```

### 2. Tester l'API

```bash
# Test de ping
curl http://localhost:3001/api/offers

# Test d'inscription
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "test123",
    "userType": "candidat",
    "nom": "Jean Test"
  }'
```

### 3. Vérifier les données stockées

Après chaque action dans l'app, vérifiez dans phpMyAdmin:
- **Inscriptions** → `utilisateurs`, `candidats`, `entreprises`
- **Candidatures** → `candidatures`, `candidature_paiements`
- **Messages** → `messages`, `conversations`
- **Notifications** → `notifications`
- **Abonnements** → `abonnements`

---

## 📊 STRUCTURE DE LA BASE DE DONNÉES

```
bddiane_sp
├── utilisateurs (id, email, mot_de_passe, type_utilisateur)
├── candidats (id, nom_complet, telephone, filiere_specialite, age, sexe, ...)
├── entreprises (id, nom_societe, domaine_activite, telephone, ...)
├── offres (id, entreprise_id, titre, description, lieu, ...)
├── candidatures (id, candidat_id, offre_id, statut, date_postulation)
├── candidature_paiements (id, candidat_id, offre_id, montant, methode_paiement, ...)
├── abonnements (id, utilisateur_id, type_abonnement, date_fin, ...)
├── messages (id, conversation_id, expediteur_id, texte, date_envoi)
├── conversations (id, candidat_id, entreprise_id, dernier_message_id, ...)
├── notifications (id, utilisateur_id, message, est_lu, date_notification)
└── paiements (id, utilisateur_id, montant, devise, raison, statut, ...)
```

---

## ⚠️ POINTS IMPORTANTS

1. **Tous les services communiquent maintenant avec la base de données**
   - Plus d'utilisations de SharedPreferences pour les données critiques
   - Les données persistent correctement

2. **Les tokens JWT**
   - Stockés dans SharedPreferences (c'est normal pour le client)
   - Vérifiés par le backend avant chaque action protégée

3. **Les paiements**
   - Montant fixe: 500 FCFA par candidature unitaire
   - Ou abonnement mensuel pour candidats/entreprises
   - Enregistrés dans `candidature_paiements` et `paiements`

4. **Logs API**
   - Activés par défaut dans `AppConfig.logApiRequests = true`
   - Vérifiez la console pour déboguer les requêtes

---

## 🐛 TROUBLESHOOTING

### Erreur: "Impossible de connexion à MySQL"
```
❌ Erreur connexion MySQL: connect ECONNREFUSED 127.0.0.1:3306
```
**Solution**: Vérifiez que WampServer MySQL est démarré (cliquez sur "Start All Services")

### Erreur: "Base de données non trouvée"
```
❌ Error: ER_BAD_DB_ERROR
```
**Solution**: Importez le fichier `bddiane_sp.sql` dans phpMyAdmin

### Erreur: "Token invalide"
```
❌ message: 'Token invalide ou expiré'
```
**Solution**: Reconnectez-vous, le token JWT a expiré (30 jours)

---

## 📞 SUPPORT

Pour plus d'informations, consultez:
- `README.md` - Documentation générale
- `SETUP_GUIDE.md` - Guide de configuration
- `.env` - Variables d'environnement
- `bddiane_sp.sql` - Structure de la BDD
