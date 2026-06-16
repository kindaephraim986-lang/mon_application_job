#!/usr/bin/env python3
import os
import subprocess
import sys

os.chdir(r'c:\Users\SYST\Desktop\mon_application_job')

print("=== Finalisation du Deploiement ===\n")

try:
    # Config Git
    print("[*] Configuration Git...")
    subprocess.run(['git', 'config', 'user.email', 'deploy@afrijob.local'], check=True)
    subprocess.run(['git', 'config', 'user.name', 'AfriJob Deployer'], check=True)
    
    # Stage web files
    print("[*] Staging des fichiers web...")
    subprocess.run(['git', 'add', 'afrijob_backend/build/web', '-f'], check=True)
    
    # Stage all changes
    print("[*] Staging de tous les fichiers...")
    subprocess.run(['git', 'add', '-A'], check=True)
    
    # Status before commit
    print("\n[*] Fichiers a committer :")
    result = subprocess.run(['git', 'diff', '--cached', '--name-only'], 
                          capture_output=True, text=True)
    files = result.stdout.strip().split('\n')
    for f in files[:20]:
        if f:
            print(f"    {f}")
    if len(files) > 20:
        print(f"    ... et {len(files)-20} autres fichiers")
    
    # Commit
    print("\n[*] Creation du commit...")
    subprocess.run(['git', 'commit', '-m', 
                   'chore: deploy flutter web application to railway with complete configuration'],
                  check=True)
    
    # Push
    print("[*] Push vers GitHub...")
    subprocess.run(['git', 'push', 'origin', 'main'], check=True)
    
    print("\n" + "="*50)
    print("SUCCESS: Deploiement Declenche!")
    print("="*50)
    print("\n[INFO] GitHub Actions va maintenant :")
    print("  1. Compiler le frontend Flutter Web")
    print("  2. Integrer les fichiers dans le backend")
    print("  3. Deployer sur Railway")
    print("  4. Redemarrer le service")
    print("\n[URL] Votre application sera disponible dans 5-10 minutes :")
    print("https://unique-blessing-production-ae97.up.railway.app")
    print()
    
except subprocess.CalledProcessError as e:
    print(f"\n[ERROR] {e}")
    sys.exit(1)
except Exception as e:
    print(f"\n[ERROR] {e}")
    sys.exit(1)
