# Quick Deployment Reference

## 5-Minute Setup

### 1. Update `render.yaml`
Edit the file with your actual configuration:
```yaml
DB_HOST: your-mysql-host.rds.amazonaws.com
DB_PORT: 3306
DB_USER: your_username
DB_PASSWORD: your_secure_password
DB_NAME: bddiane_sp
CORS_ORIGIN: https://your-app.onrender.com
FRONTEND_URL: https://your-app.onrender.com
JWT_SECRET: $(openssl rand -base64 32)
FILE_SIGNATURE_SECRET: $(openssl rand -base64 32)
```

### 2. Add GitHub Secrets
```
Repo Settings → Secrets → Actions → New Secret
RENDER_API_KEY: <your-token-from-render.com/api-tokens>
RENDER_SERVICE_ID: <from-render-dashboard>
```

### 3. Push & Deploy
```bash
git add render.yaml
git commit -m "Configure production deployment"
git push origin main
```

### 4. Monitor
- GitHub Actions: Check workflow status
- Render Dashboard: Watch deployment progress

### 5. Verify
```bash
curl https://your-app.onrender.com/api/health
# Should return: {"status":"ok"}
```

---

## File Checklist

- [x] `.github/workflows/render-deploy.yml` - GitHub Actions workflow
- [x] `Dockerfile` - Multi-stage build (backend + frontend)
- [x] `render.yaml` - Service configuration for Render
- [x] `frontend/lib/config/app_config.dart` - Web URL auto-detection
- [x] `backend/server.js` - Serves frontend + API
- [x] `frontend/pubspec.yaml` - Flutter dependencies
- [x] `DEPLOYMENT_GUIDE_RENDER.md` - Full documentation
- [x] `DEPLOYMENT_STATUS.md` - Current status & checklist

---

## Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `DB_HOST` | MySQL server | `db.example.com` |
| `DB_PORT` | MySQL port | `3306` |
| `DB_USER` | MySQL username | `admin` |
| `DB_PASSWORD` | MySQL password | `SecurePass123!` |
| `DB_NAME` | Database name | `bddiane_sp` |
| `CORS_ORIGIN` | Frontend URL | `https://app.onrender.com` |
| `FRONTEND_URL` | Frontend URL | `https://app.onrender.com` |
| `JWT_SECRET` | Auth token secret | `<random-32-char>` |
| `FILE_SIGNATURE_SECRET` | File signature secret | `<random-32-char>` |
| `NODE_ENV` | Environment | `production` |
| `PORT` | Server port | `3000` |

---

## Troubleshooting Quick Guide

| Error | Solution |
|-------|----------|
| Build fails in GitHub | Check Dart errors in Actions log |
| Container won't start | Verify DB credentials in environment variables |
| CORS errors | Update `CORS_ORIGIN` to match your deployment URL |
| Database not found | Ensure database exists: `CREATE DATABASE bddiane_sp;` |
| Port binding error | Ensure `PORT` environment variable is set to 3000 |
| Health check fails | Check MySQL connection - verify firewall/security group |

---

## Key Endpoints

Once deployed to `https://your-app.onrender.com`:

- **Frontend:** `https://your-app.onrender.com`
- **Health Check:** `https://your-app.onrender.com/api/health`
- **Login API:** `POST https://your-app.onrender.com/api/auth/login`
- **Register API:** `POST https://your-app.onrender.com/api/auth/register`
- **File Upload:** `POST https://your-app.onrender.com/api/upload`

---

## Automated Workflow

Every time you push to `main`:

```
Push to GitHub
    ↓
GitHub Actions Triggered
    ↓
1. Install Flutter + dependencies
2. Build Flutter web app
3. Trigger Render deployment
    ↓
Render Receives Trigger
    ↓
1. Build Docker image (multi-stage)
2. Deploy to Render container
3. Run health checks
    ↓
Service Live
```

---

## Important Security Notes

1. **Never commit secrets** - Use GitHub Secrets for API keys
2. **Database password** - Use strong password, 16+ characters
3. **JWT_SECRET** - Generate random, keep secret
4. **CORS_ORIGIN** - Always use HTTPS in production
5. **Environment variables** - Keep separate for dev/staging/prod

---

## Support Resources

- **Render Docs:** https://render.com/docs
- **Flutter Docs:** https://flutter.dev/docs
- **GitHub Actions:** https://docs.github.com/actions
- **Express.js:** https://expressjs.com
- **This Project:** See `DEPLOYMENT_GUIDE_RENDER.md` for full details

---

## Status Summary

✅ **Frontend:** Flutter web build configured  
✅ **Backend:** Express.js serving frontend + API  
✅ **Docker:** Multi-stage build ready  
✅ **GitHub Actions:** Workflow deployed  
✅ **Render:** Configuration file created  

⏳ **Pending:** Update render.yaml with actual values + Add GitHub secrets

---

**Ready to Deploy? Follow the 5-Minute Setup above!**
