---
name: mon-application-job-instructions
applyTo: ["**/*.dart", "**/*.js", "**/migrations/**", "bddiane_sp.sql"]
description: "Project-wide instructions for mon_application_job (AfriJob). Use when working on Flutter frontend, Node.js backend, or database. Provides context about architecture, conventions, and quick commands."
---

# Mon Application Job — Project Instructions

This is a full-stack job application platform with three integrated layers.

## Project Overview

```
Frontend:  Flutter (Dart) → Web/Mobile
Backend:   Node.js + Express + JWT
Database:  MySQL (bddiane_sp)
```

### Directory Structure

- **`frontend/`** — Flutter application (lib/, pubspec.yaml, etc.)
- **`backend/`** — Node.js server (routes/, controllers/, config/)
- **`bddiane_sp.sql`** — Database schema and migrations

## Architecture Conventions

### Frontend (Dart)
- **Services:** `lib/services/api_service.dart` (centralized API calls)
  - All HTTP requests go through `ApiService`
  - JWT tokens managed in `api_service.dart`
  - Base URL: `http://localhost:3001` (dev) or from `config/app_config.dart`

- **Naming:** `camelCase` for functions/methods, `lowerCamelCase` for constants
- **State:** Use `setState()` for UI updates; avoid nested BuildContext calls after async operations
- **Imports:** Organization follows: `dart:`, `package:flutter/`, then custom

### Backend (Node.js)
- **Routes:** Stored in `routes/` folder (auth, offers, applications, messages, notifications, payments)
- **Controllers:** Logic in `controllers/` (validation, transformations)
- **Middleware:** Auth in `middleware/auth.js` (JWT verification)
- **Database:** `config/database.js` (MySQL pool connection)
- **Error Handling:** All routes should handle errors and return JSON `{ success, message, data }`

### Database (MySQL)
- **Tables:** 10 core tables (users, offers, applications, conversations, messages, notifications, payments, subscriptions, etc.)
- **Keys:** Foreign keys enforce referential integrity
- **Collation:** UTF-8 (supports French/Senegalese text)
- **Schema:** Match `bddiane_sp.sql` exactly; migrations in `backend/migrations/`

## Quick Start Commands

### Backend
```bash
cd backend
npm install          # Install dependencies
npm start            # Start server (port 3001)
npm run migrate      # Run migrations
node scripts/run_migrations.js
```

### Frontend
```bash
cd frontend
flutter pub get      # Get dependencies
flutter analyze      # Check for issues
flutter run          # Run (choose device/browser)
```

### Database
```bash
# Import schema (if not already imported)
mysql -u root < bddiane_sp.sql

# Check tables
mysql -u root bddiane_sp -e "SHOW TABLES;"
```

## Key Routes & Endpoints

### Authentication
- `POST /api/auth/login` — Login (returns JWT token)
- `POST /api/auth/register` — Create account
- `GET /api/auth/me` — Get current user (requires token)
- `PUT /api/auth/profile` — Update profile (requires token)

### Offers (Job Postings)
- `GET /api/offers` — List all offers
- `GET /api/offers/:id` — Get offer details
- `POST /api/offers` — Create offer (company only)
- `GET /api/offers/my-offers` — My postings (company only)

### Applications
- `GET /api/applications/my-applications` — My applications (candidate only)
- `POST /api/applications` — Apply to offer
- `PUT /api/applications/:id` — Update application status

### Messages & Notifications
- `GET /api/messages/conversations` — List conversations
- `POST /api/messages` — Send message
- `GET /api/notifications` — Get notifications
- `PUT /api/notifications/:id/read` — Mark as read

## Test Accounts

```
Candidate: ephraim@example.com / password123
Company:   contact@techcorp.com / password123
```

## Common Issues & Solutions

### Frontend
- **Type mismatch (Future<X> vs X):** Use `FutureBuilder` or `await` in async context
- **BuildContext after async:** Guard with `if (!mounted) return;` before using context
- **API 404 errors:** Verify route path in backend matches API call in frontend

### Backend
- **"Route not found":** Check that route is mounted in `server.js` (e.g., `app.use('/api/auth', authRoutes)`)
- **Database connection error:** Verify MySQL is running and `bddiane_sp` exists
- **CORS errors:** Check `CORS_ORIGIN` in `.env` includes frontend URL

### Database
- **Foreign key constraint error:** Ensure parent records exist before inserting
- **UTF-8 issues:** Verify table collation is `utf8mb4_general_ci`

## When to Use `/make-project-perfect`

Use the prompt when:
- You've made several code changes and need a full validation
- The project won't compile/run and you need systematic debugging
- Before committing to check for quality issues
- Before deployment to ensure everything is production-ready

```bash
# Invoke in chat:
/make-project-perfect
/make-project-perfect scope:backend priority:errors
```

## Best Practices

1. **Always test changes locally:** Run backend + frontend before committing
2. **Database-first:** Ensure schema matches before adding frontend/backend code
3. **API contracts:** Define endpoint contracts first, then implement frontend & backend
4. **Error messages:** Always return meaningful JSON responses
5. **Logging:** Use console.log (backend) and Logger/print (Flutter) for debugging
6. **Security:** JWT tokens in Authorization header, never in URL

---

**Last Updated:** 2026-06-17
