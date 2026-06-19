## 🚀 GUIDE COMPLET DE DÉPLOIEMENT - AfriJob

### 📋 Options de déploiement

Vous avez **3 options** selon votre infrastructure:

1. **Option A:** Déploiement local/VPS (Recommandé pour débuter)
2. **Option B:** Cloud (Heroku, Railway, Render - Backend) + Firebase (Frontend)
3. **Option C:** Docker + Kubernetes (Production scale)

---

## OPTION A: Déploiement sur VPS/Serveur dédié {#option-a}

### ✅ Prérequis

- Un serveur Linux (Ubuntu 20.04+) ou Windows Server
- Node.js 16+ installé
- MySQL 8.0+ installé
- Git installé
- Domain name (optionnel mais recommandé)
- SSL certificate (Let's Encrypt gratuit)

### 📍 Étape 1: Préparer le backend

#### 1.1 Build de production

```bash
# Depuis votre machine locale
cd backend

# Installer les dépendances de production
npm install --production

# Tester que tout compile
npm run dev
# (Vérifier qu'il n'y a pas d'erreurs)
```

#### 1.2 Créer le fichier `.env` de production

```env
# backend/.env.production
NODE_ENV=production
PORT=5000

# Database
DB_HOST=localhost
DB_USER=afrijob_user
DB_PASSWORD=YOUR_SECURE_PASSWORD_HERE
DB_NAME=bddiane_sp

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this

# File signatures
FILE_SIGNATURE_SECRET=your-file-signature-secret-key

# API URLs
FRONTEND_URL=https://yourdomain.com
BACKEND_URL=https://api.yourdomain.com

# Logging
LOG_LEVEL=info
LOG_FILE=/var/log/afrijob/backend.log

# Performance
NODE_ENV=production
```

#### 1.3 Créer un script de démarrage

```bash
# backend/start-production.sh
#!/bin/bash

# Charger les variables d'environnement
export $(cat .env.production | xargs)

# Démarrer le serveur
node server.js
```

### 📍 Étape 2: Préparer le frontend Flutter

#### 2.1 Build web de production

```bash
cd frontend

# Nettoyer les anciens builds
flutter clean

# Générer le build web optimisé
flutter build web --release

# Vérifier que le dossier build/web/ a été créé
ls -la build/web/
```

#### 2.2 Optimiser les assets

```bash
# Après le build
# Les fichiers sont dans: build/web/

# Vérifier la taille
du -sh build/web/

# Accepter la taille ~50-100MB pour une app Flutter web
```

### 📍 Étape 3: Déployer sur le serveur

#### 3.1 Se connecter au serveur

```bash
# Via SSH
ssh user@your-server-ip

# Ou si vous êtes sur Windows, utiliser PuTTY
# ou Windows PowerShell:
ssh -i C:\path\to\key.pem user@your-server-ip
```

#### 3.2 Préparer les dossiers

```bash
# Sur le serveur
sudo mkdir -p /var/www/afrijob/{backend,frontend}
sudo mkdir -p /var/log/afrijob
sudo mkdir -p /var/afrijob/uploads/{profile-photos,cvs,cnib}

# Permissions
sudo chown -R $USER:$USER /var/www/afrijob
sudo chown -R $USER:$USER /var/log/afrijob
sudo chown -R $USER:$USER /var/afrijob
```

#### 3.3 Déployer le backend

```bash
# Depuis votre machine local, créer un archive
cd backend
tar -czf afrijob-backend.tar.gz --exclude=node_modules --exclude=.env .

# Copier vers le serveur
scp afrijob-backend.tar.gz user@your-server-ip:/tmp/

# Sur le serveur
cd /var/www/afrijob/backend
tar -xzf /tmp/afrijob-backend.tar.gz

# Installer dépendances
npm install --production

# Créer le fichier .env.production
nano .env.production
# (Coller le contenu du fichier .env créé plus tôt)
```

#### 3.4 Déployer le frontend

```bash
# Depuis votre machine locale
cd frontend/build/web
tar -czf afrijob-frontend.tar.gz .

# Copier vers le serveur
scp afrijob-frontend.tar.gz user@your-server-ip:/tmp/

# Sur le serveur
cd /var/www/afrijob/frontend
tar -xzf /tmp/afrijob-frontend.tar.gz
```

### 📍 Étape 4: Configurer Nginx (reverse proxy)

#### 4.1 Installer Nginx

```bash
# Sur le serveur
sudo apt update
sudo apt install -y nginx

# Démarrer
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### 4.2 Créer le fichier de configuration

```bash
# Créer un nouveau fichier config
sudo nano /etc/nginx/sites-available/afrijob

# Contenu :
```

```nginx
# Configuration Nginx pour AfriJob

# Backend API
upstream backend {
    server localhost:5000;
}

# Frontend
server {
    listen 80;
    server_name api.yourdomain.com;

    # Rediriger HTTP vers HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    # Proxy vers Node.js
    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Fichiers statiques uploadés
    location /uploads/ {
        alias /var/afrijob/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Logs
    access_log /var/log/nginx/afrijob-backend-access.log;
    error_log /var/log/nginx/afrijob-backend-error.log;
}

# Frontend
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    return 301 https://yourdomain.com$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    root /var/www/afrijob/frontend;
    index index.html index.htm;

    # Cache busting pour les fichiers avec hash
    location ~* \.[\da-f]+\.js$ {
        expires 365d;
        add_header Cache-Control "public, immutable";
    }

    location ~* \.[\da-f]+\.css$ {
        expires 365d;
        add_header Cache-Control "public, immutable";
    }

    # Fallback vers index.html pour SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Logs
    access_log /var/log/nginx/afrijob-frontend-access.log;
    error_log /var/log/nginx/afrijob-frontend-error.log;
}
```

#### 4.3 Activer la configuration

```bash
# Sur le serveur
sudo ln -s /etc/nginx/sites-available/afrijob /etc/nginx/sites-enabled/

# Vérifier la syntaxe
sudo nginx -t

# Redémarrer
sudo systemctl restart nginx
```

### 📍 Étape 5: Configurer SSL (Let's Encrypt)

```bash
# Sur le serveur
sudo apt install -y certbot python3-certbot-nginx

# Créer les certificats
sudo certbot certonly --nginx -d yourdomain.com -d www.yourdomain.com
sudo certbot certonly --nginx -d api.yourdomain.com

# Renouvellement automatique
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

### 📍 Étape 6: Déployer la base de données

#### 6.1 Créer un utilisateur MySQL

```bash
# Sur le serveur
mysql -u root -p

# Dans MySQL:
CREATE DATABASE bddiane_sp;
CREATE USER 'afrijob_user'@'localhost' IDENTIFIED BY 'YOUR_SECURE_PASSWORD';
GRANT ALL PRIVILEGES ON bddiane_sp.* TO 'afrijob_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 6.2 Importer les migrations

```bash
# Copier les fichiers SQL vers le serveur
scp backend/migrations/*.sql user@your-server-ip:/tmp/

# Sur le serveur
mysql -u afrijob_user -p bddiane_sp < /tmp/001_add_candidature_paiements_table.sql
mysql -u afrijob_user -p bddiane_sp < /tmp/002_add_features.sql
```

### 📍 Étape 7: Démarrer le backend

#### 7.1 Avec PM2 (recommandé)

```bash
# Sur le serveur
npm install -g pm2

# Démarrer l'app
cd /var/www/afrijob/backend
pm2 start server.js --name "afrijob-api" --env production

# Sauvegarder la configuration
pm2 save

# Démarrer au boot du serveur
pm2 startup
```

#### 7.2 Ou avec Systemd (alternative)

```bash
# Créer un service systemd
sudo nano /etc/systemd/system/afrijob-backend.service
```

```ini
[Unit]
Description=AfriJob Backend API
After=network.target

[Service]
Type=simple
User=afrijob
WorkingDirectory=/var/www/afrijob/backend
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10
Environment="NODE_ENV=production"
EnvironmentFile=/var/www/afrijob/backend/.env.production

[Install]
WantedBy=multi-user.target
```

```bash
# Démarrer le service
sudo systemctl daemon-reload
sudo systemctl enable afrijob-backend
sudo systemctl start afrijob-backend

# Vérifier le status
sudo systemctl status afrijob-backend
```

---

## OPTION B: Déploiement sur Cloud {#option-b}

### 📍 Backend sur Railway (recommandé pour débuter)

#### 1. Se créer un compte

Aller sur: https://railway.app
Créer un compte avec GitHub

#### 2. Créer un nouveau projet

```bash
# Dans votre terminal local
cd backend

# Installer Railway CLI
npm install -g @railway/cli

# Se connecter
railway login

# Initialiser le projet
railway init

# Connecter le répo GitHub
# (Railway détecte automatiquement l'app Node.js)
```

#### 3. Ajouter la base de données

```bash
# Dans le dashboard Railway
# Cliquer "Add" → "MySQL"
# Railway crée automatiquement les variables d'environnement

# DATABASE_URL sera disponible automatiquement
```

#### 4. Variables d'environnement

Dans le dashboard Railway:
```
NODE_ENV=production
PORT=5000
JWT_SECRET=your-secure-key
FILE_SIGNATURE_SECRET=your-file-signature-secret
FRONTEND_URL=https://yourdomain.com
```

#### 5. Déployer

```bash
# Depuis votre terminal
cd backend
git push origin main

# Railway déploie automatiquement!
# Vérifier les logs dans le dashboard
```

### 📍 Frontend sur Vercel

#### 1. Exporter depuis Flutter vers web

```bash
cd frontend
flutter build web --release
```

#### 2. Créer un fichier `vercel.json`

```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "env": {
    "FLUTTER_WEB_CANVASKIT_URL": "https://www.gstatic.com/flutter-canvaskit/"
  }
}
```

### 📍 Déployer sur Render

Render peut déployer ce projet en une seule application Docker en utilisant le `Dockerfile` à la racine du dépôt.

1. Créez un compte Render: https://render.com
2. Connectez Render à votre repo GitHub et importez `mon_application_job`.
3. Render détectera automatiquement le fichier `render.yaml` à la racine.
4. Ajoutez ces variables d'environnement dans le service Render:

```
NODE_ENV=production
PORT=3000
CORS_ORIGIN=https://your-app.onrender.com
FRONTEND_URL=https://your-app.onrender.com
DB_HOST=your-mysql-host
DB_PORT=3306
DB_USER=your-mysql-user
DB_PASSWORD=your-mysql-password
DB_NAME=bddiane_sp
JWT_SECRET=your-jwt-secret
FILE_SIGNATURE_SECRET=your-file-signature-secret
```

5. Render ne fournit pas de base MySQL directement pour ce dépôt. Vous devez utiliser une base MySQL externe ou un service compatible et mettre à jour `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, et `DB_NAME`.

> Si `DB_HOST` est laissé sur `localhost` ou `127.0.0.1`, l'application Render essaiera de se connecter à une base dans le même conteneur, ce qui provoque l’erreur `ECONNREFUSED`.
6. Déclenchez un deploy. Render va construire le backend et le frontend Flutter ensemble, puis exposer l'application sur le port `3000`.

> Note: Le projet sert désormais le build Flutter web depuis Express via `/app/public`.

#### 3. Déployer sur Vercel

```bash
# Installer Vercel CLI
npm install -g vercel

# Déployer
vercel

# Vérifier que ça fonctionne
vercel --prod
```

---

## OPTION C: Docker + Production {#option-c}

### 📍 Créer les Dockerfiles

#### Backend Dockerfile

```dockerfile
# backend/Dockerfile

FROM node:18-alpine

WORKDIR /app

# Copier package files
COPY package*.json ./

# Installer dépendances
RUN npm ci --only=production

# Copier le code
COPY . .

# Exposer le port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Démarrer
CMD ["node", "server.js"]
```

#### Frontend Dockerfile

```dockerfile
# frontend/Dockerfile

FROM cirrusci/flutter:latest as builder

WORKDIR /app

COPY pubspec*.yaml ./

RUN flutter pub get

COPY . .

RUN flutter build web --release

# Stage 2: Servir avec Nginx
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### 📍 Docker Compose

```yaml
# docker-compose.yml

version: '3.8'

services:
  # Database
  mysql:
    image: mysql:8.0
    container_name: afrijob-mysql
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: bddiane_sp
      MYSQL_USER: afrijob_user
      MYSQL_PASSWORD: afrijob_password
    volumes:
      - mysql_data:/var/lib/mysql
      - ./backend/migrations:/docker-entrypoint-initdb.d
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  # Backend API
  backend:
    build: ./backend
    container_name: afrijob-backend
    depends_on:
      mysql:
        condition: service_healthy
    environment:
      NODE_ENV: production
      DB_HOST: mysql
      DB_USER: afrijob_user
      DB_PASSWORD: afrijob_password
      DB_NAME: bddiane_sp
      JWT_SECRET: your-secret-key
      FILE_SIGNATURE_SECRET: your-file-secret
    ports:
      - "5000:5000"
    volumes:
      - ./backend/uploads:/app/uploads
    restart: unless-stopped

  # Frontend
  frontend:
    build: ./frontend
    container_name: afrijob-frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    environment:
      BACKEND_URL: http://backend:5000
    restart: unless-stopped

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: afrijob-nginx
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - backend
      - frontend
    restart: unless-stopped

volumes:
  mysql_data:
```

### 📍 Déployer avec Docker

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier le status
docker-compose ps

# Voir les logs
docker-compose logs -f backend

# Arrêter
docker-compose down
```

---

## 🧪 Tests post-déploiement

```bash
# 1. Tester le backend
curl -X GET https://api.yourdomain.com/health

# 2. Tester la base de données
curl -X GET https://api.yourdomain.com/api/offers

# 3. Tester le frontend
# Ouvrir dans navigateur: https://yourdomain.com

# 4. Tester login
curl -X POST https://api.yourdomain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password"}'

# 5. Tester uploads
curl -X POST https://api.yourdomain.com/api/profile-photos/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "photo=@/path/to/photo.jpg"
```

---

## 📊 Monitoring & Maintenance

### 📍 Logs

```bash
# Backend (PM2)
pm2 logs afrijob-api

# Backend (Systemd)
sudo journalctl -u afrijob-backend -f

# Nginx
sudo tail -f /var/log/nginx/afrijob-backend-access.log

# MySQL
sudo tail -f /var/log/mysql/error.log
```

### 📍 Backups

```bash
# Script de backup automatique
#!/bin/bash

# Backup database
mysqldump -u afrijob_user -p bddiane_sp > /backups/db-$(date +%Y%m%d-%H%M%S).sql

# Backup uploads
tar -czf /backups/uploads-$(date +%Y%m%d-%H%M%S).tar.gz /var/afrijob/uploads/

# Nettoyer les vieux backups (garder 30 jours)
find /backups -name "*.sql" -o -name "*.tar.gz" -mtime +30 -delete

# Mettre dans crontab
# 0 2 * * * /home/user/backup.sh
```

### 📍 Monitoring

```bash
# Installer Prometheus + Grafana (optionnel)
# Ou utiliser le monitoring intégré du cloud:
# - Railway: Dashboard temps réel
# - Vercel: Analytics
# - Heroku: New Relic integration
```

---

## 🚨 Checklist de déploiement

**Avant déploiement:**
- [ ] Tests locaux réussis (backend + frontend)
- [ ] Variables d'environnement configurées
- [ ] Base de données créée et migrations exécutées
- [ ] Certificats SSL générés
- [ ] Dossiers uploads créés avec bonnes permissions
- [ ] Backups configurés

**Après déploiement:**
- [ ] Frontend chargeable (https://yourdomain.com)
- [ ] API accessible (https://api.yourdomain.com/health)
- [ ] Login fonctionne
- [ ] Uploads fonctionnent
- [ ] Notifications s'affichent
- [ ] Photos persistantes après refresh
- [ ] Monitorer les logs pendant 24h

---

## 🎯 Résumé des 3 options

| Aspect | Option A (VPS) | Option B (Cloud) | Option C (Docker) |
|--------|---|---|---|
| **Coût** | $5-20/mois | Gratuit à $10+/mois | Variable |
| **Facilité** | Moyenne | ⭐⭐⭐ (Plus facile) | Difficile |
| **Scalabilité** | Limitée | ⭐⭐⭐ (Excellente) | Excellente |
| **Contrôle** | ⭐⭐⭐ (Complet) | Limité | Complet |
| **Recommandé pour** | Petite équipe | MVP/Prototype | Production scale |

---

**Recommandation:** Commencer par **Option B (Cloud)** pour rapidité, puis migrer vers **Option A** ou **C** en production.
