# 🧪 Test des Routes API - Job research

## Prérequis
- Backend lancé: `npm run dev`
- Base de données importée
- Postman ou curl disponible

---

## 1️⃣ AUTHENTIFICATION

### Inscription (Candidat)
```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "candidat@example.com",
    "password": "password123",
    "userType": "candidat",
    "nom": "Jean Dupont",
    "telephone": "+226 70 00 00 00",
    "filiere": "Informatique",
    "age": 25,
    "domicile": "Ouagadougou"
  }'
```

**Réponse attendue:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "candidat@example.com",
    "userType": "candidat",
    "nom": "Jean Dupont",
    "telephone": "+226 70 00 00 00",
    "filiere": "Informatique"
  }
}
```

### Inscription (Entreprise)
```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "company@example.com",
    "password": "password123",
    "userType": "entreprise",
    "nom": "Tech Solutions",
    "telephone": "+226 25 30 00 00",
    "domaine": "Développement Logiciel",
    "adresse": "Rue 1234, Ouagadougou"
  }'
```

### Connexion
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "candidat@example.com",
    "password": "password123"
  }'
```

**Réponse:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

### Récupérer mon profil
```bash
curl -X GET http://localhost:3001/api/auth/me \
  -H "Authorization: Bearer TOKEN_ICI"
```

### Mettre à jour le profil
```bash
curl -X PUT http://localhost:3001/api/auth/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_ICI" \
  -d '{
    "nom": "Jean Nouveau Nom",
    "telephone": "+226 70 00 00 01"
  }'
```

---

## 2️⃣ OFFRES D'EMPLOI

### Lister toutes les offres (PUBLIC)
```bash
curl -X GET http://localhost:3001/api/offers
```

### Lister toutes les offres avec filtres
```bash
curl -X GET "http://localhost:3001/api/offers?search=developpeur&type=CDI&lieu=Ouagadougou"
```

### Voir mes offres (ENTREPRISE)
```bash
curl -X GET http://localhost:3001/api/offers/my-offers \
  -H "Authorization: Bearer TOKEN_ENTREPRISE"
```

### Créer une offre (ENTREPRISE)
```bash
curl -X POST http://localhost:3001/api/offers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_ENTREPRISE" \
  -d '{
    "titre": "Développeur Full Stack",
    "description": "Nous recherchons un développeur passionné avec 3 ans d'\''expérience...",
    "typeContrat": "CDI",
    "lieu": "Ouagadougou",
    "competences": "JavaScript, React, Node.js, MongoDB",
    "niveau": "Licence",
    "experience": "3 ans",
    "salaire": "800000 - 1200000 FCFA"
  }'
```

### Voir une offre
```bash
curl -X GET http://localhost:3001/api/offers/1
```

### Supprimer une offre (ENTREPRISE)
```bash
curl -X DELETE http://localhost:3001/api/offers/1 \
  -H "Authorization: Bearer TOKEN_ENTREPRISE"
```

---

## 3️⃣ CANDIDATURES

### Postuler à une offre (CANDIDAT)
```bash
curl -X POST http://localhost:3001/api/applications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_CANDIDAT" \
  -d '{
    "offreId": 1
  }'
```

### Voir mes candidatures (CANDIDAT)
```bash
curl -X GET http://localhost:3001/api/applications/my-applications \
  -H "Authorization: Bearer TOKEN_CANDIDAT"
```

### Voir les candidatures reçues (ENTREPRISE)
```bash
curl -X GET http://localhost:3001/api/applications/company-applications \
  -H "Authorization: Bearer TOKEN_ENTREPRISE"
```

### Mettre à jour le statut (ENTREPRISE)
```bash
curl -X PUT http://localhost:3001/api/applications/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_ENTREPRISE" \
  -d '{
    "statut": "Acceptée"
  }'
```

---

## 4️⃣ MESSAGERIE

### Démarrer une conversation
```bash
curl -X POST http://localhost:3001/api/messages/start \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "otherUserId": 2
  }'
```

### Lister mes conversations
```bash
curl -X GET http://localhost:3001/api/messages/conversations \
  -H "Authorization: Bearer TOKEN"
```

### Obtenir les messages d'une conversation
```bash
curl -X GET http://localhost:3001/api/messages/conversations/1 \
  -H "Authorization: Bearer TOKEN"
```

### Envoyer un message
```bash
curl -X POST http://localhost:3001/api/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "conversationId": 1,
    "texte": "Bonjour, je suis intéressé par l'\''offre!"
  }'
```

---

## 5️⃣ NOTIFICATIONS

### Lister mes notifications
```bash
curl -X GET http://localhost:3001/api/notifications \
  -H "Authorization: Bearer TOKEN"
```

### Marquer une notification comme lue
```bash
curl -X PUT http://localhost:3001/api/notifications/1/read \
  -H "Authorization: Bearer TOKEN"
```

### Marquer toutes les notifications comme lues
```bash
curl -X PUT http://localhost:3001/api/notifications/mark/all \
  -H "Authorization: Bearer TOKEN"
```

### Supprimer une notification
```bash
curl -X DELETE http://localhost:3001/api/notifications/1 \
  -H "Authorization: Bearer TOKEN"
```

---

## 6️⃣ UPLOAD DE FICHIERS

### Télécharger un fichier
```bash
curl -X POST http://localhost:3001/api/upload \
  -H "Authorization: Bearer TOKEN" \
  -F "file=@/chemin/vers/fichier.pdf"
```

**Réponse:**
```json
{
  "success": true,
  "url": "http://localhost:3001/uploads/1234567890-fichier.pdf",
  "filename": "1234567890-fichier.pdf"
}
```

---

## 📊 Collection Postman

Vous pouvez importer cette collection dans Postman:

```json
{
  "info": {
    "name": "AfriJob API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Register",
          "request": {
            "method": "POST",
            "header": ["Content-Type: application/json"],
            "url": "http://localhost:3001/api/auth/register"
          }
        }
      ]
    }
  ]
}
```

---

## 🔑 Utiliser le Token

Stockez le token reçu lors de la connexion et incluez-le dans l'en-tête de toutes les requêtes protégées:

```bash
-H "Authorization: Bearer VOTRE_TOKEN"
```

---

## ✅ Résumé des codes HTTP

| Code | Signification |
|------|---------------|
| 200 | OK - Succès |
| 201 | CREATED - Ressource créée |
| 400 | Bad Request - Paramètres invalides |
| 401 | Unauthorized - Token invalide ou manquant |
| 403 | Forbidden - Accès refusé |
| 404 | Not Found - Ressource non trouvée |
| 500 | Server Error - Erreur serveur |

---

## 🐛 Debugging

### Voir les logs du serveur
```bash
# Terminal où le serveur est lancé
npm run dev

# Vous verrez:
# ✅ Connecté à MySQL — base: bddiane_sp
# Serveur actif sur http://0.0.0.0:3001
```

### Tester la connexion MySQL
```bash
mysql -h localhost -u root -p bddiane_sp
# Entrer le mot de passe (vide par défaut)
# SHOW TABLES;
# SELECT * FROM utilisateurs;
```

---

## 💡 Tips

1. **Sauvegarder le token:** Après la connexion, gardez le token pour les requêtes suivantes
2. **Utiliser Postman:** C'est plus facile pour tester les routes
3. **Vérifier les logs:** Consultez le terminal du backend pour les erreurs
4. **Format JSON:** Assurez-vous que toutes les données sont en JSON valide

---

**Bon testing! 🚀**
