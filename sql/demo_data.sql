
-- ================================================
-- sql/demo_data.sql
-- Run AFTER: schema, triggers, procedures, views
-- Password for ALL accounts: password123
-- ================================================

USE chain_of_custody;
 
-- ─── Officers ────────────────────────────────────
INSERT INTO Officer (name, rank, department, role, password_hash)
VALUES
    ('System Admin',    'Administrator',     'IT Security', 'admin',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    ('Rajan Mehta',     'Senior Inspector',  'Cybercrime',  'officer',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    ('Priya Sharma',    'Forensic Scientist','CFSL',        'analyst',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    ('Justice K. Rao',  'District Judge',    'Judiciary',   'judicial',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy');
 
-- ─── Cases ──────────────────────────────────────
INSERT INTO Case_Details (case_title, description, start_date, status)
VALUES
    ('CyberFraud-2026-001',
     'Bank phishing attack targeting 500+ customers across 3 states.',
     '2026-01-10', 'Under Investigation'),
    ('DataBreach-2026-002',
     'Unauthorized access to hospital patient records — 12,000 records leaked.',
     '2026-02-05', 'Open'),
    ('Ransomware-2026-003',
     'Ransomware attack on state electricity distribution company.',
     '2026-03-01', 'Open');
 
-- ─── Evidence ────────────────────────────────────
INSERT INTO Evidence (case_id, type, hash_value, status)
VALUES
    (1, 'Laptop (Dell XPS 15)',
     'a3f4b2c1d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b6c5d4e3f2a1',
     'In Analysis'),
    (1, 'USB Drive (SanDisk 32GB)',
     'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2',
     'Stored'),
    (2, 'Hard Disk (WD 1TB External)',
     'c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3',
     'Collected'),
    (3, 'Server Log Archive (ZIP — 4.2GB)',
     'd3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4',
     'In Analysis');
 
-- ─── Storage ─────────────────────────────────────
INSERT INTO Storage (evidence_id, location)
VALUES
    (1, 'Evidence Room A — Cabinet 3, Shelf 2'),
    (2, 'Evidence Room A — Cabinet 3, Shelf 3'),
    (3, 'Evidence Room B — Locker 12'),
    (4, 'Digital Archive Server — Secure Vault 2');
 -- ─── Custody Logs (via direct INSERT — triggers auto-timestamp) ──
INSERT INTO Custody_Log (evidence_id, officer_id, action)
VALUES
    (1, 2, 'Evidence collected from suspect premises — 14 MG Road, Bengaluru'),
    (1, 2, 'Transported to Evidence Room A and sealed'),
    (1, 3, 'Received by Forensic Lab — seal intact, hash verified'),
    (2, 2, 'USB Drive seized at suspect workplace'),
    (3, 2, 'Hard disk removed from hospital server room under court order'),
    (4, 2, 'Server log archive exported and transferred to secure vault'),
    (4, 3, 'Log archive received by CFSL for forensic parsing');
 
-- ─── Forensic Reports ───────────────────────────
INSERT INTO Forensic_Report (evidence_id, analyst_name, report_date)
VALUES
    (1, 'Priya Sharma', '2026-02-10'),
    (4, 'Priya Sharma', '2026-03-15');
 
-- ─── Forensic Findings (via procedure — enforces append-only) ──
CALL AppendForensicFinding(
    1, 3,
    'Browser history reveals 47 known phishing domains accessed between Oct-Dec 2025.'
);
 
CALL AppendForensicFinding(
    1, 3,
    'Encrypted archive contains 12,000 stolen credential pairs. MD5 hash cross-verified with breach database.'
);
 
CALL AppendForensicFinding(
    4, 3,
    'Log entries confirm unauthorised SSH login from IP 192.168.45.102 at 03:24 IST on 15-Jan-2026.'
);