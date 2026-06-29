# Configuration WAMP pour Render

## 1) Adresse IP publique à utiliser
Votre adresse IP publique actuelle détectée est : 102.180.83.75

Utilisez cette valeur comme `DB_HOST` dans Render.

## 2) Créer un utilisateur MySQL distant
Ouvrez phpMyAdmin ou la console MySQL et exécutez :

```sql
CREATE USER IF NOT EXISTS 'jobapp'@'%' IDENTIFIED BY 'VotreMotDePasseFort';
GRANT ALL PRIVILEGES ON bddiane_sp.* TO 'jobapp'@'%';
FLUSH PRIVILEGES;
```

## 3) Autoriser MySQL à écouter depuis l'extérieur
Dans le fichier `my.ini` de WAMP, ajoutez ou vérifiez :

```ini
bind-address = 0.0.0.0
```

Puis redémarrez le service MySQL.

## 4) Ouvrir le port 3306
Sur Windows Firewall, autorisez le port TCP 3306.

Si votre machine est derrière une box, configurez un port forwarding vers votre PC sur le port 3306.

## 5) Variables d'environnement Render
Ajoutez dans Render :

```env
DB_HOST=102.180.83.75
DB_PORT=3306
DB_USER=jobapp
DB_PASSWORD=VotreMotDePasseFort
DB_NAME=bddiane_sp
DB_SSL=false
```

## 6) Test de connexion
Depuis un terminal Windows, testez :

```bash
mysql -h 102.180.83.75 -u jobapp -p
```

Si la connexion échoue, le problème vient généralement du firewall, du port forwarding ou de la configuration MySQL.
