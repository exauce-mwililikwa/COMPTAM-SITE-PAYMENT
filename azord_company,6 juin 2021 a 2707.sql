-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : Dim 06 juin 2021 à 21:07
-- Version du serveur :  5.7.31
-- Version de PHP : 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `azord_company`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `ajoutClient`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ajoutClient` (IN `nom` VARCHAR(15), IN `postnom` VARCHAR(15), IN `prenom` VARCHAR(15), IN `attributaccesVal` VARCHAR(20), IN `password` VARCHAR(500), IN `email` VARCHAR(50), IN `AGENT` VARCHAR(25), IN `phone` VARCHAR(25))  begin 
insert into user(_username,_password)values( ( select CONCAT ( (select lpad((select COUNT(*) from identite),4,0)) ,"-",substr(identite._nom,1,1),"-",substr(identite._postnom,1,1),"-",year(CURRENT_TIMESTAMP) ) ) ,password);
INSERT INTO inscription(inscription._matricule,inscription._agentSec,inscription._dateJour)VALUES
(
	( select CONCAT ( (select lpad((select COUNT(*) from identite),4,0)) ,"-",substr(identite._nom,1,1),"-",substr(identite._postnom,1,1),"-",year(CURRENT_TIMESTAMP) ) ),AGENT,CURRENT_TIMESTAMP
);
INSERT INTO identite(identite._matricule,identite._nom,identite._postnom,identite._prenom,identite._attribut)VALUES
(
(select CONCAT ( (select lpad((select COUNT(*) from identite),4,0)) ,"-",substr(identite._nom,1,1),"-",substr(identite._postnom,1,1),"-",year(CURRENT_TIMESTAMP) ) ),nom,postnom,prenom,
    (
    select attributacces._id from attributacces where attributacces._designation=attributaccesVal
    )
);
INSERT into adresseuser(adresseuser._matriculeUser,adresseuser.email,adresseuser._telephone)VALUES
(
	(select CONCAT ( (select lpad((select COUNT(*) from identite),4,0)) ,"-",substr(identite._nom,1,1),"-",substr(identite._postnom,1,1),"-",year(CURRENT_TIMESTAMP) ) ),email,phone
);
INSERT INTO virtualcompte(virtualcompte._matriculeUser)VALUES
(
(select CONCAT ( (select lpad((select COUNT(*) from identite),4,0)) ,"-",substr(identite._nom,1,1),"-",substr(identite._postnom,1,1),"-",year(CURRENT_TIMESTAMP) ) )
);
END$$

DROP PROCEDURE IF EXISTS `modifierMotDePasse`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `modifierMotDePasse` (IN `session` VARCHAR(15), IN `nouveau` VARCHAR(15))  begin 
UPDATE user set user._password=DS_ENCRYPT(nouveau) where user._username=DS_DECRYPT;
END$$

DROP PROCEDURE IF EXISTS `transfert`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `transfert` (IN `destinataire` VARCHAR(15), IN `expeditaire` VARCHAR(15), IN `montant` INT)  begin 
	if((SELECT virtualcompte._montant FROM virtualcompte where virtualcompte._matriculeUser=expeditaire)>=montant) THEN
    UPDATE virtualcompte set virtualcompte._montant=virtualcompte+montant where virtualcompte._matriculeUser=destinataire;
    UPDATE virtualcompte set virtualcompte._montant=virtualcompte-montant where virtualcompte._matriculeUser=expeditaire;
    INSERT into transactionfinancier(transactionfinancier._numeroTransaction,transactionfinancier._expeditaire,transactionfinancier._destinataire,transactionfinancier._montant)
    values
    (
    	(
        select concat
            (
            	"00AZ",YEAR(CURRENT_TIMESTAMP),"",(SELECT COUNT(*)+1 FROM transactionfinancier)
            )
        ),expeditaire,destinataire,montant
        
    );
     END IF;
    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `adresseuser`
--

DROP TABLE IF EXISTS `adresseuser`;
CREATE TABLE IF NOT EXISTS `adresseuser` (
  `_matriculeUser` varchar(10) NOT NULL,
  `email` varchar(50) NOT NULL,
  `_telephone` varchar(10) NOT NULL,
  PRIMARY KEY (`_matriculeUser`),
  UNIQUE KEY `_telephone` (`_telephone`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `attributacces`
--

DROP TABLE IF EXISTS `attributacces`;
CREATE TABLE IF NOT EXISTS `attributacces` (
  `_id` int(11) NOT NULL AUTO_INCREMENT,
  `_designation` varchar(19) NOT NULL,
  PRIMARY KEY (`_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `detailtransactionfinancier`
--

