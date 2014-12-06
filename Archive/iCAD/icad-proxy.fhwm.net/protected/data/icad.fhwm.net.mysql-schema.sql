-- MySQL dump 10.13  Distrib 5.1.41, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: Watchman_iCAD
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12.10

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alertqueue_User`
--

DROP TABLE IF EXISTS `alertqueue_User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alertqueue_User` (
  `UserID` int(11) NOT NULL AUTO_INCREMENT,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `License` varchar(12) NOT NULL,
  `UserLock` tinyint(1) NOT NULL DEFAULT '0',
  `Active` tinyint(1) NOT NULL DEFAULT '1',
  `UserName` varchar(25) NOT NULL,
  `UserStatus` tinyint(2) NOT NULL DEFAULT '0',
  `Password` varchar(128) NOT NULL,
  `Salt` varchar(128) NOT NULL,
  `FullName` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `IPRestriction` varchar(16) DEFAULT NULL,
  `CookieKey` varchar(220) DEFAULT NULL,
  `CookieTime` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `UserName` (`UserName`),
  UNIQUE KEY `Email` (`Email`),
  KEY `FullName` (`FullName`(25))
) ENGINE=MyISAM AUTO_INCREMENT=1001 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alertqueue_User`
--

LOCK TABLES `alertqueue_User` WRITE;
/*!40000 ALTER TABLE `alertqueue_User` DISABLE KEYS */;
INSERT INTO `alertqueue_User` VALUES (1000,'2011-11-15 18:46:08','PA110003',0,1,'admin',0,'6f75426142398eef1f052a3e18be6a05','28b206548469ce62182048fd9cf91760','iCAD Admin','phil.kapalewski@firehouseautomation.com',NULL,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `alertqueue_User` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alertqueue_SystemVars`
--

DROP TABLE IF EXISTS `alertqueue_SystemVars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alertqueue_SystemVars` (
  `VarName` varchar(64) NOT NULL,
  `VarVal` text NOT NULL,
  PRIMARY KEY (`VarName`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alertqueue_SystemVars`
--

LOCK TABLES `alertqueue_SystemVars` WRITE;
/*!40000 ALTER TABLE `alertqueue_SystemVars` DISABLE KEYS */;
/*!40000 ALTER TABLE `alertqueue_SystemVars` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-11-28 16:04:33
