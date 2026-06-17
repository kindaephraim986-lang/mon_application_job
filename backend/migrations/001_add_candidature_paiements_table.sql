-- Migration: Ajouter table candidature_paiements pour tracker les paiements unitaires par candidature
-- Date: 2026-06-15
-- Description: Permet d'enregistrer et valider les paiements de 500 FCFA pour les candidatures unitaires

CREATE TABLE IF NOT EXISTS `candidature_paiements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidat_id` int NOT NULL,
  `offre_id` int NOT NULL,
  `montant` decimal(10,2) NOT NULL DEFAULT 500.00,
  `devise` varchar(10) DEFAULT 'FCFA',
  `methode_paiement` varchar(50) DEFAULT 'mobile_money',
  `statut` enum('réussi','échoué','en_attente') NOT NULL DEFAULT 'en_attente',
  `date_paiement` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `transaction_id_externe` varchar(191) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `candidat_offre_unique` (`candidat_id`, `offre_id`),
  UNIQUE KEY `transaction_id_externe` (`transaction_id_externe`),
  KEY `candidat_id` (`candidat_id`),
  KEY `offre_id` (`offre_id`),
  CONSTRAINT `candidature_paiements_ibfk_1` FOREIGN KEY (`candidat_id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `candidature_paiements_ibfk_2` FOREIGN KEY (`offre_id`) REFERENCES `offres` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
