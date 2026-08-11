# 🔐 SECRETS RENDER - Configuration Production

**GÉNÉRÉ LE:** 2026-08-11  
**APPLICATION:** AfriJob (job-research)

## ⚠️ ATTENTION SÉCURITÉ

Ces secrets doivent être configurés **UNIQUEMENT** dans le dashboard Render.  
⛔ Ne jamais les committer dans Git ou les partager publiquement.

---

## 🔑 SECRETS À CONFIGURER

### 1. JWT_SECRET
```
vwhH1TRSBTQe0Y2LJygCFS4CwDcDLAaR+dP8gXzc768=
```
**Utilisé pour:** Signature des tokens JWT d'authentification  
**Où le configurer:** Render Dashboard → Secrets Tab

### 2. FILE_SIGNATURE_SECRET
```
H9nb9AOV+hDrtXFJYJ1r1SU8nUIXn3QBrQzNNojXF9A=
```
**Utilisé pour:** Signature des fichiers uploadés  
**Où le configurer:** Render Dashboard → Secrets Tab

### 3. DB_HOST
```
102.180.83.75
```
**Description:** Adresse IP ou hostname du serveur MySQL  
**Où le configurer:** Render Dashboard → Secrets Tab  
**Note:** Remplacer par votre adresse MySQL externe

### 4. DB_USER
```
(À configurer avec votre utilisateur MySQL)
```
**Description:** Utilisateur MySQL  
**Où le configurer:** Render Dashboard → Secrets Tab  
**Exemple:** `job_research_user`

### 5. DB_PASSWORD
```
(À configurer avec votre mot de passe MySQL)
```
**Description:** Mot de passe MySQL  
**Où le configurer:** Render Dashboard → Secrets Tab  
**Sécurité:** Utiliser un mot de passe fort et unique

---

## 📝 VARIABLES D'ENVIRONNEMENT

### Environment Tab (variables publiques)
```
DB_NAME = bddiane_sp
DB_PORT = 3306
DB_SSL = false
DB_CONNECTION_LIMIT = 10
NODE_ENV = production
PORT = 3000
CORS_ORIGIN = https://job-research-tl8g.onrender.com
FRONTEND_URL = https://job-research-tl8g.onrender.com
LOG_LEVEL = debug
UPLOAD_DIR = /tmp/uploads
```

---

## ✅ CHECKLIST DE CONFIGURATION

### Dans Render Dashboard:

1. **Aller à:** Dashboard → job-research → Environment

2. **Configurer les Secrets** (Secret variables):
   - [ ] Copiez **JWT_SECRET** (ci-dessus)
   - [ ] Copiez **FILE_SIGNATURE_SECRET** (ci-dessus)
   - [ ] Entrez **DB_HOST**
   - [ ] Entrez **DB_USER**
   - [ ] Entrez **DB_PASSWORD**

3. **Vérifier les Variables** (Environment variables):
   - [ ] CORS_ORIGIN = https://job-research-tl8g.onrender.com
   - [ ] FRONTEND_URL = https://job-research-tl8g.onrender.com
   - [ ] NODE_ENV = production
   - [ ] PORT = 3000

4. **Sauvegarder** et laisser le déploiement automatique se faire

---

## 🚀 APRÈS LA CONFIGURATION

### 1. Pousser vers GitHub
```bash
git add render.yaml
git commit -m 'chore: finalize render configuration for production'
git push origin main
```

### 2. Attendre le déploiement
- Render va automatiquement redéployer après le push
- Durée: 5-10 minutes
- Suivi: Render Dashboard → Logs

### 3. Tester le déploiement
```bash
# Health check
curl https://job-research-tl8g.onrender.com/api/health

# Ouvrir dans navigateur
https://job-research-tl8g.onrender.com/
```

### 4. Tester depuis téléphone
- Ouvrir: https://job-research-tl8g.onrender.com
- Essayer de s'enregistrer (Register)
- Essayer de se connecter (Login)
- Uploader un CV (test d'upload)

---

## ❌ RÉSOLUTION DES ERREURS

### Erreur: "Cannot connect to database"
- Vérifier que DB_HOST est correct
- Vérifier que le port 3306 est accessible de Render
- Vérifier les credentials DB_USER et DB_PASSWORD

### Erreur: "CORS error"
- Vérifier que CORS_ORIGIN = https://job-research-tl8g.onrender.com
- Attendre 1-2 minutes après la sauvegarde

### Erreur: "Page not found"
- S'assurer que le Dockerfile construit correctement
- Vérifier les logs Render pour les erreurs de build

### Erreur: "Upload failed"
- Vérifier que FILE_SIGNATURE_SECRET est configuré
- S'assurer que /tmp/uploads existe (Render le crée automatiquement)

---

## 📊 MONITORING

Après le déploiement, vérifier régulièrement:

1. **Health Check:** https://job-research-tl8g.onrender.com/api/health
2. **Logs:** Render Dashboard → Logs
3. **Erreurs:** Vérifier les codes d'erreur 429, 500, 503
4. **Performance:** Vérifier le temps de réponse

---

## 🔄 ROTATION DES SECRETS

Pour maintenir la sécurité:
1. Générer de nouveaux secrets tous les 6 mois
2. Mettre à jour dans Render Dashboard
3. Tester le déploiement avant et après

---

**Généré par:** AI Setup Automation  
**Date:** 2026-08-11  
**Status:** ✅ Prêt pour production
