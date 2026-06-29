# 🚀 PRODUCTION DEPLOYMENT - QUICK START (Windows)
# 
# This script provides a quick reference for deploying to production
# Save as: DEPLOY_NOW.ps1
# Run: .\DEPLOY_NOW.ps1 bloque c

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗"
Write-Host "║         🚀 PRODUCTION DEPLOYMENT - QUICK START                ║"
Write-Host "║              Status: READY FOR DEPLOYMENT ✅                   ║"
Write-Host "╚════════════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Host "📋 STEP 1: GENERATE PRODUCTION SECRETS" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Run:"
Write-Host "  cd backend" -ForegroundColor Cyan
Write-Host "  node scripts/generate-secrets.js" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Copy the output to .env file"
Write-Host ""

Write-Host "📋 STEP 2: UPDATE ENVIRONMENT CONFIGURATION" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Edit .env file:"
Write-Host "  DB_PASSWORD=<secure_password>" -ForegroundColor Cyan
Write-Host "  JWT_SECRET=<from_generate-secrets.js>" -ForegroundColor Cyan
Write-Host "  CORS_ORIGIN=https://yourdomain.com" -ForegroundColor Cyan
Write-Host "  BACKEND_URL=https://api.yourdomain.com" -ForegroundColor Cyan
Write-Host "  FRONTEND_URL=https://yourdomain.com" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 STEP 3: UPDATE API ENDPOINT" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Edit: frontend/lib/services/api_service.dart"
Write-Host ""
Write-Host "  OLD: static const String baseUrl = 'http://localhost:3001';" -ForegroundColor Red
Write-Host "  NEW: static const String baseUrl = 'https://api.yourdomain.com';" -ForegroundColor Yellow
Write-Host ""

Write-Host "📋 STEP 4: CHOOSE YOUR DEPLOYMENT PLATFORM" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

Write-Host "⭐ RECOMMENDED: RENDER ($7/mo)" -ForegroundColor Yellow
Write-Host "  1. Go to https://render.com" -ForegroundColor Cyan
Write-Host "  2. Connect GitHub or upload files" -ForegroundColor Cyan
Write-Host "  3. Create Web Service for backend" -ForegroundColor Cyan
Write-Host "  4. Create Static Site for frontend" -ForegroundColor Cyan
Write-Host "  5. Add environment variables from .env" -ForegroundColor Cyan
Write-Host "  ⏱️  Time: ~5 minutes"
Write-Host ""

Write-Host "ALTERNATIVE: VERCEL (Frontend) + RENDER (Backend)" -ForegroundColor Cyan
Write-Host "  Frontend:"
Write-Host "    vercel --prod" -ForegroundColor Cyan
Write-Host "  Backend: (use Render)"
Write-Host "  ⏱️  Time: ~3 minutes frontend + 5 minutes backend"
Write-Host ""

Write-Host "ALTERNATIVE: FIREBASE" -ForegroundColor Cyan
Write-Host "  firebase deploy --only hosting,functions" -ForegroundColor Cyan
Write-Host "  ⏱️  Time: ~10 minutes"
Write-Host ""

Write-Host "📋 STEP 5: VERIFY DEPLOYMENT" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Test backend:"
Write-Host "  curl https://api.yourdomain.com/api/auth/me" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test frontend:"
Write-Host "  curl https://yourdomain.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test OCR endpoint:"
Write-Host "  curl -X POST https://api.yourdomain.com/api/ocr/verify `" -ForegroundColor Cyan
Write-Host "    -H 'Authorization: Bearer YOUR_TOKEN' `" -ForegroundColor Cyan
Write-Host "    -H 'Content-Type: application/json' `" -ForegroundColor Cyan
Write-Host "    -d '{`"userData`":{`"nom`":`"TEST`"},`"ocrData`":{`"nom`":`"TEST`"}}'" -ForegroundColor Cyan
Write-Host ""

Write-Host "╔════════════════════════════════════════════════════════════════╗"
Write-Host "║  📚 For detailed information, see:                            ║"
Write-Host "║     - DEPLOYMENT_CHECKLIST_FINAL.md                          ║"
Write-Host "║     - QUICK_DEPLOYMENT_GUIDE.md                              ║"
Write-Host "║     - API_ENDPOINT_CONFIGURATION.md                          ║"
Write-Host "║     - DEPLOYMENT_SESSION_COMPLETE.md                         ║"
Write-Host "╚════════════════════════════════════════════════════════════════╝"
Write-Host ""
Write-Host "✅ Ready to deploy! Follow the steps above." -ForegroundColor Green
Write-Host ""

# Optional: Open documentation
Write-Host ""
Write-Host "Would you like to open the deployment guides? (y/n)" -ForegroundColor Cyan
$response = Read-Host

if ($response -eq 'y' -or $response -eq 'Y') {
    # Open main deployment guide
    Invoke-Item "DEPLOYMENT_CHECKLIST_FINAL.md"
}
