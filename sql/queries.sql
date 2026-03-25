-- Full custody trail for one evidence item (most important query)
SELECT
   cl.log_id,
   e.evidence_id,
   e.type              AS evidence_type,
   o.name              AS handling_officer,
   o.rank,
   cl.action,
   cl.action_time
FROM   Custody_Log  cl
JOIN   Evidence     e  ON cl.evidence_id = e.evidence_id
JOIN   Officer      o  ON cl.officer_id  = o.officer_id
WHERE  cl.evidence_id = 1
ORDER  BY cl.action_time ASC;

-- All evidence with case info and current storage
SELECT
   cd.case_id,
   cd.case_title,
   cd.status           AS case_status,
   e.evidence_id,
   e.type,
   e.status            AS evidence_status,
   e.hash_value,
   s.location          AS storage_location
FROM   Case_Details  cd
JOIN   Evidence      e  ON cd.case_id     = e.case_id
LEFT JOIN Storage    s  ON e.evidence_id  = s.evidence_id
ORDER  BY cd.case_id, e.evidence_id;
 
-- Forensic findings with reporting officer name
SELECT
   ffl.finding_id,
   e.type              AS evidence_type,
   o.name              AS reported_by,
   ffl.finding_text,
   ffl.recorded_at
FROM   Forensic_Findings_Log ffl
JOIN   Evidence e  ON ffl.evidence_id = e.evidence_id
JOIN   Officer  o  ON ffl.reported_by  = o.officer_id
ORDER  BY ffl.recorded_at ASC;

-- Evidence items with NO forensic report filed yet
SELECT evidence_id, type, status
FROM   Evidence
WHERE  evidence_id NOT IN (
   SELECT DISTINCT evidence_id FROM Forensic_Report
);
 
-- Officers who have NEVER handled any evidence
SELECT officer_id, name, department
FROM   Officer
WHERE  officer_id NOT IN (
   SELECT DISTINCT officer_id FROM Custody_Log
);
 
-- Cases with NO evidence registered
SELECT case_id, case_title
FROM   Case_Details
WHERE  case_id NOT IN (
   SELECT DISTINCT case_id FROM Evidence
);
