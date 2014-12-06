DELIMITER ;;

DROP FUNCTION IF EXISTS ConvertEocTime ;;
CREATE FUNCTION ConvertEocTime ( EocTime INT, EocTZ VARCHAR(100) ) RETURNS INT
DETERMINISTIC
BEGIN

DECLARE _EocTime INT DEFAULT 0;

IF EocTime > 0 THEN

	SET _EocTime = UNIX_TIMESTAMP( CONVERT_TZ( FROM_UNIXTIME( EocTime ), EocTZ, 'UTC' ) );

END IF;

RETURN _EocTime;

END ;;

DELIMITER ;

--
-- Table: CALLEVENT
-- Descr: Non-mirrored table for incident push events
--

DROP TABLE IF EXISTS CALLEVENT;
CREATE TABLE CALLEVENT (
	`CallKey` INT NOT NULL AUTO_INCREMENT,
	`CallNo` VARCHAR(25) NULL DEFAULT NULL,
	`CreatedTimestamp` DATETIME DEFAULT NULL,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`EventTime` DATETIME NOT NULL,
	`EventType` INT NOT NULL DEFAULT 0, -- Type of CAD Event: 0=Call Entry 1=Unit Dispatch
	`Agency` VARCHAR(25) NULL DEFAULT NULL,
	`DispatcherId` VARCHAR(20) NULL DEFAULT NULL,
	`Type` VARCHAR(25) NOT NULL,
	`Nature` VARCHAR(200) NOT NULL,
	`Priority` VARCHAR(25) NOT NULL,
	`Location` VARCHAR(255) NULL DEFAULT NULL,
	`LocationAddress` VARCHAR(255) NULL DEFAULT NULL,
	`CityCode` VARCHAR(10) NULL DEFAULT NULL,
	`CrossStreets` VARCHAR(255) NULL DEFAULT NULL,
	`District` VARCHAR(50) NULL DEFAULT NULL,
	`Box` VARCHAR(50) NULL DEFAULT NULL,
	`RadioId` VARCHAR(25) NULL DEFAULT NULL,
	`GPSLatitude` VARCHAR(25) NULL DEFAULT NULL,
	`GPSLongitude` VARCHAR(25) NULL DEFAULT NULL,
	`Comment` VARCHAR(255) NULL DEFAULT NULL,
	PRIMARY KEY ( `CallKey` ),
	INDEX CallNo ( `CallNo` )
) ENGINE=INNODB DEFAULT CHARSET utf8 AUTO_INCREMENT = 1000;

--
-- Table: CALLUNITEVENT
-- Descr: Non-mirrored table for unit assignment/dispatch push events
--

DROP TABLE IF EXISTS CALLUNITEVENT;
CREATE TABLE CALLUNITEVENT (
	`CallKey` INT NOT NULL,
	`CreatedTimestamp` DATETIME DEFAULT NULL,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`UnitId` VARCHAR(100) NOT NULL,
	`DispatchTime` DATETIME NOT NULL,
	`AlertTrans` INT NULL DEFAULT NULL,
	PRIMARY KEY ( `CallKey`, `DispatchTime`, `UnitId` ),
	FOREIGN KEY ( `CallKey` ) REFERENCES CALLEVENT ( `CallKey` )
) ENGINE=INNODB DEFAULT CHARSET utf8;

