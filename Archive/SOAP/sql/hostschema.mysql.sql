CREATE TABLE regex_modifiers (
    obj_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    license_no VARCHAR(24) NOT NULL,
    regex_field VARCHAR(32) NOT NULL,
    regex_search VARCHAR(255) NOT NULL,
    regex_replace VARCHAR(255) NOT NULL
);

INSERT INTO regex_modifiers VALUES(NULL, 'MD160025', 'location', "\\bPY\\b", "PKWY");
INSERT INTO regex_modifiers VALUES(NULL, 'MD160025', 'location', "\\bHY\\b", "TERR");
INSERT INTO regex_modifiers VALUES(NULL, 'MD160025', 'location', "\\bTE\\b", "HWY");
INSERT INTO regex_modifiers VALUES(NULL, 'MD160025', 'location', "\\bAV\\b", "AVE");

INSERT INTO regex_modifiers VALUES(NULL, 'MD160025', 'city', "\\bPGCO\\b", "PG");
INSERT INTO regex_modifiers VALUES(NULL, 'MD160025', 'city', "\\bPG CO\\b", "PG");
INSERT INTO regex_modifiers VALUES(NULL, 'MD160025', 'city', "\\bHYATTS\\b", "HYATTSVILLE");
INSERT INTO regex_modifiers VALUES(NULL, 'MD160025', 'city', "\\bNEW CAROLLTON\\b", "NEW CARROLLTON");

