# 🚀 LANCER TON APP - GUIDE RAPIDE

## 1️⃣ Localement (Docker)
```bash
docker-compose up -d
# Accès: http://localhost:3000
```

## 2️⃣ Partager avec tes amis (Render.com - GRATUIT)

1. Va sur https://render.com → Sign up avec GitHub
2. "New Web Service" → Sélectionne ton repo
3. Configure dans `afrijob_backend/`:
   - Build: `npm install`
   - Start: `npm start`
4. Ajoute variables d'env (DB, JWT, etc)
5. Deploy! ✨

**Boom! URL publique en 10 minutes!**

## 3️⃣ Alternative: Railway.app

Le token échoue actuellement. Solution:
```bash
# Créer token Project dans Railway (pas Account)
# Au lieu de Account/Workspace token
```

## Résumé
- ✅ App prête à déployer
- ✅ Docker push tout automatique
- ✅ GitHub Actions activé
- ✅ Juste besoin de déployer sur Render/Railway

**C'est fini! Partage ton URL! 🎉**