DROP TABLE IF EXISTS AlertTrans;
CREATE TABLE `AlertTrans` (
	`TransId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`EventNo` VARCHAR(32) NOT NULL,
	`Station` VARCHAR(12) NOT NULL,
	`AlertTime` DATETIME NULL DEFAULT NULL,
	`Status` TINYINT(1) NOT NULL DEFAULT -1, -- -1 Pending, -2 In Progress, 0 Failed, 1 Successful
	`ConfirmTime` DATETIME NULL DEFAULT NULL,
	`Result` VARCHAR(128) NULL DEFAULT NULL,
	Key `EventNo` ( `EventNo` )
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1000;

DROP TABLE IF EXISTS Station;
CREATE TABLE `Station` (
    `Station` VARCHAR(12) NOT NULL,
    `Agency` VARCHAR(25) NOT NULL,
    `DeptName` VARCHAR(128) NOT NULL,
    `PrimaryIp` VARCHAR(16) NOT NULL,
    `PrimaryPort` VARCHAR(5) NOT NULL,
    `SecondaryIp` VARCHAR(16) NULL DEFAULT NULL,
    `SecondaryPort` VARCHAR(5) NULL DEFAULT NULL,
    `Inactive` TINYINT(1) DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS StationUnit;
CREATE TABLE `StationUnit` (
	`UnitId` VARCHAR(12) NOT NULL,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`Station` VARCHAR(12) NOT NULL,
	`MoveTime` DATETIME NULL DEFAULT NULL,
	`MoveId` DATETIME NULL DEFAULT NULL,
	`UnitLabel` VARCHAR(16) NOT NULL,
	`Inactive` TINYINT(1) DEFAULT 0,
	PRIMARY KEY ( `UnitId` ),
	INDEX ( `Station` ),
	FOREIGN KEY ( `Station` ) REFERENCES Station ( `Station` )
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS IncidentTTS;
CREATE TABLE `IncidentTTS` (
	`EventNo` VARCHAR(25) NOT NULL, -- Renamed from IncidentNo
	`DispatchTime` INT NOT NULL,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`Status` TINYINT(1) NOT NULL DEFAULT -1, -- -1 PENDING, 0 SUCCESSFUL, 1 FAILED/TTS ERROR
	`VoiceAlertKeyUri` VARCHAR(255) NULL DEFAULT NULL,
	`UnitList` VARCHAR(255) NULL DEFAULT NULL, -- 12/4 - Drop column in favor of DispatchTime
	PRIMARY KEY ( `EventNo`, `DispatchTime` )
	INDEX ( `EventNo` ),
);

DROP TABLE IF EXISTS CallType;
CREATE TABLE `CallType` (
	`TypeCode` VARCHAR(64) NOT NULL,
	`CallGroup` VARCHAR(16) NOT NULL, -- Current CallGroup Support: (1) FIRE, (2) LOCAL (3) RESCUE (4) EMS (5) MISC
	`Label` VARCHAR(128) NULL DEFAULT NULL,
	`TTS_Announcement` VARCHAR(128) NULL DEFAULT NULL,
	`Ignore` TINYINT(1) NOT NULL DEFAULT 0,
	`Agency` VARCHAR(25) NULL DEFAULT NULL,
	PRIMARY KEY ( `TypeCode` )
);

DROP TABLE IF EXISTS FormattingRules;
CREATE TABLE `FormattingRules` (
	`SearchKey` VARCHAR(64) NOT NULL,
	`ReplaceKey` TEXT NULL DEFAULT NULL,
	`Category` VARCHAR(12) NOT NULL, -- Currently supports categories (1)unit, (2)box, (3)location, (4)nature
	PRIMARY KEY ( `SearchKey` )
);

-- Pittsburgh Unit Formatting Rules
INSERT INTO FormattingRules VALUES
('^(EN)(?:([0-9])?([0-9]{2}))$', 'sub{ "$2<say-as interpret-as=\\"vxml:number\\">$3</say-as> engine" }', 'unit'),
('^(TK)(?:([0-9])?([0-9]{2}))$', 'sub{ "$2<say-as interpret-as=\\"vxml:number\\">$3</say-as> truck" }', 'unit'),
('^(TW)(?:([0-9])?([0-9]{2}))$', 'sub{ "$2<say-as interpret-as=\\"vxml:number\\">$3</say-as> tower" }', 'unit'),
('^(4[0-9]{1})([0-9]{2})$', 'sub{ "unit <say-as interpret-as=\\"vxml:number\\">$1</say-as><say-as interpret-as=\\"vxml:number\\">$2</say-as>" }', 'unit'),
('^(MAC)([0-9]{1,2})$', 'sub{ "MAC <say-as interpret-as=\\"vxml:number\\">$2</say-as>" }', 'unit'),
-- Pittsburgh Box Formatting Rules
('^([0-9])([0-9]{1,})$', 'sub{ my $zone=$1; my $area=$2; my $vxml="number"; if($area=~m/^0/){$vxml="digits";}  "fire zone $zone <say-as interpret-as=\\\"vxml:$vxml\\\">$area</say-as>" }','box');

-- PGMD Unit Formatting Rules
INSERT INTO FormattingRules VALUES
('^(E)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"engine $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(TK)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"truck $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(TW)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"tower $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(RS)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"rescue squad $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(BO)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"battalion chief $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(SO)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"safety officer $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(A)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"ambulance $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(MD)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"medic $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(PA)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"paramedic ambulance $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(PE)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"paramedic engine $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
('^(SQ)(?:([0-9])?([0-9]{2}))([A-Z])?$', 'sub{ my $u=$3;"rescue squad $2 <say-as interpret-as=\\"vxml:".($3=~m/^0/?"digits":"number")."\\">$u</say-as>$4" }', 'unit'),
-- PGMD Box Format
('^([0-9]{2})([0-9]{2})$','sub{ my $box=$1; my $area=$2; my $vxml="number"; if($area=~m/^0/){$vxml="digits";} \"box area <say-as interpret-as=\\\"vxml:number\\\">$box</say-as> <say-as interpret-as=\\\"vxml:$vxml\\\">$area</say-as>\" }','box');

-- Location Formatting Rules
INSERT INTO FormattingRules VALUES
('\\b(AL|ALY|AY)\\b', 'sub{ "Alley" }', 'location'),
('\\b(AV|AVE)\\b', 'sub{ "Avenue" }', 'location'),
('\\b(BL|BLV|BLVD)\\b', 'sub{ "Boulevard" }', 'location'),
('\\b(CSW|CSWY)\\b', 'sub{ "Causeway" }', 'location'),
('\\b(CNT|CTR)\\b', 'sub{ "Center" }', 'location'),
('\\b(CI|CIR|CR)\\b', 'sub{ "Circle" }', 'location'),
('\\b(CT)\\b', 'sub{ "Court" }', 'location'),
('\\b(CRN|CORN|COR)\\b', 'sub{ "Corner" }', 'location'),
('\\b(DR)\\b', 'sub{ "Drive" }', 'location'),
('\\b(EX|EXP|EXPR|EXPY)\\b', 'sub{ "Expressway" }', 'location'),
('\\b(EXT)\\b', 'sub{ "Extension" }', 'location'),
('\\b(FY|FWY|FRW)\\b', 'sub{ "Freeway" }', 'location'),
('\\b(FK|FRK)\\b', 'sub{ "Fork" }', 'location'),
('\\b(GT|GTW|GTWY)\\b', 'sub{ "Gateway" }', 'location'),
('\\b(HTS)\\b', 'sub{ "Heights" }', 'location'),
('\\b(HW|HWY|HY)\\b', 'sub{ "Highway" }', 'location'),
('\\b(INLT|IN|INL)\\b', 'sub{ "Inlet" }', 'location'),
('\\b(JCT|JT|JC)\\b', 'sub{ "Junction" }', 'location'),
('\\b(LNDG|LND|LD)\\b', 'sub{ "Landing" }', 'location'),
('\\b(LN|LA)\\b', 'sub{ "Lane" }', 'location'),
('\\b(MNR)\\b', 'sub{ "Manor" }', 'location'),
('\\b(MDWS)\\b', 'sub{ "Meadows" }', 'location'),
('\\b(MTY|MTW|MW|MWY|MTWY)\\b', 'sub{ "Motorway" }', 'location'),
('\\b(MT|MNT)\\b', 'sub{ "Mount" }', 'location'),
('\\b(PKY|PY)\\b', 'sub{ "Parkway" }', 'location'),
('\\b(PK)\\b', 'sub{ "Pike" }', 'location'),
('\\b(PL)\\b', 'sub{ "Place" }', 'location'),
('\\b(PLZ|PZ)\\b', 'sub{ "Plaza" }', 'location'),
('\\b(PT)\\b', 'sub{ "Point" }', 'location'),
('\\b(PRT)\\b', 'sub{ "Port" }', 'location'),
('\\b(RPDS|RP|RPD)\\b', 'sub{ "Rapids" }', 'location'),
('\\b(RG|RDG)\\b', 'sub{ "Ridge" }', 'location'),
('\\b(RI|RIV|RV)\\b', 'sub{ "River" }', 'location'),
('\\b(RD)\\b', 'sub{ "Road" }', 'location'),
('\\b(RT|RTE|ROU)\\b', 'sub{ "Route" }', 'location'),
('\\b(SHR|SH)\\b', 'sub{ "Shore" }', 'location'),
('\\b(SHRS|SHS)\\b', 'sub{ "Shores" }', 'location'),
('\\b(SPG)\\b', 'sub{ "Spring" }', 'location'),
('\\b(SP|SPU|SPR)\\b', 'sub{ "Spur" }', 'location'),
('\\b(SQ|SQR)\\b', 'sub{ "Square" }', 'location'),
('\\b(STA)\\b', 'sub{ "Station" }', 'location'),
('\\b(ST|STR)\\b', 'sub{ "Street" }', 'location'),
('\\b(SMT|SM|SU)\\b', 'sub{ "Summit" }', 'location'),
('\\b(TER|TE)\\b', 'sub{ "Terrace" }', 'location'),
('\\b(TRL|TR)\\b', 'sub{ "Trail" }', 'location'),
('\\b(TUN|TL)\\b', 'sub{ "Tunnel" }', 'location'),
('\\b(TPKE|TPK|TK|TP|TRNPK)\\b', 'sub{ "Turnpike" }', 'location'),
('\\b(UN)\\b', 'sub{ "Union" }', 'location'),
('\\b(VLY|VAL)\\b', 'sub{ "Valley" }', 'location'),
('\\b(VIA|VDT)\\b', 'sub{ "Viaduct" }', 'location'),
('\\b(VW)\\b', 'sub{ "View" }', 'location'),
('\\b(VLG|VG)\\b', 'sub{ "Village" }', 'location'),
('\\b(VL|VIL)\\b', 'sub{ "Ville" }', 'location'),
('\\b(VIS|VS|VST)\\b', 'sub{ "Vista" }', 'location'),
('\\b(WLK|WK|WL)\\b', 'sub{ "Walk" }', 'location'),
('\\b(WY)\\b', 'sub{ "Way" }', 'location'),
('\\b(PA)\\b', 'sub{ "Pennsylvania" }', 'location'),
('\\b(MD)\\b', 'sub{ "Maryland" }', 'location'),
('\\b(DE)\\b', 'sub{ "Deleware" }', 'location'),
('\\b(WV)\\b', 'sub{ "West Virginia" }', 'location'),
('\\b(VA)\\b', 'sub{ "Virginia" }', 'location'),
('\\b(OH)\\b', 'sub{ "Ohio" }', 'location'),
('\\b(MM)\\b', 'sub{ "Mile Marker" }', 'location'),
('\\b(EX|EXT|EXI)\\b', 'sub{ "Exit" }', 'location'),
('\\b(RM|RMP)\\b', 'sub{ "Ramp" }', 'location'),
('\\b(NB)\\b', 'sub{ "North Bound" }', 'location'),
('\\b(SB)\\b', 'sub{ "South Bound" }', 'location'),
('\\b(EB)\\b', 'sub{ "East Bound" }', 'location'),
('\\b(WB)\\b', 'sub{ "West Bound" }', 'location'),
('\\b(OL)\\b', 'sub{ "Outer Loop" }', 'location'),
('\\b(IL)\\b', 'sub{ "Inner Loop" }', 'location'),
('\\b(ONRP)\\b', 'sub{ "On the ramp to" }', 'location'),
('\\b(OFRP)\\b', 'sub{ "On the ramp from" }', 'location'),
('\\b(END)\\b', 'sub{ "The Dead End" }', 'location'),
('\\b(NE)\\b', 'sub{ "North East" }', 'location'),
('\\b(NW)\\b', 'sub{ "North West" }', 'location'),
('\\b(SE)\\b', 'sub{ "South East" }', 'location'),
('\\b(SW)\\b', 'sub{ "South West" }', 'location'),
('\\b(N)\\b', 'sub{ "North" }', 'location'),
('\\b(S)\\b', 'sub{ "South" }', 'location'),
('\\b(E)\\b', 'sub{ "East" }', 'location'),
('\\b(W)\\b', 'sub{ "West" }', 'location'),
('\\b(BRG)\\b', 'sub{ "Bridge" }', 'location'),
('\\b(NURSG)\\b', 'sub{ "Nursing" }', 'location'),
('\\b(btwn)\\b', 'sub{ "Between" }', 'location'),
('\\b(PGH)\\b', 'sub{ "Pittsburgh" }', 'location');

DROP TABLE IF EXISTS IncidentGeoInfo;
CREATE TABLE `IncidentGeoInfo` (
	`IncidentNo` VARCHAR(25) NOT NULL,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`Status` TINYINT(1) NOT NULL DEFAULT -1, -- -1 PENDING, 0 FAILED/API ERROR, 1 COMPLETE/READY
	`CrossStreet1` VARCHAR(255) NULL DEFAULT NULL,
	`CrossStreet2` VARCHAR(255) NULL DEFAULT NULL,
	PRIMARY KEY ( `IncidentNo` )
);

DROP TABLE IF EXISTS `WebCAD_User`;
CREATE TABLE `WebCAD_User` (
  `UserID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `License` VARCHAR(12) NOT NULL,
  `UserLock` TINYINT(1) NOT NULL DEFAULT '0',
  `Active` TINYINT(1) NOT NULL DEFAULT '1',
  `Username` VARCHAR(25) NOT NULL,
  `UserStatus` TINYINT(2) NOT NULL DEFAULT '0', -- 10=web, 20=alertqueue-agent, 99=ADMIN
  `Password` VARCHAR(128) NOT NULL,
  `Salt` VARCHAR(128) NOT NULL,
  `FullName` VARCHAR(255) NOT NULL,
  `Email` VARCHAR(255) NOT NULL,
  `StartDate` DATE NULL DEFAULT NULL,
  `EndDate` DATE NULL DEFAULT NULL,
  `IPRestriction` VARCHAR(16) NULL DEFAULT NULL,
  `CookieKey` VARCHAR(220) NULL DEFAULT NULL,
  `CookieTime` INT(11) NOT NULL DEFAULT '0',
  `Agency` VARCHAR(12) NULL DEFAULT NULL,
  UNIQUE KEY `UserName` (`UserName`),
  UNIQUE KEY `Email` (`Email`),
  KEY `FullName` (`FullName`(25))
) ENGINE=MYISAM AUTO_INCREMENT=1000;

