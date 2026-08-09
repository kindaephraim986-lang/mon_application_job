# Script pour corriger les caractères mal encodés en UTF-8 dans les fichiers Dart

$filePath = "frontend\lib\candidate_dashboard.dart"

Write-Host "Lecture du fichier: $filePath"
$content = Get-Content $filePath -Raw -Encoding UTF8

Write-Host "Correction des caractères mal encodés..."

# Remplacer les caractères mal encodés
$content = $content -replace 'SÃƒÂ©lectionnez', 'Sélectionnez'
$content = $content -replace 'rÃƒÂ©el', 'réel'
$content = $content -replace 'rÃƒÂ©elle', 'réelle'
$content = $content -replace 'VÃƒÂ©rifier', 'Vérifier'
$content = $content -replace 'VÃƒÂ©rifiez', 'Vérifiez'
$content = $content -replace 'importÃƒÂ©', 'importé'
$content = $content -replace 'succÃƒÂ¨s', 'succès'
$content = $content -replace 'effectuÃƒÂ©', 'effectué'
$content = $content -replace 'sÃƒÂ©lectionnÃƒÂ©', 'sélectionné'
$content = $content -replace 'sÃƒÂ©lectionner', 'sélectionner'
$content = $content -replace 'Ã¢Å"â€œ', '✓'

Write-Host "Écriture du fichier corrigé..."
Set-Content $filePath $content -Encoding UTF8

Write-Host "✓ Fichier corrigé avec succès!"
