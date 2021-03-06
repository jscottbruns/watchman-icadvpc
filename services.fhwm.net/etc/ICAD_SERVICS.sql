DROP TABLE IF EXISTS `iCadUrlMap`;
CREATE TABLE iCadUrlMap (
	`UrlKey` INT NOT NULL PRIMARY KEY,
	`Url` VARCHAR(150) NOT NULL,
	`ForwardUrl` VARCHAR(255) NOT NULL,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM;