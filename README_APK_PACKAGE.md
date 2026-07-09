**Génération et packaging APK debug + dump MySQL**

But: produire un ZIP prêt à envoyer par WhatsApp contenant l'APK debug et un dump SQL de la base `bddiane_sp`.

1) Builder l'APK automatiquement via GitHub Actions
   - Ouvre l'onglet `Actions` sur GitHub et lance le workflow "Build Flutter Android Debug APK" (workflow_dispatch).
   - Lorsque le workflow est terminé, télécharge l'artifact `mon_application_job-debug-apk` depuis l'interface Actions.

2) Faire l'export de la base et empaqueter (local, sur la machine WAMP)
   - Place l'APK téléchargé dans le repo (ou note son chemin) et exécute le script PowerShell:

```powershell
cd <repo-root>
.
\scripts\export_and_package.ps1 -ApkPath "path\to\app-debug.apk" -MysqlUser root -MysqlPassword "" -Database bddiane_sp -OutputZip "mon_application_job_ready.zip"
```

   - Le script utilise `mysqldump` (doit être disponible dans le PATH, WAMP fournit `mysqldump.exe`).
   - Le ZIP final contiendra `bddiane_sp.sql` et l'APK.

3) Envoyer par WhatsApp
   - Envoie le fichier ZIP via WhatsApp (Android) ; sur le téléphone le destinataire dézippe et installe `app-debug.apk` (activer installations depuis sources inconnues si besoin) puis importe la base via `bddiane_sp.sql` si nécessaire.

Notes importantes:
 - L'APK debug utilisera par défaut l'URL production `https://afrijob-backend.onrender.com/api` (voir `AppConfig`), ce qui permet d'utiliser directement le backend déployé sur Render.
 - Si tu veux que l'APK pointe vers ton WAMP local, il faudra builder l'APK avec l'argument `--dart-define=API_BASE_URL=http://<IP>:3001` (IP accessible depuis le téléphone) ; je peux ajouter ça si nécessaire.
