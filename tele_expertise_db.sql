-- phpMyAdmin SQL Dump
-- version 6.0.0-dev+20260524.6165a6f84f
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 02, 2026 at 04:15 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tele_expertise_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `actes_medicaux`
--

CREATE TABLE `actes_medicaux` (
  `id` bigint NOT NULL,
  `nom` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tarif` double NOT NULL,
  `consultation_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `consultations`
--

CREATE TABLE `consultations` (
  `id` bigint NOT NULL,
  `date_consultation` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `motif` text COLLATE utf8mb4_unicode_ci,
  `observations` text COLLATE utf8mb4_unicode_ci,
  `diagnostic` text COLLATE utf8mb4_unicode_ci,
  `traitement` text COLLATE utf8mb4_unicode_ci,
  `cout_base` double NOT NULL DEFAULT '150',
  `statut` enum('EN_COURS','EN_ATTENTE_AVIS_SPECIALISTE','TERMINEE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EN_COURS',
  `patient_id` bigint NOT NULL,
  `generaliste_id` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `creneaux`
--

CREATE TABLE `creneaux` (
  `id` bigint NOT NULL,
  `heure_debut` datetime NOT NULL,
  `heure_fin` datetime NOT NULL,
  `statut` enum('DISPONIBLE','RESERVE','INDISPONIBLE','ARCHIVE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DISPONIBLE',
  `specialiste_id` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `demandes_expertise`
--

CREATE TABLE `demandes_expertise` (
  `id` bigint NOT NULL,
  `question` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `priorite` enum('URGENTE','NORMALE','NON_URGENTE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `statut` enum('EN_ATTENTE','TERMINEE','ANNULEE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EN_ATTENTE',
  `avis_medical` text COLLATE utf8mb4_unicode_ci,
  `recommandations` text COLLATE utf8mb4_unicode_ci,
  `date_demande` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_reponse` datetime DEFAULT NULL,
  `consultation_id` bigint NOT NULL,
  `specialiste_id` bigint NOT NULL,
  `creneau_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `generalistes`
--

CREATE TABLE `generalistes` (
  `id` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `infirmiers`
--

CREATE TABLE `infirmiers` (
  `id` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id` bigint NOT NULL,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prenom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_naissance` date DEFAULT NULL,
  `numero_securite_sociale` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mutuelle` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telephone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `adresse` text COLLATE utf8mb4_unicode_ci,
  `antecedents` text COLLATE utf8mb4_unicode_ci,
  `allergies` text COLLATE utf8mb4_unicode_ci,
  `traitements_en_cours` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `signes_vitaux`
--

CREATE TABLE `signes_vitaux` (
  `id` bigint NOT NULL,
  `tension_arterielle` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `frequence_cardiaque` int DEFAULT NULL,
  `temperature` double DEFAULT NULL,
  `frequence_respiratoire` int DEFAULT NULL,
  `poids` double DEFAULT NULL,
  `taille` double DEFAULT NULL,
  `date_prise` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `patient_id` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `specialistes`
--

CREATE TABLE `specialistes` (
  `id` bigint NOT NULL,
  `specialite` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tarif` double NOT NULL,
  `duree_moyenne` int NOT NULL DEFAULT '30'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `utilisateurs`
--

CREATE TABLE `utilisateurs` (
  `id` bigint NOT NULL,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prenom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('INFIRMIER','GENERALISTE','SPECIALISTE','ADMINISTRATEUR') COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `actes_medicaux`
--
ALTER TABLE `actes_medicaux`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_actes_consultations` (`consultation_id`);

--
-- Indexes for table `consultations`
--
ALTER TABLE `consultations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_consultations_patients` (`patient_id`),
  ADD KEY `fk_consultations_generalistes` (`generaliste_id`);

--
-- Indexes for table `creneaux`
--
ALTER TABLE `creneaux`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_creneaux_specialistes` (`specialiste_id`);

--
-- Indexes for table `demandes_expertise`
--
ALTER TABLE `demandes_expertise`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `consultation_id` (`consultation_id`),
  ADD UNIQUE KEY `creneau_id` (`creneau_id`),
  ADD KEY `fk_demandes_specialistes` (`specialiste_id`);

--
-- Indexes for table `generalistes`
--
ALTER TABLE `generalistes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `infirmiers`
--
ALTER TABLE `infirmiers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_securite_sociale` (`numero_securite_sociale`);

--
-- Indexes for table `signes_vitaux`
--
ALTER TABLE `signes_vitaux`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_signes_vitaux_patients` (`patient_id`);

--
-- Indexes for table `specialistes`
--
ALTER TABLE `specialistes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `actes_medicaux`
--
ALTER TABLE `actes_medicaux`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `consultations`
--
ALTER TABLE `consultations`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `creneaux`
--
ALTER TABLE `creneaux`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `demandes_expertise`
--
ALTER TABLE `demandes_expertise`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `signes_vitaux`
--
ALTER TABLE `signes_vitaux`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `actes_medicaux`
--
ALTER TABLE `actes_medicaux`
  ADD CONSTRAINT `fk_actes_consultations` FOREIGN KEY (`consultation_id`) REFERENCES `consultations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `consultations`
--
ALTER TABLE `consultations`
  ADD CONSTRAINT `fk_consultations_generalistes` FOREIGN KEY (`generaliste_id`) REFERENCES `generalistes` (`id`),
  ADD CONSTRAINT `fk_consultations_patients` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`);

--
-- Constraints for table `creneaux`
--
ALTER TABLE `creneaux`
  ADD CONSTRAINT `fk_creneaux_specialistes` FOREIGN KEY (`specialiste_id`) REFERENCES `specialistes` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `demandes_expertise`
--
ALTER TABLE `demandes_expertise`
  ADD CONSTRAINT `fk_demandes_consultations` FOREIGN KEY (`consultation_id`) REFERENCES `consultations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_demandes_creneaux` FOREIGN KEY (`creneau_id`) REFERENCES `creneaux` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_demandes_specialistes` FOREIGN KEY (`specialiste_id`) REFERENCES `specialistes` (`id`);

--
-- Constraints for table `generalistes`
--
ALTER TABLE `generalistes`
  ADD CONSTRAINT `fk_generalistes_utilisateurs` FOREIGN KEY (`id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `infirmiers`
--
ALTER TABLE `infirmiers`
  ADD CONSTRAINT `fk_infirmiers_utilisateurs` FOREIGN KEY (`id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `signes_vitaux`
--
ALTER TABLE `signes_vitaux`
  ADD CONSTRAINT `fk_signes_vitaux_patients` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `specialistes`
--
ALTER TABLE `specialistes`
  ADD CONSTRAINT `fk_specialistes_utilisateurs` FOREIGN KEY (`id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