DROP TABLE IF EXISTS `detailtransactionfinancier`;
CREATE TABLE IF NOT EXISTS `detailtransactionfinancier` (
  `_numeroTransaction` varchar(15) NOT NULL,
  `_heure` datetime NOT NULL,
  PRIMARY KEY (`_numeroTransaction`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `identite`
--

DROP TABLE IF EXISTS `identite`;
CREATE TABLE IF NOT EXISTS `identite` (
  `_id` int(11) NOT NULL AUTO_INCREMENT,
  `_matricule` varchar(10) NOT NULL,
  `_nom` varchar(15) NOT NULL,
  `_postnom` varchar(15) NOT NULL,
  `_prenom` varchar(15) NOT NULL,
  `_attribut` int(11) NOT NULL,
  `photo` mediumblob NOT NULL,
  PRIMARY KEY (`_id`),
  UNIQUE KEY `_matricule` (`_matricule`),
  KEY `messages_ibfk_1` (`_attribut`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déclencheurs `identite`
--
DROP TRIGGER IF EXISTS `matriculisation`;
DELIMITER $$
CREATE TRIGGER `matriculisation` AFTER INSERT ON `identite` FOR EACH ROW UPDATE identite set identite._matricule=(select concat('AZ',substr(identite._nom,1,1),'',substr(identite._postnom,1,1),'',(select YEAR(CURRENT_TIMESTAMP))))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `inscription`
--

DROP TABLE IF EXISTS `inscription`;
CREATE TABLE IF NOT EXISTS `inscription` (
  `_id` int(11) NOT NULL AUTO_INCREMENT,
  `_matricule` varchar(10) NOT NULL,
  `_agentSec` varchar(10) NOT NULL,
  `_dateJour` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`_id`),
  UNIQUE KEY `_matricule` (`_matricule`),
  KEY `messages_ibfk_31` (`_agentSec`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `qrbiometrique`
--

DROP TABLE IF EXISTS `qrbiometrique`;
CREATE TABLE IF NOT EXISTS `qrbiometrique` (
  `_matriculeUser` varchar(10) NOT NULL,
  `_identificationQr` varchar(20) NOT NULL,
  PRIMARY KEY (`_matriculeUser`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `transactionfinancier`
--

DROP TABLE IF EXISTS `transactionfinancier`;
CREATE TABLE IF NOT EXISTS `transactionfinancier` (
  `_id` int(11) NOT NULL AUTO_INCREMENT,
  `_numeroTransaction` varchar(15) NOT NULL,
  `_expeditaire` varchar(10) NOT NULL,
  `_destinataire` varchar(15) NOT NULL,
  `_montant` int(11) NOT NULL,
  `_retenu` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`_id`),
  UNIQUE KEY `_numeroTransaction` (`_numeroTransaction`),
  KEY `messages_ibfk_2` (`_expeditaire`),
  KEY `messages_ibfk_3` (`_destinataire`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `_username` varchar(10) NOT NULL,
  `_password` varchar(500) NOT NULL,
  PRIMARY KEY (`_username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `virtualcompte`
--

DROP TABLE IF EXISTS `virtualcompte`;
CREATE TABLE IF NOT EXISTS `virtualcompte` (
  `_matriculeUser` varchar(10) NOT NULL,
  `_montant` int(11) NOT NULL,
  PRIMARY KEY (`_matriculeUser`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `adresseuser`
--
ALTER TABLE `adresseuser`
  ADD CONSTRAINT `adresseuser_ibfk_1` FOREIGN KEY (`_matriculeUser`) REFERENCES `identite` (`_matricule`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `identite`
--
ALTER TABLE `identite`
  ADD CONSTRAINT `identite_ibfk_1` FOREIGN KEY (`_matricule`) REFERENCES `user` (`_username`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`_attribut`) REFERENCES `attributacces` (`_id`);

--
-- Contraintes pour la table `inscription`
--
ALTER TABLE `inscription`
  ADD CONSTRAINT `inscription_ibfk_1` FOREIGN KEY (`_matricule`) REFERENCES `identite` (`_matricule`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_31` FOREIGN KEY (`_agentSec`) REFERENCES `user` (`_username`);

--
-- Contraintes pour la table `qrbiometrique`
--
ALTER TABLE `qrbiometrique`
  ADD CONSTRAINT `qr_user` FOREIGN KEY (`_matriculeUser`) REFERENCES `user` (`_username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `transactionfinancier`
--
ALTER TABLE `transactionfinancier`
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`_expeditaire`) REFERENCES `user` (`_username`),
  ADD CONSTRAINT `messages_ibfk_3` FOREIGN KEY (`_destinataire`) REFERENCES `user` (`_username`),
  ADD CONSTRAINT `transactionfinancier_ibfk_1` FOREIGN KEY (`_numeroTransaction`) REFERENCES `detailtransactionfinancier` (`_numeroTransaction`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `virtualcompte`
--
ALTER TABLE `virtualcompte`
  ADD CONSTRAINT `messages_ibfk_123` FOREIGN KEY (`_matriculeUser`) REFERENCES `user` (`_username`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