CREATE TABLE `license` (
    `license_no` varchar(24) NOT NULL COMMENT 'State (MD) Vol/Carreer (01/02) County Code (12) Increment (001)',
    `license_name` varchar(128) default NULL,
    `state` char(2) NOT NULL,
    `county` char(2) NOT NULL,
    `station` char(4) NOT NULL,
    `node_name` varchar(64) NOT NULL,
    `ip_addr` varchar(16) NOT NULL,
    `active` tinyint(1) NOT NULL default '1',
    `suspended` tinyint(1) NOT NULL default '0',
    `sms` tinyint(1) NOT NULL default '0',
    `sms_connection_ip` varchar(16) default NULL,
    `rss` tinyint(1) NOT NULL default '0',
    `rss_connection_ip` varchar(16) default NULL,
    `gps` tinyint(1) NOT NULL DEFAULT 0,
    `sms_viewer` tinyint(1) NOT NULL default '0',
    `sms_viewer_uri` int(11) NOT NULL default '0',
    `sms_viewer_start` varchar(150) default NULL,
    `sms_viewer_end` varchar(150) default NULL,
    `sms_regex_location` varchar(255) default NULL,
    `sms_regex_address` varchar(255) default NULL,
    `sms_regex_city` varchar(255) default NULL,
    `sms_regex_county` varchar(255) default NULL,
    PRIMARY KEY  (`license_no`),
    UNIQUE KEY `sms_viewer_uri` (`sms_viewer_uri`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `alerts` (
    `eid` varchar(12) NOT NULL,
    `name` varchar(255) NOT NULL,
    `phoneno` varchar(24) NOT NULL,
    `carrier` varchar(18) NOT NULL,
    `pref` varchar(12) NOT NULL default 'calltype',
    `calltypes` text,
    `units` text,
    PRIMARY KEY  (`eid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `notification` (
    `message_id` VARCHAR(32) NOT NULL PRIMARY KEY,
    `license_no` varchar(24) NOT NULL,
    `datetime` datetime default NULL,
    `inc_no` varchar(24) NOT NULL,
    `subject` varchar(128) NOT NULL,
    `message` text NOT NULL,
    `recipients` text NOT NULL,
    `result` varchar(255) default NULL,
    `symlink` INT(5) NULL DEFAULT NULL,
    `err` tinyint(1) NOT NULL default '0',
    KEY `license_no` (`license_no`(12))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `recipient` (
    `message_id` VARCHAR(32) NOT NULL,
    `recipient` VARCHAR(16) NOT NULL,
    `carrier` VARCHAR(64) NULL DEFAULT NULL,
    `result` TINYINT(1) NOT NULL DEFAULT 0,
    `err_msg` VARCHAR(24) NULL DEFAULT NULL,
    KEY `message_id` ( `message_id` (32) )
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `rss` (
    `obj_id` int(11) NOT NULL auto_increment,
    `license_no` varchar(24) NOT NULL,
    `datetime` datetime NOT NULL,
    `inc_no` varchar(24) NOT NULL,
    `area` varchar(12) NOT NULL,
    `units` varchar(255) NOT NULL,
    `location` varchar(255) NOT NULL,
    `callGroup` varchar(12) default NULL,
    `callType` varchar(12) default NULL,
    `callTypeName` varchar(64) default NULL,
    `text` varchar(244) default NULL,
    PRIMARY KEY  (`obj_id`),
    UNIQUE KEY `obj_id` (`obj_id`),
    UNIQUE KEY `inc_no` (`inc_no`),
    KEY `license_no` (`license_no`(12)),
    KEY `datetime` (`datetime`)
) ENGINE=MyISAM AUTO_INCREMENT=1078 DEFAULT CHARSET=utf8;

CREATE TABLE `carriers` (
    `carrier` varchar(64) NOT NULL,
    `method` varchar(12) NOT NULL,
    `hostname` varchar(64) NOT NULL,
    `port` varchar(5) default NULL,
    `auth_user` varchar(24) default NULL,
    `auth_pass` varchar(24) default NULL,
    `intl_req` TINYINT(1) DEFAULT 0,
    PRIMARY KEY  (`carrier`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO carriers VALUES('Alltell', 'wctp', 'wctp.alltel.net/wctp', '80', NULL, NULL, 0);
INSERT INTO carriers VALUES('Arch_Wireless', 'wctp', 'wctp.arch.com/wctp', '80', NULL, NULL, 0);
INSERT INTO carriers VALUES('ATT_Wireless_SMTP', 'smtp', 'txt.att.net', '25', NULL, NULL, 0);
INSERT INTO carriers VALUES('ATT_Wireless_WCTP', 'wctp', 'wctp.att.net/wctp', '80', 'watchman', 'FDFV', 0);
INSERT INTO carriers VALUES('Boost', 'smtp', 'myboostmobile.com', '25', NULL, NULL, 0);
INSERT INTO carriers VALUES('Cingular', 'wctp', 'wctp.cingular.com/wctp', '80', NULL, NULL, 0);
INSERT INTO carriers VALUES('Sprint_PCS', 'wctp', 'wctp.telemessage.com/servlet/wctp', '80', 'decho', NULL, 1);
INSERT INTO carriers VALUES('T-Mobile', 'smtp', 'tmomail.net', '25', NULL, NULL, 0);
INSERT INTO carriers VALUES('Nextel', 'wctp', 'wctp.telemessage.com/servlet/wctp', '80', 'decho', NULL, 1);
INSERT INTO carriers VALUES('Verizon', 'smtp', 'vtext.com', '25', NULL, NULL, 0);
INSERT INTO carriers VALUES('Cricket', 'smtp', 'sms.mycricket.com', '25', NULL, NULL, 0);
INSERT INTO carriers VALUES('Metrocall', 'wctp', 'wctp.metrocall.com/wctp', '80', NULL, NULL, 0);
INSERT INTO carriers VALUES('Skytel', 'wctp', 'wctp.skytel.com/wctp', '80', NULL, NULL, 0);
INSERT INTO carriers VALUES('US_Mobility', 'wctp', 'wctp.wirelesscontrol.net/wctp', '80', NULL, NULL, 0);

CREATE TABLE url_redirect (
    url VARCHAR(64) NOT NULL,
    url_key INT(3) NOT NULL,
    datetime DATETIME NOT NULL,
    license_no VARCHAR(24) NOT NULL,
    dest_url VARCHAR(255) NOT NULL,
    PRIMARY KEY ( url ),
    UNIQUE url_key ( url_key )
);
INSERT INTO url_redirect VALUES('http://fhwm.net/x/y', 1, '2020-12-31 10:10:00', 'MD999999', 'http://fhwm.net/x/y');

# BEGIN incident reporting schema

CREATE TABLE `unit` (
    `unit_hash` VARCHAR(32) NOT NULL PRIMARY KEY,
    `license_no` VARCHAR(24) NOT NULL,
    `unit` VARCHAR(24) NOT NULL,
    `label` VARCHAR(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE personnel (
    `member_id` VARCHAR(16) NOT NULL PRIMARY KEY,
    `member_name` VARCHAR(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `incident` (
    `incident_hash` VARCHAR(32) NOT NULL PRIMARY KEY,
    `license_no` VARCHAR(24) NOT NULL,
    `inc_no` VARCHAR(24) NOT NULL,
    `datetime` DATETIME NOT NULL,
    `station` VARCHAR(6) NULL DEFAULT NULL,
    `box` VARCHAR(12) NULL DEFAULT NULL,
    `run_no` INT NULL DEFAULT NULL,
    `call_no` INT NULL DEFAULT NULL,
    `location` VARCHAR(255) NOT NULL,
    `comment` TEXT,
    KEY license_no ( `license_no` ),
    KEY inc_no ( `inc_no` )
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE incident_unit (
    `obj_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `incident_hash` VARCHAR(32) NOT NULL,
    `unit` VARCHAR(12) NOT NULL,
    `status` VARCHAR(16) NULL DEFAULT NULL,
    `dispatch` DATETIME NULL DEFAULT NULL,
    `response` DATETIME NULL DEFAULT NULL,
    `arrival` DATETIME NULL DEFAULT NULL,
    `onradio` DATETIME NULL DEFAULT NULL,
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE unit_personnel (
    `obj_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `incident_hash` VARCHAR(32) NOT NULL,
    `unit` VARCHAR(32) NOT NULL,
    `member_id` VARCHAR(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
