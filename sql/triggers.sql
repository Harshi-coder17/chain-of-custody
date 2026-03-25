DELIMITER $$
 
CREATE TRIGGER trg_no_custody_delete
   BEFORE DELETE ON Custody_Log
   FOR EACH ROW
BEGIN
   SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT =
           'SECURITY VIOLATION: Custody_Log records are permanent and cannot be deleted.';
END$$
 
DELIMITER ;
DELIMITER $$
 
CREATE TRIGGER trg_no_findings_update
   BEFORE UPDATE ON Forensic_Findings_Log
   FOR EACH ROW
BEGIN
   SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT =
           'SECURITY VIOLATION: Forensic findings are immutable. New findings must be appended only.';
END$$
 
DELIMITER ;
DELIMITER $$
 
CREATE TRIGGER trg_no_findings_delete
   BEFORE DELETE ON Forensic_Findings_Log
   FOR EACH ROW
BEGIN
   SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT =
           'SECURITY VIOLATION: Forensic findings cannot be deleted once recorded.';
END$$
 
DELIMITER ;
DELIMITER $$
 
CREATE TRIGGER trg_custody_force_timestamp
   BEFORE INSERT ON Custody_Log
   FOR EACH ROW
BEGIN
   SET NEW.action_time = NOW();
END$$
 
DELIMITER ;
DELIMITER $$
 
CREATE TRIGGER trg_findings_force_timestamp
   BEFORE INSERT ON Forensic_Findings_Log
   FOR EACH ROW
BEGIN
   SET NEW.recorded_at = NOW();
END$$
 
DELIMITER ;

