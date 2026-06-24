# 🔗 API ENDPOINT CONFIGURATION GUIDE

## Current Status

### Development
- Backend: `http://localhost:3001`
- Frontend: `http://localhost:3000` or `flutter run -d chrome`
- API Service: Uses hardcoded `baseUrl`

### Production
- Backend: `https://api.yourdomain.com`
- Frontend: `https://yourdomain.com`
- API Service: Must point to production URL

---

## 📍 WHERE TO UPDATE API ENDPOINTS

### 1. Frontend API Service

**File:** `frontend/lib/services/api_service.dart`

**Current Code:**
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:3001';
  // ...
}
```

**Production Update:**
```dart
class ApiService {
  static const String baseUrl = 'https://api.yourdomain.com';
  // For dynamic configuration (optional):
  // static String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.yourdomain.com');
}
```

### 2. Environment-Based Configuration (Recommended)

**Create: `frontend/lib/config/app_config.dart`**
```dart
class AppConfig {
  static const isDevelopment = false; // Set to true for dev builds
  
  static String get apiBaseUrl {
    if (isDevelopment) {
      return 'http://localhost:3001';
    } else {
      return 'https://api.yourdomain.com';
    }
  }

  static String get frontendUrl {
    if (isDevelopment) {
      return 'http://localhost:3000';
    } else {
      return 'https://yourdomain.com';
    }
  }
}
```

**Update ApiService:**
```dart
import 'package:your_app/config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;
  // ...
}
```

### 3. Build-Time Configuration (Best Practice)

**Using --dart-define flag:**
```bash
# Development build
flutter run --debug \
  --dart-define=API_BASE_URL=http://localhost:3001 \
  --dart-define=ENVIRONMENT=development

# Production web build
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=ENVIRONMENT=production
```

**In Dart code:**
```dart
const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', 
  defaultValue: 'https://api.yourdomain.com');
const String environment = String.fromEnvironment('ENVIRONMENT', 
  defaultValue: 'production');
```

---

## 🔐 CORS Configuration

### Backend `.env`
```
CORS_ORIGIN=https://yourdomain.com
CORS_CREDENTIALS=true
```

### Backend Code: `backend/server.js` or CORS middleware
```javascript
const cors = require('cors');

app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 3600
}));
```

**Important:** CORS_ORIGIN must exactly match your frontend domain (with https://, no trailing slash)

---

## 📋 API ENDPOINTS CHECKLIST

### Authentication Routes
```
POST   /api/auth/register      → No auth required ✓
POST   /api/auth/login         → No auth required ✓
GET    /api/auth/me            → Auth required (Bearer token)
PUT    /api/auth/profile       → Auth required
```

### OCR Routes (Secured)
```
POST   /api/ocr/extract        → Auth required + Magic-byte validation ✓
POST   /api/ocr/verify         → Auth required ✓
```

### Job Offers
```
GET    /api/offers             → No auth required
GET    /api/offers/:id         → No auth required
POST   /api/offers             → Auth required (company only)
```

### Applications
```
GET    /api/applications/my-applications  → Auth required
POST   /api/applications                  → Auth required
PUT    /api/applications/:id             → Auth required
```

### Payments
```
POST   /api/payments/apply     → Auth required ✓
GET    /api/payments/history   → Auth required
```

---

## 🚀 DEPLOYMENT CONFIGURATION

### Option A: Render Deployment

**1. Backend Web Service Environment Variables**
```
BACKEND_URL=https://afrijob-backend.onrender.com
CORS_ORIGIN=https://afrijob-frontend.onrender.com
DB_HOST=mysql.c.your-mysql-host.internal
DB_USER=afrijob_user
DB_PASSWORD=[from generate-secrets.js]
JWT_SECRET=[from generate-secrets.js]
NODE_ENV=production
```

**2. Frontend Static Site Build Command**
```bash
cd frontend && flutter build web --release \
  --dart-define=API_BASE_URL=https://afrijob-backend.onrender.com \
  --dart-define=ENVIRONMENT=production
