# Render + MySQL externe

## Variables d’environnement à ajouter dans Render

Dans le service Render, ouvrez Settings > Environment and add:

```env
NODE_ENV=production
PORT=3000

DB_HOST=VOTRE_HOST_MYSQL_EXTERNE
DB_PORT=3306
DB_USER=VOTRE_UTILISATEUR_MYSQL
DB_PASSWORD=VOTRE_MOT_DE_PASSE_MYSQL
DB_NAME=bddiane_sp
DB_SSL=false

JWT_SECRET=GENERER_UNE_VALEUR_LONGUE_ET_ALEATOIRE
FILE_SIGNATURE_SECRET=GENERER_UNE_AUTRE_VALEUR_LONGUE_ET_ALEATOIRE
CORS_ORIGIN=https://VOTRE_SERVICE.onrender.com
FRONTEND_URL=https://VOTRE_SERVICE.onrender.com
```

## Import initial du schéma SQL

Avant la première mise en ligne, créez la base et importez le schéma :

```bash
mysql -h VOTRE_HOST_MYSQL_EXTERNE -u VOTRE_UTILISATEUR_MYSQL -p
CREATE DATABASE bddiane_sp;
exit;

mysql -h VOTRE_HOST_MYSQL_EXTERNE -u VOTRE_UTILISATEUR_MYSQL -p bddiane_sp < bddiane_sp.sql
```

## Déploiement

1. Connecter le dépôt GitHub à Render.
2. Créer un service Web avec le Dockerfile du projet.
3. Ajouter les variables ci-dessus.
4. Déployer.

## Vérification

Après déploiement, vérifier :

```bash
https://VOTRE_SERVICE.onrender.com/api/health
```
