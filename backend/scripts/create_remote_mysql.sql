-- Crée la base et un utilisateur distant pour Render
CREATE DATABASE IF NOT EXISTS `bddiane_sp` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'jobapp'@'%' IDENTIFIED BY 'Ephi5729l';
GRANT ALL PRIVILEGES ON `bddiane_sp`.* TO 'jobapp'@'%';
FLUSH PRIVILEGES;

-- Importer ensuite le schéma depuis bddiane_sp.sql :
-- mysql -h YOUR_PUBLIC_IP -P 3306 -u jobapp -p bddiane_sp < bddiane_sp.sql
