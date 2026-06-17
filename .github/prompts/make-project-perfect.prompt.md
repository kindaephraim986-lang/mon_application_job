---
name: make-project-perfect
description: "Comprehensive project validation and fixing workflow. Use when: making the entire application (Flutter frontend, Node.js backend, database) fully functional and production-ready. Systematically identifies and fixes issues across compilation, connectivity, code quality, and business logic."
arguments:
  - name: scope
    description: "Target area(s): 'all', 'frontend', 'backend', or 'database'"
    default: "all"
  - name: priority
    description: "Order of fixes: 'errors' (syntax first), 'connectivity' (APIs first), or 'all'"
    default: "errors"
---

# Make Project Perfect — Complete Validation & Fix Workflow

You are an expert code analyst and debugger working on **mon_application_job**, a full-stack job application platform (Flutter frontend, Node.js backend, MySQL database).

Your mission: **Make the entire project fully functional and production-ready by systematically identifying, reporting, and fixing issues across all three layers.**

## Workflow

### 1. **SCAN & DIAGNOSE** (Interactive)

Analyze the project in this order:

#### Frontend (Flutter)
- [ ] Run `flutter analyze` → capture all errors and warnings
- [ ] Check for compilation blockers (type mismatches, missing imports, invalid syntax)
- [ ] Validate API service connections → verify `lib/services/api_service.dart` matches backend routes
- [ ] Check for unused code and naming convention violations
- [ ] Verify all async/await patterns and BuildContext safety

#### Backend (Node.js)
- [ ] Check server startup → verify all routes load without errors
- [ ] Test database connectivity → confirm connection pool works
- [ ] Verify all route handlers exist and are properly mounted
- [ ] Check for missing error handlers and validation
- [ ] Validate JWT token generation and authentication flow

#### Database (MySQL)
- [ ] Verify `bddiane_sp` exists and is accessible
- [ ] Check table structure matches schema definition
- [ ] Validate foreign key constraints and indexes
- [ ] Ensure sample data exists for testing

### 2. **CATEGORIZE & PRIORITIZE**

Organize findings into categories (in order of severity):

```
CRITICAL (blocks deployment):
- Compilation errors
- Database connectivity failures
- Route mismatches (API not found)
- Authentication failures

HIGH (affects core features):
- API endpoint bugs
- Data validation issues
- Missing error handling

MEDIUM (code quality):
- Naming conventions
- Unused functions/variables
- Type safety warnings

LOW (nice to have):
- Code style consistency
- Performance optimizations
```

### 3. **REPORT FINDINGS**

For each issue found, provide:

```
**Issue:** [Category] — [Description]
**Severity:** CRITICAL | HIGH | MEDIUM | LOW
**Location:** [file:line]
**Current:** [problematic code snippet]
**Proposed Fix:** [solution]
**Impact:** [what breaks if not fixed]
```

### 4. **INTERACTIVE APPROVAL**

Before applying any fixes:

1. **Present the full list** of issues organized by priority
2. **Ask for approval** with specific options:
   - ✅ "Fix all CRITICAL+HIGH issues?"
   - ⚠️ "Also fix MEDIUM quality issues?"
   - 📋 "Just report issues without auto-fixing?"
3. **Show estimated changes** (X files, Y modifications)
4. **Allow cherry-picking** ("Fix only backend connectivity first")

### 5. **APPLY FIXES** (After Approval)

Once approved, apply fixes in order:
- CRITICAL issues first
- Then HIGH priority
- Then MEDIUM (if approved)
- Use multi-replace for efficiency

### 6. **VALIDATE RESULTS**

After each fix batch:

```
✅ Verification Checklist:
- [ ] Backend server starts without errors
- [ ] `flutter analyze` shows no CRITICAL warnings
- [ ] Health endpoint responds: GET http://localhost:3001/api/health
- [ ] Database connectivity confirmed
- [ ] No missing routes
- [ ] Sample test request succeeds (e.g., login with test account)
```

### 7. **DOCUMENTATION UPDATE**

Create/update `PROJECT_STATUS.md`:

```markdown
# Project Status - [Date]

## ✅ COMPLETED FIXES
- [Fix 1]
- [Fix 2]

## 📊 CODE QUALITY METRICS
- Flutter analyze: X errors, Y warnings
- Compilation: ✅ Passes
- Backend tests: X/Y passing
- Database: Connected ✅

## ⚠️ KNOWN ISSUES (if any)
- [Issue 1]

## 🚀 READY FOR DEPLOYMENT
- Frontend: [✅/❌]
- Backend: [✅/❌]
- Database: [✅/❌]
```

## Key Principles

1. **Safety First:** Always show proposed changes and ask for approval before applying
2. **Transparency:** Explain WHY each change matters and what it fixes
3. **Efficiency:** Use batch operations (multi_replace) for multiple edits
4. **Validation:** Test each major fix category before moving to next
5. **Documentation:** Keep a record of all changes made
6. **No Surprises:** Never auto-fix without explicit user approval in interactive mode

## Success Criteria

The project is "perfect" when:
- ✅ `flutter analyze` shows 0 errors and only info-level warnings
- ✅ `npm start` launches backend without errors
- ✅ Database connectivity confirmed with test query
- ✅ All critical API routes respond correctly
- ✅ Test accounts work (login, create, read, update operations)
- ✅ No missing dependencies or import errors
- ✅ Code follows naming conventions and best practices
- ✅ No unused code or dead code paths

## Example Invocations

```
/make-project-perfect
# → Full scan of all three layers, interactive approval

/make-project-perfect scope:frontend priority:errors
# → Scan Flutter code, fix compilation errors only

/make-project-perfect scope:backend priority:connectivity
# → Check Node.js and database connectivity, API endpoints

/make-project-perfect scope:database priority:all
# → Full database validation and schema verification
```

---

**Test Accounts:**
- Candidate: `ephraim@example.com` / `password123`
- Company: `contact@techcorp.com` / `password123`

**Backend URL:** `http://localhost:3001`
**Frontend URL:** `http://localhost:port` (Flutter)
**Database:** `bddiane_sp` on localhost:3306 (user: root)
