# Package d'installation Android — mon_application_job

Contenu:
- `app-release.apk` : fichier APK à installer
- `install_adb.ps1` : script PowerShell pour installer via `adb` (Windows)
- `install_adb.sh` : script shell pour installer via `adb` (macOS / Linux)
- `install_adb.bat` : script batch pour Windows
- `metadata.txt` : informations utiles (package/applicationId)

Instructions rapides:

1) Installation manuelle (depuis l'appareil):
   - Copier `app-release.apk` sur l'appareil Android.
   - Sur l'appareil, ouvrir le gestionnaire de fichiers et lancer le fichier APK.
   - Autoriser l'installation depuis des sources inconnues si demandé.

2) Installation via `adb` (ordinateur avec `adb` et appareil en USB):

   Windows PowerShell:

```powershell
adb devices
.\\install_adb.ps1
```

   macOS / Linux:

```bash
adb devices
./install_adb.sh
```

3) Vérifier que l'application se lance:
   - Les scripts exécutent `monkey` pour lancer l'application. Vous pouvez aussi la lancer manuellement depuis le lanceur.

Conseils pour s'assurer que l'application fonctionne bien:
- Vérifier la connectivité réseau et l'URL du backend (si l'app nécessite un backend, assurez-vous que l'API est accessible depuis le réseau mobile).
- Donner les permissions nécessaires à l'application lors de la première exécution (stockage, caméra, etc.).
- Si l'application nécessite une configuration (`APP_ENV` ou endpoints), fournissez un build pré-configuré ou modifiez le fichier de configuration côté serveur.

Problèmes fréquents et solutions:
- Erreur d'installation: exécuter `adb uninstall com.example.mon_application_job` puis réinstaller.
- L'application se ferme au démarrage: vérifier les logs `adb logcat` pour voir les erreurs.

Support:
Si vous voulez, je peux préparer une version signée avec votre clé (keystore) ou un guide pas-à-pas pour configurer les endpoints.