```

**3. Publish Directory**
```
frontend/build/web
```

### Option B: Vercel Deployment

**1. Environment Variables (Vercel Dashboard)**
```
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
API_BASE_URL=https://api.yourdomain.com
ENVIRONMENT=production
```

**2. Build Command**
```bash
cd frontend && flutter build web --release
```

**3. Output Directory**
```
frontend/build/web
```

### Option C: Firebase Deployment

**1. firebase.json Configuration**
```json
{
  "hosting": {
    "public": "frontend/build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "redirects": [],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

**2. Environment Variables**
```bash
# Set in Cloud Build or deploy command
--env API_BASE_URL=https://api.yourdomain.com
```

---

## ✅ VERIFICATION CHECKLIST

### Before Deployment

```bash
# 1. Verify API endpoint in code
grep -n "baseUrl\|API_BASE_URL" frontend/lib/services/api_service.dart

# 2. Check CORS configuration
grep -n "CORS_ORIGIN" backend/.env

# 3. Verify backend URL matches CORS_ORIGIN
# Example:
# BACKEND_URL=https://api.yourdomain.com
# CORS_ORIGIN=https://yourdomain.com

# 4. Test API connectivity
curl https://api.yourdomain.com/api/auth/me
# Should return: Unauthorized (401) or User info (with token)
```

### After Deployment

```bash
# 1. Test frontend loads
curl https://yourdomain.com | head -20
# Should contain: <!DOCTYPE html>, flutter_bootstrap.js

# 2. Test API from frontend
# Open browser console on https://yourdomain.com
# Try: fetch('https://api.yourdomain.com/api/auth/me')

# 3. Test with token
TOKEN=$(curl -X POST https://api.yourdomain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' | jq -r '.token')

curl https://api.yourdomain.com/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
# Should return: User information
```

---

## 🐛 TROUBLESHOOTING API CONNECTION ISSUES

### Issue: "CORS error in browser console"
```
Error: Access to XMLHttpRequest at 'https://api.yourdomain.com' 
       from origin 'https://yourdomain.com' has been blocked by CORS policy
```

**Solution:**
```bash
# 1. Check CORS_ORIGIN in .env
grep CORS_ORIGIN backend/.env

# 2. Verify exact match (https://, no trailing slash)
CORS_ORIGIN=https://yourdomain.com
# Not: http://yourdomain.com
# Not: https://yourdomain.com/
# Not: https://*.yourdomain.com

# 3. Restart backend after .env change
pm2 restart server
# Or redeploy on Render/Railway
```

### Issue: "API endpoint not found (404)"
```
Error: POST https://api.yourdomain.com/api/ocr/extract 404 Not Found
```

**Solution:**
```bash
# 1. Check backend is running
curl https://api.yourdomain.com/api/auth/me

# 2. Verify API route exists
grep -r "router.post.*extract" backend/routes/

# 3. Check route is mounted in server.js
grep "app.use.*ocr" backend/server.js
```

### Issue: "Network timeout / Connection refused"
```
Error: Failed to fetch https://api.yourdomain.com
```

**Solution:**
```bash
# 1. Verify backend is deployed and running
curl -I https://api.yourdomain.com

# 2. Check API_BASE_URL in frontend config
grep "baseUrl\|API_BASE_URL" frontend/lib/services/api_service.dart

# 3. Check firewall/load balancer allows HTTPS (port 443)
```

---

## 📝 CONFIGURATION SUMMARY

| Environment | Frontend URL | Backend URL | API Endpoint |
|-------------|------------|------------|--------------|
| Local Dev | `http://localhost:3000` | `http://localhost:3001` | `http://localhost:3001` |
| Production | `https://yourdomain.com` | `https://api.yourdomain.com` | `https://api.yourdomain.com` |

**Key Files to Update:**
- ✏️ `frontend/lib/services/api_service.dart` (baseUrl)
- ✏️ `backend/.env` (CORS_ORIGIN, BACKEND_URL)
- ✏️ Deployment platform environment variables

---

**Last Updated:** 2026-06-22
**Status:** Ready for configuration ✅
