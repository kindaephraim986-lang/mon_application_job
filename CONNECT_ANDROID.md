## Connecter l'app Android au backend local

Scénarios courants et actions recommandées :

- Emulateur Android (Android Studio - AVD)
  - En développement, l'émulateur utilise l'hôte spécial `10.0.2.2`.
  - L'application est déjà configurée pour utiliser `http://10.0.2.2:3001/api` en mode développement.

- Appareil Android physique (sur le même réseau Wi‑Fi que le PC)
  1. Démarrez le backend sur le PC (ex: depuis `backend/` : `node server.js`).
  2. Trouvez l'IP locale du PC (exécutez `ipconfig` sous Windows).
  3. Ouvrez le port 3001 si nécessaire : exécutez en Administrateur `backend\add_firewall_rule_3001.ps1`.
  4. Lancez l'app Flutter avec le script fourni :

```powershell
cd frontend
./run_android_device.ps1 -DeviceId <device-id>
```

  Si vous voulez forcer une URL précise :

```powershell
./run_android_device.ps1 -DeviceId <device-id> -ApiBaseUrl http://<IP_PC>:3001
```

- Accès via tunnel public (`ngrok`)
  - Installer `ngrok`, exécuter `ngrok http 3001` et utiliser l'URL HTTPS fournie :

```powershell
flutter run -d <device-id> --dart-define=API_BASE_URL=https://xxxxx.ngrok.io
```

Notes techniques
- Le backend écoute sur `0.0.0.0` donc il accepte des connexions externes si le pare‑feu et le réseau le permettent.
- En production, l'app utilise l'URL de production configurée (`https://afrijob-backend.onrender.com`).
