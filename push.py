#!/usr/bin/env python3
import subprocess
import sys

try:
    import os
    os.chdir('c:\\Users\\SYST\\Desktop\\mon_application_job')
    
    print("Staging...")
    subprocess.run(['git', 'add', '-A'], check=True)
    
    print("Committing...")
    subprocess.run(['git', 'commit', '-m', 'Feature: Inscription intelligente'], check=True)
    
    print("Pushing...")
    subprocess.run(['git', 'push', 'origin', 'main'], check=True)
    
    print("SUCCESS")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
