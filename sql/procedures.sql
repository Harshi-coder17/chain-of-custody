DELIMITER $$
DROP PROCEDURE IF EXISTS TransferCustody;
CREATE PROCEDURE TransferCustody (
   IN  p_evidence_id  INT,
   IN  p_officer_id   INT,
   IN  p_action       VARCHAR(200),
   IN  p_new_status   VARCHAR(50)
)
BEGIN
   DECLARE v_ev_count  INT DEFAULT 0;
   DECLARE v_off_count INT DEFAULT 0;
 
   -- Validate evidence exists
   SELECT COUNT(*) INTO v_ev_count
   FROM   Evidence
   WHERE  evidence_id = p_evidence_id;
 
   IF v_ev_count = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Error: Evidence item not found.';
   END IF;
 
   -- Validate officer exists
   SELECT COUNT(*) INTO v_off_count
   FROM   Officer
   WHERE  officer_id = p_officer_id;
 
   IF v_off_count = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Error: Officer not found.';
   END IF;
 
   -- Atomic: insert log + update status together
   START TRANSACTION;
 
       INSERT INTO Custody_Log (evidence_id, officer_id, action)
       VALUES (p_evidence_id, p_officer_id, p_action);
 
       UPDATE Evidence
       SET    status = p_new_status
       WHERE  evidence_id = p_evidence_id;
 
   COMMIT;
 
   SELECT 'Transfer completed successfully' AS result;
END$$
 
DELIMITER ;
 

DELIMITER $$
DROP PROCEDURE IF EXISTS AppendForensicFinding; 
CREATE PROCEDURE AppendForensicFinding (
   IN p_evidence_id  INT,
   IN p_reported_by  INT,
   IN p_finding_text TEXT
)
BEGIN
   IF p_finding_text IS NULL OR TRIM(p_finding_text) = '' THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Error: Finding text cannot be empty.';
   END IF;
 
   INSERT INTO Forensic_Findings_Log (evidence_id, reported_by, finding_text)
   VALUES (p_evidence_id, p_reported_by, p_finding_text);
 
   SELECT LAST_INSERT_ID() AS new_finding_id,
          'Finding appended successfully' AS result;
END$$
 
DELIMITER ;
 

DELIMITER $$
DROP FUNCTION IF EXISTS GetCustodyCount; 
CREATE FUNCTION GetCustodyCount (p_evidence_id INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
   DECLARE v_count INT DEFAULT 0;
 
   SELECT COUNT(*)
   INTO   v_count
   FROM   Custody_Log
   WHERE  evidence_id = p_evidence_id;
 
   RETURN v_count;
END$$
 
DELIMITER ;
 

DELIMITER $$
DROP FUNCTION IF EXISTS GetAuditSummary; 
CREATE FUNCTION GetAuditSummary (p_evidence_id INT)
RETURNS VARCHAR(500)
READS SQL DATA
DETERMINISTIC
BEGIN
   DECLARE v_custody_cnt  INT DEFAULT 0;
   DECLARE v_findings_cnt INT DEFAULT 0;
   DECLARE v_reports_cnt  INT DEFAULT 0;
   DECLARE v_summary      VARCHAR(500);
 
   SELECT COUNT(*) INTO v_custody_cnt
   FROM   Custody_Log
   WHERE  evidence_id = p_evidence_id;
 
   SELECT COUNT(*) INTO v_findings_cnt
   FROM   Forensic_Findings_Log
   WHERE  evidence_id = p_evidence_id;
 
   SELECT COUNT(*) INTO v_reports_cnt
   FROM   Forensic_Report
   WHERE  evidence_id = p_evidence_id;
 
   SET v_summary = CONCAT('Evidence #', p_evidence_id,
                         ' | Custody transfers: ', v_custody_cnt,
                         ' | Forensic findings: ', v_findings_cnt,
                         ' | Reports filed: ', v_reports_cnt);
 
   RETURN v_summary;
END$$
 
DELIMITER ;
