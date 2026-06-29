# Configuration de base de données pour la production

## Variables d'environnement Render
Ajoutez ces variables dans l'onglet Environment de votre service Render :

```env
DB_HOST=
DB_PORT=3306
DB_USER=
DB_PASSWORD=
DB_NAME=bddiane_sp
DB_SSL=true
JWT_SECRET=
FILE_SIGNATURE_SECRET=
CORS_ORIGIN=https://job-research-tl8g.onrender.com
FRONTEND_URL=https://job-research-tl8g.onrender.com
```

## Étapes
1. Créer une base MySQL externe
2. Récupérer l'hôte, l'utilisateur, le mot de passe et le nom de la base
3. Remplir les variables ci-dessus dans Render
4. Redéployer l'application
5. Importer le schéma SQL si nécessaire

## Schéma SQL
Le schéma principal est disponible dans :
- bddiane_sp.sql
- bddiane_sp_dump.sql
