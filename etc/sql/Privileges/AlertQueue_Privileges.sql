GRANT DELETE, EXECUTE, INSERT, LOCK_TABLES, SELECT, UPDATE, USAGE ON ICAD_MASTER.* TO 'icad_user'@'10.254.0.%' IDENTIFIED BY 'firehouseicad';

GRANT SELECT ON ICAD_MASTER.* TO 'icad_viewer'@'10.254.0.%' IDENTIFIED BY 'firehouseicad';
GRANT INSERT, UPDATE, DELETE ON ICAD_MASTER.AlertQueueSession TO 'icad_viewer'@'10.254.0.%' IDENTIFIED BY 'firehouseicad';
GRANT INSERT, UPDATE, DELETE ON ICAD_MASTER.AlertQueueUser TO 'icad_viewer'@'10.254.0.%' IDENTIFIED BY 'firehouseicad';