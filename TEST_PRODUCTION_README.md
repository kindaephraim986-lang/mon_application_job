# Test-AfriJobProduction.ps1
## Script Expert de Validation de Deploiement

**Votre outil professionnel pour tester l'application AfriJob en production**

---

## QU'EST-CE QUE C'EST?

Un script PowerShell expert qui teste automatiquement tous les aspects de votre application:

✅ Disponibilite du service  
✅ Frontend et assets statiques  
✅ Endpoints API critiques  
✅ Configuration CORS  
✅ Gestion des erreurs  
✅ Performance (latence)  
✅ Certificats SSL/TLS  
✅ Headers du service  

---

## COMMENT L'UTILISER?

### Methode 1: PowerShell Simple
```powershell
powershell.exe -File Test-AfriJobProduction.ps1
```

### Methode 2: PowerShell Avec Bypass
```powershell
powershell.exe -ExecutionPolicy Bypass -File Test-AfriJobProduction.ps1
```

### Methode 3: Avec URL personnalisee
```powershell
powershell.exe -ExecutionPolicy Bypass -File Test-AfriJobProduction.ps1 -BaseUrl "https://votre-url.com"
```

### Methode 4: Mode Verbose
```powershell
powershell.exe -ExecutionPolicy Bypass -File Test-AfriJobProduction.ps1 -Verbose
```

---

## EXEMPLE DE SORTIE

```
================================================================================
[ROCKET] VALIDATION AFRIJOB PRODUCTION DEPLOYMENT
================================================================================
[INFO] Target URL: https://job-research-tl8g.onrender.com
[INFO] Timeout: 30 seconds
[INFO] Test Time: 2026-08-11 12:40:15


================================================================================
PHASE 1: Service Availability
================================================================================
[INFO] Test: Health Check
[INFO]   URL: GET https://job-research-tl8g.onrender.com/api/health
[OK] Health Check (Status: 200, Time: 14874.95ms)


PHASE 2: Frontend and Assets
[OK] Home Page (Status: 200, Time: 342.39ms)


PHASE 3: Critical API Endpoints
[OK] API Health Check (Status: 200, Time: 769.53ms)
...

[RESULTS SUMMARY]
Tests Passed:       12/14
Errors:             2/14
Warnings:           0/14
Total Time:         21.63s

[OK] DEPLOYMENT VALIDATED - PRODUCTION READY
```

---

## INTERPRETATION DES RESULTATS

### Succes Total (0 Erreurs)
```
[OK] DEPLOYMENT VALIDATED - PRODUCTION READY
ALL CRITICAL TESTS PASSED!
```
✅ Votre application est en production!

### Erreurs Detectees
```
[ERROR] DEPLOYMENT FAILED
4 critical error(s) detected
```

**Causes possibles et solutions:**

| Erreur | Cause | Solution |
|--------|-------|----------|
| Health Check fails | Service non accessible | Attendre 2-3 min, puis relancer |
| Database status DOWN | Secrets DB_* non configurés | Configurer dans Render Dashboard |
| API returns 500 | Erreur interne | Verifier les logs Render |
| CORS error | Mauvaise configuration CORS | Verifier CORS_ORIGIN |
| SSL Certificate error | Certificat invalide | Contacter Render support |

---

## LES 8 PHASES DE TEST

### PHASE 1: Service Availability
- Teste que le service Render est actif et accessible
- Enpoint: `/api/health`
- Status attendu: 200 OK

### PHASE 2: Frontend and Assets
- Teste que la page d'accueil se charge
- Endpoint: `/` (racine)
- Verifies: HTML valide

