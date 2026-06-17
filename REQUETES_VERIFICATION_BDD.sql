-- ===============================================
-- REQUÊTES DE VÉRIFICATION - bddiane_sp
-- ===============================================
-- Copiez/collez ces requêtes dans phpMyAdmin pour vérifier les données
-- http://localhost/phpmyadmin

-- ===============================================
-- 1️⃣ VÉRIFIER LES UTILISATEURS INSCRITS
-- ===============================================
SELECT 
    id,
    email,
    type_utilisateur,
    DATE_FORMAT(date_inscription, '%d/%m/%Y %H:%i') as 'Date'
FROM utilisateurs
ORDER BY date_inscription DESC;

-- Résultat attendu: 1 ligne par inscription


-- ===============================================
-- 2️⃣ VÉRIFIER LES CANDIDATS
-- ===============================================
SELECT 
    id,
    nom_complet,
    telephone,
    filiere_specialite,
    age,
    domicile,
    sexe
FROM candidats
ORDER BY id DESC;

-- Résultat attendu: 1 ligne par candidat inscrit


-- ===============================================
-- 3️⃣ VÉRIFIER LES ENTREPRISES
-- ===============================================
SELECT 
    id,
    nom_societe,
    domaine_activite,
    telephone,
    adresse_complete,
    ville_lieu
FROM entreprises
ORDER BY id DESC;

-- Résultat attendu: 1 ligne par entreprise inscrite


-- ===============================================
-- 4️⃣ VÉRIFIER LES OFFRES
-- ===============================================
SELECT 
    o.id,
    o.titre,
    o.type_contrat,
    o.lieu,
    o.salaire,
    e.nom_societe,
    DATE_FORMAT(o.date_publication, '%d/%m/%Y') as 'Date'
FROM offres o
JOIN entreprises e ON o.entreprise_id = e.id
ORDER BY o.date_publication DESC;

-- Résultat attendu: Toutes les offres avec leurs entreprises


-- ===============================================
-- 5️⃣ VÉRIFIER LES CANDIDATURES (⭐ PRINCIPAL)
-- ===============================================
SELECT 
    c.id,
    cand.nom_complet as 'Candidat',
    o.titre as 'Offre',
    e.nom_societe as 'Entreprise',
    c.statut,
    DATE_FORMAT(c.date_postulation, '%d/%m/%Y %H:%i') as 'Date Postulation'
FROM candidatures c
JOIN candidats cand ON c.candidat_id = cand.id
JOIN offres o ON c.offre_id = o.id
JOIN entreprises e ON o.entreprise_id = e.id
ORDER BY c.date_postulation DESC;

-- Résultat attendu: 1 ligne par candidature envoyée
-- C'EST LA VÉRIFICATION MAÎTRESSE!


-- ===============================================
-- 6️⃣ VÉRIFIER LES URLs DE FICHIERS UPLOADÉS
-- ===============================================
SELECT 
    id,
    nom_complet,
    photo_profil_url,
    cv_url
FROM candidats
WHERE photo_profil_url IS NOT NULL 
   OR cv_url IS NOT NULL;

-- Résultat attendu: URLs des fichiers en BDD
-- Exemple: http://localhost:3001/uploads/1623845678-123456789.jpg


-- ===============================================
-- 7️⃣ COMPTER LES DONNÉES
-- ===============================================
SELECT 
    (SELECT COUNT(*) FROM utilisateurs) as 'Total Utilisateurs',
    (SELECT COUNT(*) FROM candidats) as 'Total Candidats',
    (SELECT COUNT(*) FROM entreprises) as 'Total Entreprises',
    (SELECT COUNT(*) FROM offres) as 'Total Offres',
    (SELECT COUNT(*) FROM candidatures) as 'Total Candidatures';

-- Résultat attendu: Compte totaux de chaque entité


-- ===============================================
-- 8️⃣ VÉRIFIER LES ABONNEMENTS (Si paiements)
-- ===============================================
SELECT 
    a.id,
    u.email,
    a.type_abonnement,
    a.statut,
    DATE_FORMAT(a.date_debut, '%d/%m/%Y') as 'Début',
    DATE_FORMAT(a.date_fin, '%d/%m/%Y') as 'Fin',
    a.montant
FROM abonnements a
JOIN utilisateurs u ON a.utilisateur_id = u.id
ORDER BY a.date_debut DESC;

-- Résultat attendu: Abonnements actifs/expirés


-- ===============================================
-- 9️⃣ VÉRIFIER CANDIDATURES PAR CANDIDAT
-- ===============================================
-- Remplacez 'email@example.com' par un email réel
SELECT 
    cand.nom_complet,
    COUNT(c.id) as 'Nombre de candidatures',
    GROUP_CONCAT(o.titre SEPARATOR ', ') as 'Offres'
FROM candidatures c
JOIN candidats cand ON c.candidat_id = cand.id
JOIN offres o ON c.offre_id = o.id
JOIN utilisateurs u ON cand.id = u.id
WHERE u.email = 'email@example.com'
GROUP BY cand.id, cand.nom_complet;

-- Remplacez 'email@example.com' dans la requête ci-dessus


-- ===============================================
-- 🔟 VÉRIFIER CANDIDATURES REÇUES PAR ENTREPRISE
-- ===============================================
-- Remplacez 'entreprise@example.com' par un email réel
SELECT 
    e.nom_societe,
    o.titre as 'Offre',
    COUNT(c.id) as 'Candidatures reçues',
    GROUP_CONCAT(cand.nom_complet SEPARATOR ', ') as 'Candidats'
FROM candidatures c
JOIN offres o ON c.offre_id = o.id
JOIN candidats cand ON c.candidat_id = cand.id
JOIN entreprises e ON o.entreprise_id = e.id
JOIN utilisateurs u ON e.id = u.id
WHERE u.email = 'entreprise@example.com'
GROUP BY e.id, o.id, o.titre;

-- Remplacez 'entreprise@example.com' dans la requête ci-dessus


-- ===============================================
-- RÉSUMÉ RAPIDE
-- ===============================================
-- Copier/coller cet ensemble pour vue globale:

SHOW TABLES IN bddiane_sp;
SELECT COUNT(*) as "Utilisateurs" FROM utilisateurs;
SELECT COUNT(*) as "Candidats" FROM candidats;
SELECT COUNT(*) as "Entreprises" FROM entreprises;
SELECT COUNT(*) as "Offres" FROM offres;
SELECT COUNT(*) as "Candidatures" FROM candidatures;

-- ===============================================
-- ✅ TOUT LES COMPTEURS DOIVENT AUGMENTER
-- après chaque action dans l'app!
-- ===============================================
