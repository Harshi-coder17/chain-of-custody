-- sql/views.sql
-- Court_View and Audit_View
 
USE chain_of_custody;
 
-- Court_View
-- Read-only access for the Judicial Authority role.
-- Shows full custody trail joined with case details.
CREATE OR REPLACE VIEW Court_View AS
SELECT
   cd.case_id,
   cd.case_title,
   cd.status           AS case_status,
   e.evidence_id,
   e.type              AS evidence_type,
   e.hash_value,
   e.status            AS evidence_status,
   o.name              AS handling_officer,
   o.rank_name              AS officer_rank,
   cl.action           AS custody_action,
   cl.action_time,
   s.location          AS storage_location
FROM   Case_Details  cd
JOIN   Evidence      e   ON cd.case_id     = e.case_id
JOIN   Custody_Log   cl  ON e.evidence_id  = cl.evidence_id
JOIN   Officer       o   ON cl.officer_id  = o.officer_id
LEFT JOIN Storage    s   ON e.evidence_id  = s.evidence_id
ORDER  BY cd.case_id, e.evidence_id, cl.action_time;
 
-- ─────────────────────────────────────────────────
-- Audit_View
-- Combined timeline of custody events + forensic findings.
-- Used in the Audit Log tab of the judicial dashboard.
-- ─────────────────────────────────────────────────
CREATE OR REPLACE VIEW Audit_View AS
SELECT
   e.evidence_id,
   e.type              AS evidence_type,
   'CUSTODY TRANSFER'  AS event_type,
   o.name              AS actor,
   cl.action           AS event_text,
   cl.action_time      AS event_time
FROM   Custody_Log cl
JOIN   Evidence    e  ON cl.evidence_id = e.evidence_id
JOIN   Officer     o  ON cl.officer_id  = o.officer_id
 
UNION ALL
 
SELECT
   e.evidence_id,
   e.type              AS evidence_type,
   'FORENSIC FINDING'  AS event_type,
   o.name              AS actor,
   ffl.finding_text    AS event_text,
   ffl.recorded_at     AS event_time
FROM   Forensic_Findings_Log ffl
JOIN   Evidence  e  ON ffl.evidence_id = e.evidence_id
JOIN   Officer   o  ON ffl.reported_by  = o.officer_id
 
ORDER  BY evidence_id, event_time;
 
DROP VIEW IF EXISTS Case_Evidence_Count;

-- Evidence count per case
CREATE VIEW Case_Evidence_Count AS
SELECT
   cd.case_id,
   cd.case_title,
   COUNT(e.evidence_id) AS evidence_count
FROM   Case_Details cd
LEFT JOIN Evidence e ON cd.case_id = e.case_id
GROUP  BY cd.case_id, cd.case_title;

--Custody stats per evidence
DROP VIEW IF EXISTS Evidence_Custody_Stats;

CREATE VIEW Evidence_Custody_Stats AS
SELECT
   evidence_id,
   COUNT(*)         AS transfer_count,
   MIN(action_time) AS first_custody,
   MAX(action_time) AS latest_custody
FROM   Custody_Log
GROUP  BY evidence_id;

--Evidence status distribution
DROP VIEW IF EXISTS Evidence_Status_Distribution;

CREATE VIEW Evidence_Status_Distribution AS
SELECT
   status,
   COUNT(*) AS total_items
FROM Evidence
GROUP BY status;

--Cases with multiple evidence 
DROP VIEW IF EXISTS Cases_With_Multiple_Evidence;

CREATE VIEW Cases_With_Multiple_Evidence AS
SELECT
   cd.case_id,
   cd.case_title,
   COUNT(e.evidence_id) AS evidence_count
FROM Case_Details cd
JOIN Evidence e ON cd.case_id = e.case_id
GROUP BY cd.case_id
HAVING COUNT(e.evidence_id) > 1;
