# 🔐 Validation du Paiement - Guide d'implémentation Backend

## 📋 Résumé de la solution

Le backend valide les candidatures selon le flux suivant :

```
Candidat non abonné
    ↓
Effectue un paiement 500 FCFA (Frontend)
    ↓
Enregistre le paiement via `POST /api/payments/apply` (Backend)
    ↓
Envoie la candidature `POST /api/applications` (Backend)
    ↓
Backend vérifie : abonnement OU paiement enregistré
    ↓
✅ Candidature acceptée OU ❌ Erreur 402 Payment Required
```

---

## 🛠️ Étapes à suivre

### Étape 1 : Exécuter la migration SQL

Importe la nouvelle table `candidature_paiements` dans la DB :

```sql
-- Exécute le fichier migrations/001_add_candidature_paiements_table.sql
-- Via phpMyAdmin ou MySQL CLI
mysql -u root bddiane_sp < afrijob_backend/migrations/001_add_candidature_paiements_table.sql
```

Ou manuellement dans phpMyAdmin :
1. Ouvre phpMyAdmin → sélectionne `bddiane_sp`
2. Onglet SQL → colle le contenu de `migrations/001_add_candidature_paiements_table.sql`
3. Clique "Exécuter"

### Étape 2 : Tester les nouveaux endpoints

#### a) Enregistrer un paiement (500 FCFA)

```bash
POST /api/payments/apply
Content-Type: application/json
Authorization: Bearer {TOKEN}

{
  "offreId": 1,
  "montant": 500,
  "methode_paiement": "orange_money"
}
```

**Réponse réussie (201)** :
```json
{
  "success": true,
  "message": "Paiement enregistré avec succès",
  "paymentId": 1
}
```

**Erreur - Paiement déjà fait (400)** :
```json
{
  "success": false,
  "message": "Vous avez déjà payé pour cette offre"
}
```

#### b) Vérifier si candidat a payé

```bash
GET /api/payments/apply/1
Authorization: Bearer {TOKEN}
```

**Réponse** :
```json
{
  "paid": true,
  "paymentId": 1
}
```

#### c) Vérifier abonnement actif

```bash
GET /api/payments/subscription
Authorization: Bearer {TOKEN}
```

**Réponse** :
```json
{
  "hasActiveSubscription": true,
  "expiryDate": "2026-07-15T10:30:00.000Z"
}
```

#### d) Postuler à une offre

```bash
POST /api/applications
Content-Type: application/json
Authorization: Bearer {TOKEN}

{
  "offreId": 1
}
```

**Scénarios possibles** :

1️⃣ **Candidat abonné** → ✅ `201 Candidature envoyée`

2️⃣ **Candidat non-abonné + a payé** → ✅ `201 Candidature envoyée`

3️⃣ **Candidat non-abonné + n'a pas payé** → ❌ `402 Paiement requis`

---

## 📊 Flux de données

### Quand un candidat postule (non-abonné) :

**Frontend** :
1. Ouvre la fenêtre de paiement
2. Affiche "500 FCFA - Candidature"
3. Simule le paiement (OTP, code test: 123456)
4. En cas de succès → appelle `POST /api/payments/apply`
5. Puis appelle `POST /api/applications`

**Backend** :
1. Reçoit `POST /api/applications`
2. Vérifie : a-t-il un abonnement actif ?
   - SI OUI → accepte la candidature ✅
   - SI NON → vérifie s'il a payé cette offre
3. Si abonnement OU paiement présent → `201 Accepté`
4. Si rien → `402 Paiement requis`

---

## 🔄 Synchronisation Frontend/Backend

| Événement | Frontend | Backend |
|-----------|----------|---------|
| Paiement effectué | Enregistre localement (SharedPreferences) | Enregistre dans DB (`candidature_paiements`) |
| Postulation | Appelle `/api/applications` | Vérifie paiement |
| Succès | Ajoute candidature à la liste locale | Insère dans `candidatures` |
| Échec paiement | Affiche erreur | Retourne 402 |

---

## 📝 Tables affectées

### Table `candidature_paiements` (nouvelle)
```sql
CREATE TABLE candidature_paiements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  candidat_id INT NOT NULL,
  offre_id INT NOT NULL,
  montant DECIMAL(10,2) DEFAULT 500.00,
  devise VARCHAR(10) DEFAULT 'FCFA',
  methode_paiement VARCHAR(50),
  statut ENUM('réussi','échoué','en_attente'),
  date_paiement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(candidat_id, offre_id)
);
```

### Table `abonnements` (existante)
- Utilisée pour vérifier les abonnements actifs

### Table `candidatures` (existante)
- Modifiée pour exiger la validation du paiement au préalable

---

## 🚀 Tests rapides

### Avec cURL

```bash
# 1. Enregistrer un paiement
curl -X POST http://localhost:3001/api/payments/apply \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"offreId": 1, "montant": 500}'

# 2. Vérifier le paiement
curl -X GET http://localhost:3001/api/payments/apply/1 \
  -H "Authorization: Bearer $TOKEN"

# 3. Postuler avec paiement
curl -X POST http://localhost:3001/api/applications \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"offreId": 1}'
```

### Via Postman

1. Importe les endpoints dans une collection
2. Ajoute le token JWT en header `Authorization: Bearer {token}`
3. Teste chaque endpoint

---

## ⚠️ Cas d'erreur à gérer

| Code | Message | Solution |
|------|---------|----------|
| 400 | Vous avez déjà payé pour cette offre | Candidat ne peut pas payer 2x la même offre |
| 402 | Paiement requis | Candidat doit payer 500 FCFA ou s'abonner |
| 404 | Offre non trouvée | Vérifie l'ID de l'offre |
| 500 | Erreur serveur | Vérifie les logs du backend |

---

## 📄 Fichiers modifiés/créés

✅ `afrijob_backend/routes/payments.js` - Nouveaux endpoints
✅ `afrijob_backend/server.js` - Intégration des routes
✅ `afrijob_backend/routes/applications.js` - Validation du paiement
✅ `afrijob_backend/migrations/001_add_candidature_paiements_table.sql` - Schema DB
✅ `lib/services/api_service.dart` - Nouveaux appels API
✅ `lib/candidate_dashboard.dart` - Intégration paiement/candidature

---

## 💡 Prochaines améliorations

- [ ] Intégrer les vrais paiements (Orange Money, Wave, Moov)
- [ ] Ajouter un webhook pour les confirmations de paiement
- [ ] Implémenter un système de remboursement
- [ ] Dashboard d'historique des paiements
- [ ] Notifications pour paiements échoués
