#!/usr/bin/env python3
import subprocess
import sys
import os

os.chdir('c:\\Users\\SYST\\Desktop\\mon_application_job')

print("🔧 Déploiement des corrections MySQL...")

# Git operations
try:
    subprocess.run(['git', 'config', 'user.email', 'afrijob@example.com'], check=True)
    subprocess.run(['git', 'config', 'user.name', 'AfriJob Deploy'], check=True)
    print("✓ Configuration git")
except Exception as e:
    print(f"Erreur config git: {e}")

try:
    subprocess.run(['git', 'add', '-A'], check=True)
    print("✓ Fichiers staged")
except Exception as e:
    print(f"Erreur add: {e}")

try:
    result = subprocess.run(['git', 'commit', '-m', 'Fix: Corriger credentials MySQL - variables Railway'], 
                          capture_output=True, text=True)
    print("✓ Commit créé:", result.stdout.strip()[:50])
except Exception as e:
    print(f"Erreur commit: {e}")

try:
    subprocess.run(['git', 'push', 'origin', 'main'], check=True)
    print("✓ Push complété - GitHub Actions déclenché!")
except Exception as e:
    print(f"Erreur push: {e}")

print("\n⏳ Déploiement en cours sur Railway...")
print("   Lien: https://unique-blessing-production-ae97.up.railway.app/")
