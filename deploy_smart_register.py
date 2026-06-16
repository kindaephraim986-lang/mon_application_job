#!/usr/bin/env python3
import subprocess
import os
import time

os.chdir('c:\\Users\\SYST\\Desktop\\mon_application_job')

print("=" * 60)
print("🚀 DÉPLOIEMENT COMPLET - Inscription Intelligente")
print("=" * 60)

# 1. Git config
print("\n1️⃣  Configuration Git...")
subprocess.run(['git', 'config', 'user.email', 'afrijob@deploy.com'], check=False)
subprocess.run(['git', 'config', 'user.name', 'AfriJob Deploy Bot'], check=False)

# 2. Stage et commit
print("2️⃣  Staging des changements...")
subprocess.run(['git', 'add', '-A'], check=False)

print("3️⃣  Création du commit...")
result = subprocess.run(
    ['git', 'commit', '-m', 'Feature: Inscription intelligente - cherche/cree/connecte automatiquement'],
    capture_output=True, text=True
)
print(result.stdout if result.returncode == 0 else "Pas de changement à committer")

# 3. Push
print("4️⃣  Push vers GitHub...")
result = subprocess.run(['git', 'push', 'origin', 'main'], capture_output=True, text=True)
if result.returncode == 0:
    print("✅ Push réussi - GitHub Actions déclenché!")
else:
    print("⚠️  Erreur lors du push:", result.stderr[:100])

print("\n" + "=" * 60)
print("⏳ Déploiement en cours sur Railway...")
print("   URL: https://unique-blessing-production-ae97.up.railway.app/")
print("=" * 60)
print("\n🎯 Nouvelle fonctionnalité:")
print("   - Inscription intelligente implémentée")
print("   - Si le compte existe → connexion automatique")
print("   - Si le compte n'existe pas → création + connexion")
print("   - Utilisateur redirigé automatiquement au dashboard\n")