DROP TABLE IF EXISTS `WebCAD_Session`;
CREATE TABLE `WebCAD_Session` (
  `id` VARCHAR(40) NOT NULL,
  `last_activity` INT(10) NOT NULL,
  `data` TEXT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MYISAM;

DROP TABLE IF EXISTS `AlertQueueSystemVars`;
CREATE TABLE `AlertQueueSystemVars` (
  `VarName` varchar(64) NOT NULL PRIMARY KEY,
  `VarVal` text NOT NULL
) ENGINE=MyISAM;

INSERT INTO AlertQueueSystemVars VALUES
('USER_LOGIN', '1'),
('DEFAULT_TIMEZONE', '');

DROP TABLE IF EXISTS `NotifyIncidentQueue`;
CREATE TABLE `NotifyIncidentQueue` (
	`QueueId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`EventNo` VARCHAR(25) NOT NULL,
	`EventTime` INT NOT NULL,
	`EventType` TINYINT(1) NOT NULL DEFAULT 0, -- 0=PENDING, 1=DISPATCHED
	UNIQUE EventNoEventTimeEventType ( EventNo, EventTime, EventType )
) ENGINE=INNODB;

DROP TABLE IF EXISTS `NotifyIncident`;
CREATE TABLE `NotifyIncident` (
	`NotifyId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`EventNo` VARCHAR(25) NOT NULL,
	`EventTime` INT NOT NULL,
	`Status` TINYINT(1) NOT NULL DEFAULT -1, -- -1=Waiting, 0=Complete 1=Error
	`EventType` TINYINT(1) NOT NULL DEFAULT 0, -- 0=PENDING, 1=DISPATCHED
	`SendTime` TIMESTAMP NULL DEFAULT NULL,
	`AckTime` TIMESTAMP NULL DEFAULT NULL,
	`EventData` TEXT NULL DEFAULT NULL, -- Use for pending incident notification event data storage
	KEY `EventNo` ( `EventNo` ),
	FOREIGN KEY ( `EventNo` ) REFERENCES CARSCALL ( `CALLKEY` )
) ENGINE=MYISAM;

DROP TABLE IF EXISTS `NotifyIncidentRecipients`;
CREATE TABLE `NotifyIncidentRecipients` (
	`RecipId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`NotifyId` INT NOT NULL,
	`MemberId` INT NOT NULL,
	`DestAddr` VARCHAR(16) NOT NULL,
	`DestNetwork` VARCHAR(10) NULL DEFAULT NULL,
	`DeliveryApi` VARCHAR(6) NOT NULL DEFAULT 'SMTP',
	`MessageId` VARCHAR(255) NOT NULL,
	`Status` VARCHAR(3) NOT NULL DEFAULT 0,
	KEY `MemberId` ( `MemberId` ),
	KEY `NotifyId` ( `NotifyId` ),
	FOREIGN KEY ( `NotifyId` ) REFERENCES NotifyIncident ( `NotifyId` )
) ENGINE=MYISAM;

DROP TABLE IF EXISTS `NotifyMember`;
CREATE TABLE `NotifyMember` (
	`ObjId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`MemberName` VARCHAR(255) NOT NULL,
	`MemberId` VARCHAR(64) NOT NULL, -- Optional value to incorporate dept-specific member ID
	`MemberEmail` VARCHAR(255) NOT NULL,
	`NotifyMethod` VARCHAR(24) NOT NULL DEFAULT 'SMS', -- (1) SMS (2) SMTPSMS (3) EMAIL (4) WCTPSMS
	`NotifyAddr` VARCHAR(255) NOT NULL, -- Mobile Number for SMS, MobileNumber@CarrierSMTP_Gateway for SMTPSMS, Email@Address for EMAIL
	`NotifySchedule` VARCHAR(255) NULL DEFAULT NULL,
	`Inactive` TINYINT(1) NOT NULL DEFAULT 0,
	KEY `MemberName` ( `MemberName` )
) ENGINE=MYISAM;

DROP TABLE IF EXISTS `NotifyMemberDevice`;
CREATE TABLE `NotifyMemberDevice` (
	`DeviceId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`MemberObjId` INT NOT NULL,
	`NotifyMethod` VARCHAR(24) NOT NULL DEFAULT 'SMS', -- (1) SMS (2) SMTPSMS (3) EMAIL (4) WCTPSMS
	`NotifyMethodCarrier` VARCHAR(24) NULL DEFAULT NULL, -- Used only w/SMTPSMS & WCTPSMS
	`NotifyAddr` VARCHAR(255) NOT NULL, -- Mobile Number for SMS, MobileNumber@CarrierSMTP_Gateway for SMTPSMS, Email@Address for EMAIL
	`NotifySchedule` VARCHAR(255) NULL DEFAULT NULL,
	`Inactive` TINYINT(1) NOT NULL DEFAULT 0,
	KEY `MemberObjId` ( `MemberObjId` ),
	FOREIGN KEY ( `MemberObjId` ) REFERENCES NotifyMember ( `ObjId` )
) ENGINE=MYISAM;

DROP TABLE IF EXISTS `NotifyMemberRules`;
CREATE TABLE `NotifyMemberRules` (
	`RuleId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`MemberObjId` INT NOT NULL,
	`NotifyOnDispatch` TINYINT(1) NOT NULL DEFAULT 1, -- Notify upon incident dispatch event
	`NotifyOnActive` TINYINT(1) NOT NULL DEFAULT 0, -- Notify upon incident entry event (pending)
	`NotifyArea` TEXT NULL DEFAULT NULL, -- ^([[:<:]][2](1|2|3)[[:>:]])$
	`NotifyRuleset` TEXT NULL DEFAULT NULL, -- (((type:)(TYPE1|TYPE2|TYPE3|TYPE4))|((group:)(FIRE|LOCAL|RESCUE|EMS))
	`NotifyUnits` TEXT NULL DEFAULT NULL, -- [[:<:]](231EN10|231EN17|231TK17)[[:>:]]
	KEY `MemberObjId` ( `MemberObjId` ),
	FOREIGN KEY ( `MemberObjId` ) REFERENCES NotifyMember ( `ObjId` )
) ENGINE=MYISAM;

DROP TABLE IF EXISTS `SmsCarrierGateways`;
CREATE TABLE SmsCarrierGateways (
	`Carrier` VARCHAR(24) NOT NULL PRIMARY KEY,
	`SmsEmailGateway` VARCHAR(100) NULL DEFAULT NULL,
	`SmsEmailInactive` TINYINT(1) NOT NULL DEFAULT 0,
	`WctpGateway` VARCHAR(100) NULL DEFAULT NULL, # http://{auth_user}:{auth_pass}@host:port/path
	`WctpInactive` TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=MyISAM;

INSERT INTO SmsCarrierGateways VALUES
( 'ALLTELL', '', 0, 'http://wctp.alltel.net/wctp', 0 ),
( 'ARCH WIRELESS', '', 0, 'http://wctp.arch.com/wctp', 0 ),
( 'AT&T', 'txt.att.net', 0, 'http://wctp.att.net/wctp', 0 ),
( 'Boost', 'myboostmobile.com', 0, NULL, 0 ),
( 'Cingular', NULL, 0, 'http://wctp.cingular.com/wctp', 0 ),
( 'Sprint-Nextel', 'messaging.sprintpcs.com', 0, 'http://{jsbruns:}@wctp.sprint.com/servlet/wctp', 0),
( 'T-Mobile', 'tmomail.net', 0, NULL, 0 ),
( 'Verizon', 'vtext.com', 0, NULL, 0 ),
( 'Cricket', 'sms.mycricket.com', 0, NULL, 0 ),
( 'Metrocall', NULL, 0, 'http://wctp.metrocall.com/wctp', 0 ),
( 'Skytel', NULL, 0, 'http://wctp.skytel.com/wctp', 0 ),
( 'US Mobility', NULL, 0, 'http://wctp.wirelesscontrol.net/wctp', 0 );

DROP TABLE IF EXISTS `SmsNumberPool`;
CREATE TABLE SmsNumberPool (
	`Number` VARCHAR(24) NOT NULL PRIMARY KEY,
	`Provider` VARCHAR(100) NOT NULL,
	`Inactive` TINYINT(1) DEFAULT 0,
	KEY `Provider` ( `Provider` )
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `ErrorLog`;
CREATE TABLE ErrorLog (
	`RowId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Timestamp` TIMESTAMP,
	`LogFile` VARCHAR(128) NOT NULL,
	`Level` VARCHAR(16) NOT NULL DEFAULT 'ERROR',
	`ErrorText` VARCHAR(255) NOT NULL,
	KEY `LogFile` ( `LogFile` )
) ENGINE=MyISAM;



--
-- Trigger: Trigg_EventDispatch
-- 	 Event: INSERT
--	Timing: BEFORE
--   Table: CALLUNITEVENT
--   Descr:	Trigger for invoking iCAD dispatching via event listener agent (icad-listener)
--

DELIMITER ;;

DROP TRIGGER IF EXISTS `Trigg_EventDispatch` ;;
CREATE TRIGGER Trigg_EventDispatch
BEFORE INSERT ON CALLUNITEVENT
FOR EACH ROW
BEGIN

DECLARE Incident_ViewExists INT DEFAULT 0;
DECLARE IncidentUnit_ViewExists INT DEFAULT 0;
DECLARE DispFlag INT DEFAULT 0;
DECLARE IncidentUnitEvent_Flag INT DEFAULT 0;
DECLARE CallUnitEvent_Flag INT DEFAULT 0;
DECLARE _NotifyFlag INT;
DECLARE _CallGroup VARCHAR(16);
DECLARE _CallType VARCHAR(50);
DECLARE _BoxArea VARCHAR(50);

-- Make sure we have an Incident table in the event there is no icad mirroring/sync
SELECT COUNT(*) INTO Incident_ViewExists FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'Incident';
SELECT COUNT(*) INTO IncidentUnit_ViewExists FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'IncidentUnit';

-- Station dispatch/alert triggering

SELECT COUNT( t1.CallNo ) INTO CallUnitEvent_Flag
FROM CALLUNITEVENT t1
WHERE t1.CallNo = NEW.CallNo AND t1.DispatchTime = NEW.DispatchTime AND t1.UnitId = NEW.UnitId;

IF CallUnitEvent_Flag = 0 THEN

	IF IncidentUnit_ViewExists > 0 THEN
		SELECT COUNT( t1.IncidentNo ) INTO IncidentUnitEvent_Flag
		FROM IncidentUnit t1
		WHERE t1.IncidentNo = NEW.CallNo AND t1.DispatchUTC BETWEEN DATE_ADD(NEW.DispatchTime, INTERVAL -3 SECOND) AND DATE_ADD(NEW.DispatchTime, INTERVAL 3 SECOND) AND t1.Unit = NEW.UnitId;
	END IF;

	IF IncidentUnitEvent_Flag = 0 THEN

	    SELECT COUNT( t1.UnitId ) INTO DispFlag
	    FROM StationUnit t1
	    RIGHT JOIN Station t2 ON t1.Station = t2.Station
	    WHERE t1.UnitId = NEW.UnitId AND t1.Inactive = 0;

	    IF DispFlag > 0 THEN
	        SET New.AlertTrans = -1;
	    END IF;

	END IF;

END IF;

-- Incident notification triggering

SELECT t1.Box, t1.Type, t2.CallGroup INTO _BoxArea, _CallType, _CallGroup
FROM CALLEVENT t1
LEFT JOIN CallType t2 ON t2.TypeCode = t1.Type
WHERE t1.CallNo = NEW.CallNo AND t1.EventTime = NEW.DispatchTime
GROUP BY t1.CallNo;

SELECT COUNT( t2.RuleId ) INTO _NotifyFlag
FROM NotifyMember t1
RIGHT JOIN NotifyMemberRules t2 ON t1.ObjId = t2.MemberObjId
WHERE
(
	(
		_BoxArea REGEXP t2.NotifyArea
		AND
		(
			CONCAT('type:', _CallType) REGEXP t2.NotifyRuleset OR CONCAT('group:', _CallGroup) REGEXP t2.NotifyRuleset
		)
	)
	OR NEW.UnitId REGEXP t2.NotifyUnits
)
AND t2.NotifyOnDispatch = 1 AND t1.Inactive = 0;

IF _NotifyFlag > 0 THEN

	INSERT INTO NotifyIncidentQueue ( EventNo, EventTime, EventType ) VALUES ( NEW.CallNo, UNIX_TIMESTAMP( NEW.DispatchTime ), 1 )
	ON DUPLICATE KEY UPDATE NotifyIncidentQueue.Timestamp = NOW();

END IF;

END ;;


--
-- Trigger: Trigg_EventEntry
-- 	 Event: INSERT
--	Timing: AFTER
--   Table: CALLEVENT
--   Descr:	Trigger for invoking iCAD pending/alertqueue notifications via call events
--

DELIMITER ;;

DROP TRIGGER IF EXISTS `Trigg_EventEntry` ;;
CREATE TRIGGER Trigg_EventEntry
AFTER INSERT ON CALLEVENT
FOR EACH ROW
BEGIN

DECLARE _NotifyFlag INT;
DECLARE _CallGroup VARCHAR(16);

IF NEW.EventType = 0 THEN

	SELECT CallGroup INTO _CallGroup FROM CallType WHERE TypeCode = NEW.Type;

	SELECT COUNT( t2.RuleId ) INTO _NotifyFlag
	FROM NotifyMember t1
	RIGHT JOIN NotifyMemberRules t2 ON t1.ObjId = t2.MemberObjId
	WHERE
		NEW.Box REGEXP t2.NotifyArea
		AND
		(
			CONCAT('type:', NEW.Type) REGEXP t2.NotifyRuleset OR CONCAT('group:', _CallGroup) REGEXP t2.NotifyRuleset
		)
		AND t2.NotifyOnActive = 1 AND t1.Inactive = 0;

	IF _NotifyFlag > 0 THEN

		INSERT INTO NotifyIncidentQueue ( EventNo, EventTime, EventType ) VALUES ( NEW.CallNo, UNIX_TIMESTAMP( NEW.EventTime ), 0 )
		ON DUPLICATE KEY UPDATE NotifyIncidentQueue.Timestamp = NOW();

	END IF;

END IF;

END ;;


--
-- Trigger: Trigg_EventEntryUpdate
-- 	 Event: UPDATE
--	Timing: AFTER
--   Table: CALLEVENT
--   Descr:	Trigger for invoking iCAD pending/alertqueue **UPDATE** notifications via call events (icad-notifier)
--

DELIMITER ;;

DROP TRIGGER IF EXISTS `Trigg_EventEntryUpdate` ;;
CREATE TRIGGER Trigg_EventEntryUpdate
AFTER UPDATE ON CALLEVENT
FOR EACH ROW
BEGIN

DECLARE _ActiveAlert INT;
DECLARE _NotifyFlag INT;
DECLARE _CallGroup VARCHAR(16);

IF NEW.EventType = 0 THEN

	SELECT t1.NotifyId INTO _ActiveAlert FROM NotifyIncident t1 WHERE t1.EventNo = NEW.CallNo AND t1.EventTime = UNIX_TIMESTAMP( NEW.EventTime ) AND t1.EventType = 0;
	SELECT CallGroup INTO _CallGroup FROM CallType WHERE TypeCode = NEW.Type;

	IF _ActiveAlert >= 0 AND ( NEW.Type != OLD.Type OR NEW.LocationAddress != OLD.LocationAddress OR NEW.Box != OLD.Box ) THEN

		INSERT INTO NotifyIncidentQueue ( EventNo, EventTime, EventType ) VALUES ( NEW.CallNo, UNIX_TIMESTAMP( NEW.EventTime ), 0 )
		ON DUPLICATE KEY UPDATE NotifyIncidentQueue.Timestamp = NOW();

	ELSE

		SELECT COUNT( t2.RuleId ) INTO _NotifyFlag
		FROM NotifyMember t1
		RIGHT JOIN NotifyMemberRules t2 ON t1.ObjId = t2.MemberObjId
		WHERE
			NEW.Box REGEXP t2.NotifyArea
			AND
			(
				CONCAT('type:', NEW.Type) REGEXP t2.NotifyRuleset OR CONCAT('group:', _CallGroup) REGEXP t2.NotifyRuleset
			)
			AND t2.NotifyOnActive = 1 AND t1.Inactive = 0;
	END IF;

	IF _NotifyFlag > 0 THEN

		INSERT INTO NotifyIncidentQueue ( EventNo, EventTime, EventType ) VALUES ( NEW.CallNo, NEW.EventTime, 0 )
		ON DUPLICATE KEY UPDATE NotifyIncidentQueue.Timestamp = NOW();

	END IF;

END IF;

END ;;

