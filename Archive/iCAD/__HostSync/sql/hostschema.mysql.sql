-- Incident Polling Table
CREATE TABLE incidentpoll (
	client_license VARCHAR(24) NOT NULL,
	client_ip VARCHAR(16) NOT NULL,
    county_code VARCHAR(12) NOT NULL,
	call_no VARCHAR(16) NOT NULL,
	incident_no	VARCHAR(16) NULL DEFAULT NULL,
	incident_date DATE NOT NULL,
	timestamp INT NOT NULL,
	entry_timestamp INT NULL DEFAULT 0,
	opentime TIME NOT NULL,
	closetime TIME NULL DEFAULT NULL,
	calltype VARCHAR(12) NOT NULL,
	box VARCHAR(6) NULL DEFAULT NULL,
    location VARCHAR(255) NOT NULL,
    PRIMARY KEY ( call_no, county_code ),
    INDEX call_no ( call_no ),
	INDEX incident_no ( incident_no ),
	INDEX incident_date ( incident_date, county_code )
) ENGINE=MyISAM;

-- Table controlling specific site permitted to update hostsync incident database for given county
CREATE TABLE hostsync_control (
    county_code VARCHAR(12) NOT NULL PRIMARY KEY,
    license_no VARCHAR(12) NOT NULL,
    required_ipaddr VARCHAR(16) NULL DEFAULT NULL,
    required_nodename VARCHAR(128) NULL DEFAULT NULL
) ENGINE=MyISAM;

-- Sites/Users permitted to access hostsync incident data
DROP TABLE IF EXISTS `hostsync_client`;
CREATE TABLE `hostsync_client` (
  `id_hash` varchar(32) NOT NULL PRIMARY KEY,
  `timestamp` INT NOT NULL,
  `license` VARCHAR(12) NOT NULL,
  `user_lock` tinyint(1) NOT NULL default '0',
  `active` tinyint(1) NOT NULL default '1',
  `user_name` varchar(25) NOT NULL default '',
  `user_status` tinyint(2) NOT NULL default '0',
  `pwd_hash` varchar(58) NOT NULL,
  `full_name` varchar(255) NOT NULL default '',
  `email` varchar(255) NOT NULL default '',
  `start_date` date NULL default NULL,
  `end_date` date NULL default NULL,
  `ip_restriction` varchar(16) NULL default NULL,
  `cookie_key` varchar(220) NULL default NULL,
  `cookie_time` int(11) NOT NULL default '0',
  KEY `id_hash` USING BTREE (`id_hash`),
  UNIQUE KEY `user_name` USING BTREE (`user_name`),
  UNIQUE KEY `email` USING BTREE (`email`),
  KEY `full_name` USING BTREE (`full_name`(25))
) ENGINE=MYISAM DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `hostsync_session`;
CREATE TABLE `hostsync_session` (
  `obj_id` int(11) NOT NULL auto_increment,
  `session_id` varchar(128) NOT NULL default '',
  `id_hash` varchar(32) NOT NULL default '',
  `time` int(11) NOT NULL default '0',
  `reload_session` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`obj_id`),
  KEY `session_id` USING BTREE (`session_id`),
  KEY `id_hash` USING BTREE (`id_hash`)
) ENGINE=MYISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `system_vars`;
CREATE TABLE `system_vars` (
  `var_name` varchar(64) NOT NULL,
  `var_val` text NOT NULL,
  PRIMARY KEY  (`var_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
-- GRANT SELECT ON watchman.'incidentpoll' TO 'watchman_cad'@'67.217.167.20' IDENTIFIED BY 'XYZ';