-- Incident Polling Table
CREATE TABLE incidentpoll (
	incident_no	VARCHAR(16) NULL DEFAULT NULL,
	incident_date DATETIME NOT NULL,
	calltype VARCHAR(12) NOT NULL,
	box VARCHAR(6) NULL DEFAULT NULL,
	location VARCHAR(255) NOT NULL,
	units VARCHAR(255) NULL DEFAULT NULL,
	INDEX `incident_date` ( `incident_date` ),
	INDEX incident_no ( incident_no )
) ENGINE=MyISAM;

-- GRANT ALL PRIVILEGES ON watchman.incidentpoll TO 'hostsync_user'@'localhost' IDENTIFIED BY '__PWD__';
-- GRANT ALL PRIVILEGES ON watchman.__incidentpoll TO 'hostsync_user'@'localhost' IDENTIFIED BY '__PWD__';