### PHASE 3: Critical API Endpoints
- Teste les endpoints API principaux
- Endpoints:
  - `/api/health` (sante de l'app)
  - `/api/offers` (liste des offres)
  - `/api/auth/login` (authentification)
- Verifies: Status codes corrects

### PHASE 4: CORS Configuration
- Teste les headers CORS
- Enpoint: `/api/health` avec header Origin
- Verifies: Acces depuis la meme origine

### PHASE 5: Error Handling
- Teste les codes d'erreur
- Endpoint: `/api/route-invalid-xyz` (route factice)
- Verifies: Erreur 404

### PHASE 6: Performance Tests
- Teste 5 requetes consecutives
- Mesure les temps de reponse
- Calcule: Min, Average, Max
- Alerte: Si moyenne > 2 secondes

### PHASE 7: Security (SSL/TLS)
- Valide le certificat SSL
- Verifies: Certificat valide et signe
- Alerte: Si certificat problematique

### PHASE 8: Service Information
- Recupere les informations du service
- Affiche: Server, Content-Type, Date
- But: Debug et diagnostic

---

## METRIQUES COLLECTEES

Le script collecte automatiquement:

- **Nombres de tests:** Passes, Errors, Warnings
- **Temps de reponse:** Min, Average, Max
- **Status HTTP:** Codes de reponse
- **Headers:** Server, Content-Type, etc.
- **Statut SSL:** Validite du certificat
- **Statut base de donnees:** OK/DOWN
- **Statut API:** OK/DOWN
- **Duree totale:** Temps d'execution complet

---

## CAS DE USE

### Avant le deploiement
Verifier que tout est ok avant de mettre en production:
```powershell
.\Test-AfriJobProduction.ps1
```

### Apres le deploiement
Valider que tout fonctionne:
```powershell
.\Test-AfriJobProduction.ps1
```

### Monitoring quotidien
Tester chaque jour que l'app est accessible:
```powershell
# Dans une tache planifiee
.\Test-AfriJobProduction.ps1
```

### Troubleshooting
Identifier le probleme exactement:
```powershell
.\Test-AfriJobProduction.ps1 -Verbose
```

### CI/CD Pipeline
Tester automatiquement apres chaque deploiement:
```powershell
.\Test-AfriJobProduction.ps1
if ($LASTEXITCODE -eq 0) { 
    Write-Host "Deployment SUCCESS"
} else { 
    Write-Host "Deployment FAILED"
}
```

---

## PARAMETRES AVANCES

### -BaseUrl
URL cible a tester (defaut: https://job-research-tl8g.onrender.com)

```powershell
.\Test-AfriJobProduction.ps1 -BaseUrl "https://mon-app.com"
```

### -TimeoutSeconds
Timeout pour chaque requete en secondes (defaut: 30)

```powershell
.\Test-AfriJobProduction.ps1 -TimeoutSeconds 60
```

### -Verbose
Affiche des details supplementaires

```powershell
.\Test-AfriJobProduction.ps1 -Verbose
```

---

## CODES DE SORTIE

- **0:** Tous les tests passes - Succes!
- **1:** Au moins une erreur critique - Echec

### En PowerShell:
```powershell
.\Test-AfriJobProduction.ps1
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK"
} else {
    Write-Host "ERREUR"
}
```

---

## PREREQUIS

- Windows PowerShell 5.0 ou superieur
- Acces Internet (pour atteindre Render)
- .NET Framework 4.5+

**Verifier votre version:**
```powershell
$PSVersionTable.PSVersion
```

---

## PROBLEMES COMMUNS

### Erreur: "ExecutionPolicy"
```
File Test-AfriJobProduction.ps1 cannot be loaded because running 
scripts is disabled on this system.
```

**Solution:**
```powershell
powershell.exe -ExecutionPolicy Bypass -File Test-AfriJobProduction.ps1
```

### Erreur: "Service Unavailable (503)"
L'application redémarre ou est temporairement inaccessible.

**Solution:**
- Attendre 2-3 minutes
- Relancer le test
- Verifier Render Dashboard

### Erreur: "Cannot connect" ou "Connection timeout"
Problème de connectivité reseau.

**Solution:**
- Verifier la connexion Internet
- Augmenter le timeout: `-TimeoutSeconds 60`
- Verifier l'URL cible

### Erreur: "SSL Certificate error"
Probleme avec le certificat SSL.

**Solution:**
- Contacter Render support
- Attendre que le certificat se renouvelle
- Verifier l'URL (https://)

---

## EXAMPLES COMPLETS

### Test simple (par defaut)
```powershell
cd C:\Users\SYST\Desktop\Job_Research_main_tmp
powershell.exe -File Test-AfriJobProduction.ps1
```

### Test avec timeout augmente
```powershell
powershell.exe -ExecutionPolicy Bypass -File Test-AfriJobProduction.ps1 -TimeoutSeconds 60
```

### Test URL personnalisee
```powershell
powershell.exe -ExecutionPolicy Bypass -File Test-AfriJobProduction.ps1 `
    -BaseUrl "https://ma-app-production.com"
```

### Test dans un script CI/CD
```powershell
# Test et capture du resultat
$result = & powershell.exe -File Test-AfriJobProduction.ps1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment OK - Notifier l'equipe"
    Send-Email -To "team@example.com" -Subject "Deploy SUCCESS"
} else {
    Write-Host "Deployment FAILED - Enqueter"
    Send-Email -To "devops@example.com" -Subject "Deploy FAILED"
    exit 1
}
```

---

## RESULTATS ATTENDUS PAR PHASE

### Phase 1: Service Availability - ✅ Requis
DOIT passer sinon l'app n'est pas accessible

### Phase 2: Frontend and Assets - ✅ Requis
DOIT passer sinon les utilisateurs voient une erreur

### Phase 3: Critical API Endpoints - ✅ Requis
DOIT passer sinon les fonctionnalites ne marchent pas

### Phase 4: CORS Configuration - ⚠️ Important
A verifier si erreurs CORS dans le frontend

### Phase 5: Error Handling - ⚠️ Important
Verifier que les erreurs 404 sont gerees correctement

### Phase 6: Performance Tests - ℹ️ Info
Mesurer la latence, alerter si > 2s

### Phase 7: Security - ✅ Requis
Certificat SSL doit etre valide

### Phase 8: Service Information - ℹ️ Info
Debug et diagnostic uniquement

---

## TUTORIEL COMPLET

### Etape 1: Configurer les secrets dans Render
1. Aller a https://dashboard.render.com
2. Selectionner "job-research"
3. Onglet "Environment"
4. Ajouter les 5 secrets

### Etape 2: Attendre le deploiement
- Aller a "Deploys"
- Attendre que le statut soit "Live" (vert)
- Cela prend 5-10 minutes

### Etape 3: Tester avec le script
```powershell
powershell.exe -ExecutionPolicy Bypass -File Test-AfriJobProduction.ps1
```

### Etape 4: Interpreter les resultats
- Si "DEPLOYMENT VALIDATED" → Succes!
- Si erreurs → Voir les solutions ci-dessus

### Etape 5: Tester sur mobile
Ouvrir l'URL sur telephone:
```
https://job-research-tl8g.onrender.com/
```

---

## SUPPORT

Si vous avez des problemes:

1. Lire la section "PROBLEMES COMMUNS"
2. Verifier les logs Render Dashboard
3. Relancer le script en mode Verbose
4. Consulter GUIDE_FINALISATION_COMPLETE.md

---

## INFORMATIONS TECHNIQUES

**Version du script:** 2.0 - Production Grade  
**Auteur:** AI Deployment Expert  
**Date de creation:** 2026-08-11  
**Langage:** PowerShell 5.0+  
**Plateforme:** Windows

---

## RESUMÉ

Ce script teste votre application de maniere professionnelle et exhaustive.

**Utilisation simple:**
```powershell
powershell.exe -File Test-AfriJobProduction.ps1
```

**Attendez le resultat:**
- ✅ Succes = Votre app fonctionne!
- ❌ Erreurs = Voir les solutions

**Bonne chance!** 🚀
