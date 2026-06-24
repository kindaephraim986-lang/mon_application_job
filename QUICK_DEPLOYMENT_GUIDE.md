# 🚀 QUICK DEPLOYMENT GUIDE

## Deployment Platforms Comparison

| Platform | Backend | Frontend | Cost | Setup Time |
|----------|---------|----------|------|------------|
| **Render** | ✅ Node.js | ✅ Static | $7-20/mo | 5 min |
| **Railway** | ✅ Node.js | ✅ Static | $5-50/mo | 5 min |
| **Heroku** | ✅ Node.js | ✅ Static | $7+/mo | 5 min |
| **Vercel** | ✅ (Functions) | ✅✅ (Best) | Free-$20/mo | 3 min |
| **Firebase** | ⚠️ (Functions) | ✅ | Free-Pay/use | 10 min |
| **AWS** | ✅ (EC2/ECS) | ✅ (S3) | Variable | 15+ min |

---

## Option A: RENDER (Recommended - $7/mo)

### 1. Backend Deployment
```bash
# 1. Create Render account: https://render.com
# 2. Connect GitHub repo (or use git push deploy)
# 3. Create New → Web Service

# In Render dashboard:
- Name: afrijob-backend
- Runtime: Node
- Build Command: npm install
- Start Command: npm start
- Environment variables (add from .env):
  * NODE_ENV = production
  * DB_HOST = your-mysql-host
  * DB_USER = afrijob_user
  * DB_PASSWORD = (from .env)
  * JWT_SECRET = (from generate-secrets.js)
  * CORS_ORIGIN = https://your-frontend-domain
```

### 2. Frontend Deployment
```bash
# 1. Create New → Static Site
# 2. Build Command: cd frontend && flutter build web --release
# 3. Publish Directory: frontend/build/web
# 4. Environment: Ensure API endpoint points to backend URL
```

**Result:** Backend at `https://afrijob-backend.onrender.com`, Frontend at `https://afrijob-frontend.onrender.com`

---

## Option B: RAILWAY (Simple - $5/mo)

### 1. Backend
```bash
# 1. railway link  # Link to your project folder
# 2. railway service add # Select Node.js
# 3. railway up # Deploy
# 4. railway environment # Set env vars from .env
```

### 2. Frontend
```bash
# Build locally
cd frontend && flutter build web --release

# Deploy to Railway static hosting
# Or use Railway's build: Add build.json
```

---

## Option C: VERCEL (Best for Frontend - Free-$20/mo)

### 1. Frontend Deployment
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd frontend
vercel --prod

# Configure environment:
# Settings → Environment Variables
# Add: NEXT_PUBLIC_API_URL=https://your-backend.com
```

### 2. Backend (Optional - use Render for backend)
```bash
# Vercel supports Node.js serverless functions
# Create backend as Vercel Functions if needed
```

---

## Option D: FIREBASE (Integrated - Free tier available)

### 1. Setup
```bash
npm install -g firebase-tools
firebase login
firebase init
```

### 2. Frontend
```bash
cd frontend
flutter build web
firebase deploy --only hosting
```

### 3. Backend
```bash
# Create backend as Cloud Function
firebase deploy --only functions
```

---

## 📋 Pre-Deployment Checklist (All Platforms)

### 1. Code Ready
```bash
cd frontend && flutter analyze        # ✅ No issues found!
cd backend && npm test                 # ✅ Tests passing
```

### 2. Database Ready
```bash
# Ensure MySQL is accessible from deployment platform
# Test connection: mysql -h host -u user -p bddiane_sp
```

### 3. Secrets Configured
```bash
# Generate secrets
node backend/scripts/generate-secrets.js

# Update .env with:
- DB_PASSWORD (secure)
- JWT_SECRET (from script)
- CORS_ORIGIN (your domain)
- API URLs
```

### 4. Build Artifacts Ready
```bash
# Frontend
ls frontend/build/web/index.html        # ✅ Present
ls frontend/build/web/main.dart.js      # ✅ Present

# Backend
npm install --production                 # ✅ Works
npm start                                # ✅ Starts on port 3001
```

---

## 🎯 QUICKEST DEPLOYMENT (Render + Vercel)

### Total Time: ~10 minutes

**Backend → Render:**
```
1. Push code to GitHub
2. Connect Render to GitHub
3. Create Web Service
4. Add environment variables from .env
5. Deploy (5 min)
```

**Frontend → Vercel:**
```
1. vercel --prod (3 min)
2. Add environment variables
3. Done!
```

---

## 🔧 Common Deployment Issues

### Issue: "Cannot find module 'dotenv'"
```bash
# Solution
npm install dotenv
npm install --production
```

### Issue: "CORS error from frontend"
```bash
# Check .env
CORS_ORIGIN=https://your-frontend-domain.com
# Not http://, not localhost, exact match
```

### Issue: "Database connection refused"
```bash
# Check:
1. MySQL server running
2. DB_HOST accessible from deployment platform
3. DB_USER and DB_PASSWORD correct
4. Firewall allows port 3306 from deployment server
```

### Issue: "Flutter build fails on deployment"
```bash
# Solution: Pre-build locally, upload build/web/
# Or ensure Flutter SDK available on deployment platform
```

---

## 📊 Deployment Verification

### Backend Health Check
```bash
curl https://api.yourdomain.com/api/auth/me
# Should return: Unauthorized or success (with token)
```

### Frontend Check
```bash
curl https://yourdomain.com
# Should return HTML content
```

### OCR Endpoint Test
```bash
curl -X POST https://api.yourdomain.com/api/ocr/verify \
  -H "Authorization: Bearer YOUR_TEST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userData":{"nom":"TEST"},"ocrData":{"nom":"TEST"}}'
# Should return: {"success":true}
```

---

## 📝 After Deployment

### 1. Monitor Logs
- Render: Dashboard → Logs
- Vercel: Dashboard → Function Logs
- Firebase: Cloud Console → Logs

### 2. Setup Monitoring
```bash
# Email alerts on errors
# Database monitoring
# CDN performance
```

### 3. Backup Database
```bash
# Daily backup schedule
# Test restoration procedure
```

### 4. Domain & SSL
```bash
# Configure custom domain
# SSL certificates (auto-provisioned on most platforms)
# Update CORS_ORIGIN if using custom domain
```

---

## 🎉 Deployment Complete!

Your application is now live at:
- **Frontend:** https://yourdomain.com
- **Backend API:** https://api.yourdomain.com

**Next Steps:**
1. Test all features end-to-end
2. Share with users
3. Monitor for issues
4. Iterate and improve

---

**Last Updated:** 2026-06-22
**Status:** Ready for deployment ✅
