#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour corriger les caractères mal encodés dans les fichiers Dart
"""

import os

def fix_encoding(file_path):
    """Corriger les caractères mal encodés dans un fichier"""
    print(f"Correction du fichier: {file_path}")
    
    # Lire le fichier avec détection automatique d'encodage
    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            content = f.read()
    except:
        with open(file_path, 'r', encoding='latin-1') as f:
            content = f.read()
    
    # Corrections des caractères mal encodés (double encodage UTF-8)
    corrections = {
        'SÃƒÂ©lectionnez': 'Sélectionnez',
        'SÃ©lectionnez': 'Sélectionnez',
        'rÃƒÂ©el': 'réel',
        'rÃ©el': 'réel',
        'rÃƒÂ©elle': 'réelle',
        'rÃ©elle': 'réelle',
        'VÃƒÂ©rifier': 'Vérifier',
        'VÃ©rifier': 'Vérifier',
        'VÃƒÂ©rifiez': 'Vérifiez',
        'VÃ©rifiez': 'Vérifiez',
        'importÃƒÂ©': 'importé',
        'importÃ©': 'importé',
        'succÃƒÂ¨s': 'succès',
        'succÃ¨s': 'succès',
        'effectuÃƒÂ©': 'effectué',
        'effectuÃ©': 'effectué',
        'sÃƒÂ©lectionnÃƒÂ©': 'sélectionné',
        'sÃ©lectionnÃ©': 'sélectionné',
        'sÃƒÂ©lectionner': 'sélectionner',
        'sÃ©lectionner': 'sélectionner',
        'Ã¢Å"â€œ': '✓',
        'Ã¢Â€Â"': '–',
    }
    
    original_content = content
    for old, new in corrections.items():
        if old in content:
            print(f"  ✓ Correction: {old} → {new}")
            content = content.replace(old, new)
    
    if content != original_content:
        # Écrire le fichier corrigé en UTF-8
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✓ Fichier {file_path} corrigé avec succès!\n")
        return True
    else:
        print(f"  Aucune correction nécessaire\n")
        return False

# Lister les fichiers à corriger
files_to_fix = [
    'frontend/lib/candidate_dashboard.dart',
    'frontend/lib/screens/home_screen.dart',
    'frontend/lib/screens/profile_screen.dart',
]

print("=" * 60)
print("Correction des caractères mal encodés")
print("=" * 60 + "\n")

fixed_count = 0
for file_path in files_to_fix:
    full_path = os.path.join(os.getcwd(), file_path)
    if os.path.exists(full_path):
        if fix_encoding(full_path):
            fixed_count += 1
    else:
        print(f"⚠ Fichier non trouvé: {file_path}\n")

print("=" * 60)
print(f"Résumé: {fixed_count} fichier(s) corrigé(s)")
print("=" * 60)
