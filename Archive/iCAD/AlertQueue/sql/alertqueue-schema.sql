CREATE DATABASE IF NOT EXISTS Watchman_iCAD;
USE Watchman_iCAD;

-- Sites/Users permitted to access alertqueue incident data
DROP TABLE IF EXISTS `alertqueue_User`;
CREATE TABLE `alertqueue_User` (
  `UserID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `License` VARCHAR(12) NOT NULL,
  `UserLock` TINYINT(1) NOT NULL DEFAULT '0',
  `Active` TINYINT(1) NOT NULL DEFAULT '1',
  `UserName` VARCHAR(25) NOT NULL,
  `UserStatus` TINYINT(2) NOT NULL DEFAULT '0',
  `Password` VARCHAR(128) NOT NULL,
  `Salt` VARCHAR(128) NOT NULL,
  `FullName` VARCHAR(255) NOT NULL,
  `Email` VARCHAR(255) NOT NULL,
  `StartDate` DATE NULL DEFAULT NULL,
  `EndDate` DATE NULL DEFAULT NULL,
  `IPRestriction` VARCHAR(16) NULL DEFAULT NULL,
  `CookieKey` VARCHAR(220) NULL DEFAULT NULL,
  `CookieTime` INT(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `UserName` (`UserName`),
  UNIQUE KEY `Email` (`Email`),
  KEY `FullName` (`FullName`(25))
) ENGINE=MYISAM AUTO_INCREMENT=1000;


DROP TABLE IF EXISTS `alertqueue_Session`;
CREATE TABLE `alertqueue_Session` (
  `SessionID` VARCHAR(128) NOT NULL PRIMARY KEY,
  `UserHash` VARCHAR(32) NOT NULL,
  `SessionTime` INT(11) NOT NULL DEFAULT '0',
  `ReloadSession` TINYINT(1) NOT NULL DEFAULT '0',
  KEY `SessionID` (`SessionID`),
  KEY `UserHash` (`UserHash`)
) ENGINE=MYISAM;


DROP TABLE IF EXISTS `alertqueue_SystemVars`;
CREATE TABLE `alertqueue_SystemVars` (
  `VarName` varchar(64) NOT NULL PRIMARY KEY,
  `VarVal` text NOT NULL
) ENGINE=MyISAM;
-- GRANT SELECT ON watchman.'incidentpoll' TO 'watchman_cad'@'67.217.167.20' IDENTIFIED BY 'XYZ';