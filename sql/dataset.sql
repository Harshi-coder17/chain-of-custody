-- ============================================================
-- sql/dataset.sql
-- Chain-of-Custody DBMS — Extended Demo Dataset
-- UCS310 | Thapar Institute of Engineering & Technology
-- Jan–Jun 2026
--
-- NOTE: This file builds on top of the 4 Officers + 3 Cases
--       + 4 Evidence items already inserted by the project
--       report demo. Run schema.sql, triggers.sql,
--       procedures.sql, views.sql FIRST, then run this file.
--
-- Intentional suspicious patterns seeded in this dataset:
--   1. Officer involved in multiple unrelated cases (officer_id 2, 6, 9)
--   2. Same evidence type appearing in two different cases
--   3. Evidence with suspiciously many custody transfers (evidence_id 3,7,15)
--   4. Same officer handling same evidence repeatedly (evidence_id 5)
--   5. Evidence "idle" — no custody update for months (evidence_id 18,22)
--   6. Evidence collected but never presented to court (evidence_id 6,11,20)
--   7. Large time gap between custody transfers (evidence_id 12)
--   8. Two cases sharing the same crime-scene evidence type
--   9. Officers working on both cybercrime + financial fraud (overlap)
-- ============================================================

USE chain_of_custody;

-- ============================================================
-- DISABLE FK checks during bulk load (re-enabled at the end)
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- TABLE 1: Case_Details
-- Already present (from project demo):
--   case_id 1: CyberFraud-2026-001
--   case_id 2: DataBreach-2026-002
--   case_id 3: Ransomware-2026-003
-- We add 12 more cases (IDs 4–15)
-- ============================================================

INSERT INTO Case_Details (case_title, description, start_date, status) VALUES
-- 4
('PhishNet-2026-004',
 'Coordinated phishing ring targeting government email accounts across 7 ministries. Over 3,000 credentials harvested.',
 '2026-01-15', 'Under Investigation'),
-- 5
('CryptoLaunder-2026-005',
 'Illegal cryptocurrency mixing service used to launder proceeds from ransomware attacks. Bitcoin wallets traced.',
 '2026-01-20', 'Open'),
-- 6
('InsiderTheft-2026-006',
 'Suspected insider data exfiltration at a national defence contractor. Classified documents found on personal USB.',
 '2026-01-22', 'Under Investigation'),
-- 7
('ChildSafety-2026-007',
 'Online child exploitation material distributed via encrypted P2P network. IP traces back to multiple states.',
 '2026-02-01', 'Open'),
-- 8
('ATMSkimmer-2026-008',
 'ATM skimming network compromised 1,200 debit cards across Punjab and Haryana. Hardware implants recovered.',
 '2026-02-08', 'Under Investigation'),
-- 9
('SocialEngr-2026-009',
 'Vishing scam defrauded senior citizens of Rs 4.2 crore. Call centres operating out of Chandigarh and Mohali.',
 '2026-02-12', 'Open'),
-- 10
('CorpEspionage-2026-010',
 'Theft of trade secrets from a pharmaceutical R&D lab. Suspect uploaded formulas to a foreign cloud server.',
 '2026-02-18', 'Under Investigation'),
-- 11
('DDoS-2026-011',
 'Distributed denial-of-service attack on state hospital network during peak hours. Patient records inaccessible for 9 hours.',
 '2026-02-25', 'Open'),
-- 12
('FakeNews-2026-012',
 'Coordinated disinformation campaign during state elections. Deepfake videos circulated on social media.',
 '2026-03-05', 'Under Investigation'),
-- 13 — NOTE: Same lead officer as case 1 (intentional suspicious overlap)
('BankFraud-2026-013',
 'Fraudulent SWIFT transactions totalling Rs 18 crore. Malware injected into core banking middleware.',
 '2026-03-10', 'Open'),
-- 14 — CLOSED case — evidence should be Presented
('IdentityFraud-2025-014',
 'Identity theft ring creating fake Aadhaar and PAN cards for illegal SIM registration. 47 arrests made.',
 '2025-11-01', 'Closed'),
-- 15 — CLOSED
('EmailSpoofing-2025-015',
 'Executive email impersonation fraud targeting finance departments. Rs 2.8 crore transferred to mule accounts.',
 '2025-10-15', 'Closed');

-- ============================================================
-- TABLE 2: Officer
-- Already present (from project demo):
--   officer_id 1: System Admin (admin)
--   officer_id 2: Rajan Mehta  (officer)
--   officer_id 3: Priya Sharma (analyst)
--   officer_id 4: Justice K. Rao (judicial)
-- We add 16 more officers (IDs 5–20)
-- Password hash = bcrypt of 'password123' (10 rounds)
-- ============================================================

INSERT INTO Officer (name, rank, department, role, password_hash) VALUES
-- 5
('Amit Verma', 'Inspector', 'Cybercrime', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 6  ← suspicious: works on cybercrime AND financial fraud cases
('Neha Kapoor', 'Senior Inspector', 'Financial Crime', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 7
('Suresh Pillai', 'Deputy Superintendent', 'Cybercrime', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 8
('Kavya Nair', 'Forensic Scientist', 'CFSL Chandigarh', 'analyst',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 9  ← suspicious: appears in both cybercrime and insider threat cases
('Rohit Bansal', 'Inspector', 'Special Investigation Unit', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 10
('Deepika Rao', 'Senior Forensic Analyst', 'CFSL Hyderabad', 'analyst',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 11
('Manish Gupta', 'Additional Commissioner', 'Cybercrime', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 12
('Anjali Singh', 'Inspector', 'Economic Offences Wing', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 13
('Vikram Thapar', 'Forensic Expert', 'CFSL Delhi', 'analyst',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 14
('Pooja Desai', 'Sub-Inspector', 'Cybercrime', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 15
('Arjun Malhotra', 'Inspector', 'Financial Crime', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 16
('Sunita Yadav', 'Senior Forensic Analyst', 'CFSL Mumbai', 'analyst',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 17
('Justice M. Krishnan', 'Sessions Judge', 'District Court Patiala', 'judicial',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 18
('Kiran Bose', 'Inspector', 'Narcotics & Cybercrime', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 19
('Tanvi Saxena', 'Forensic Scientist', 'CFSL Chandigarh', 'analyst',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
-- 20  ← idle officer: never assigned to any custody log (detectable by subquery)
('Harpreet Gill', 'Sub-Inspector', 'Cybercrime', 'officer',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy');

-- ============================================================
-- TABLE 3: Evidence
-- Already present (from project demo, case_ids 1–3):
--   evidence_id 1: Laptop (Dell XPS 15)         case 1  In Analysis
--   evidence_id 2: USB Drive (SanDisk 32GB)      case 1  Stored
--   evidence_id 3: Hard Disk (WD 1TB External)   case 2  Collected
--   evidence_id 4: Server Log Archive (ZIP 4.2GB) case 3 In Analysis
-- We add evidence_ids 5–35 across cases 1–15
-- ============================================================

INSERT INTO Evidence (case_id, type, hash_value, status) VALUES
-- Case 1 (CyberFraud-2026-001) — 2 more items
(1, 'Email Archive (PST — 12GB)',
 'e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5',
 'In Analysis'),   -- 5
(1, 'Mobile Phone (Samsung Galaxy S23)',
 'f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6',
 'Stored'),         -- 6 ← collected but never presented (idle)

-- Case 2 (DataBreach-2026-002) — 3 more items
(2, 'Network Packet Capture (PCAP — 8.7GB)',
 'a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7',
 'In Analysis'),   -- 7
(2, 'Database Dump (MySQL — 2.1GB)',
 'b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8',
 'Stored'),         -- 8
(2, 'USB Drive (Kingston 64GB)',    -- ← same evidence TYPE as case 1 (suspicious)
 'c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9',
 'Collected'),      -- 9

-- Case 3 (Ransomware-2026-003) — 3 more items
(3, 'Firewall Log Export (TXT — 560MB)',
 'd9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0',
 'Stored'),         -- 10
(3, 'Encrypted Ransom Note (TXT)',
 'e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1',
 'In Analysis'),   -- 11 ← never reached court
(3, 'RAM Dump (WinPmem — 32GB)',
 'f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2',
 'Collected'),      -- 12 ← large time gap between transfers

-- Case 4 (PhishNet-2026-004) — 4 items
(4, 'Phishing Email Headers Archive (EML)',
 'a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3',
 'In Analysis'),   -- 13
(4, 'Spoofed Domain Registration Records',
 'b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4',
 'Collected'),      -- 14
(4, 'Laptop (HP EliteBook 840)',         -- ← same evidence TYPE as case 1
 'c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5',
 'Stored'),         -- 15 ← many custody transfers (suspicious)
(4, 'Mobile Phone (iPhone 14 Pro)',
 'd5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6',
 'In Analysis'),   -- 16

-- Case 5 (CryptoLaunder-2026-005) — 4 items
(5, 'Cold Wallet Hardware (Ledger Nano X)',
 'e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7',
 'Stored'),         -- 17
(5, 'Transaction Blockchain Export (JSON — 780MB)',
 'f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8',
 'Collected'),      -- 18 ← idle evidence (no updates for months)
(5, 'Desktop PC (Custom — Mining Rig)',
 'a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9',
 'In Analysis'),   -- 19
(5, 'External SSD (Samsung T7 — 2TB)',
 'b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0',
 'Collected'),      -- 20 ← never presented

-- Case 6 (InsiderTheft-2026-006) — 4 items
(6, 'USB Drive (Verbatim 32GB)',          -- ← same type as case 1 USB — suspicious
 'c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1',
 'In Analysis'),   -- 21
(6, 'Laptop (Lenovo ThinkPad X1 Carbon)',
 'd1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2',
 'Collected'),      -- 22 ← idle evidence
(6, 'Access Card Clone Device',
 'e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3',
 'Stored'),         -- 23
(6, 'CCTV Footage Archive (MP4 — 22GB)',
 'f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4',
 'In Analysis'),   -- 24

-- Case 7 (ChildSafety-2026-007) — 3 items
(7, 'Hard Disk (Seagate 2TB)',            -- ← same type as case 2 (Seagate) suspicious
 'a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5',
 'In Analysis'),   -- 25
(7, 'Mobile Phone (Realme 11 Pro)',
 'b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6',
 'Stored'),         -- 26
(7, 'Tor Browser Configuration Files',
 'c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7',
 'Collected'),      -- 27

-- Case 8 (ATMSkimmer-2026-008) — 3 items
(8, 'ATM Skimmer Hardware (PCB Module)',
 'd7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8',
 'Stored'),         -- 28
(8, 'Micro SD Card (32GB — Skimmer Storage)',
 'e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9',
 'In Analysis'),   -- 29
(8, 'Laptop (Dell Inspiron 15)',          -- ← same type as case 1 and case 4 (laptop!)
 'f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0',
 'Collected'),      -- 30

-- Case 9 (SocialEngr-2026-009) — 3 items
(9, 'VoIP Server Recording Archive (WAV — 6GB)',
 'a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1',
 'In Analysis'),   -- 31
(9, 'Call Centre Database Export (CSV)',
 'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2',
 'Collected'),      -- 32
(9, 'Mobile Phone (OnePlus 11)',
 'c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3',
 'Stored'),         -- 33

-- Case 10 (CorpEspionage-2026-010) — 3 items
(10, 'Laptop (MacBook Pro 14)',
 'd3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4',
 'In Analysis'),   -- 34
(10, 'Cloud Sync Log Files (ZIP — 1.2GB)',
 'e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5',
 'Collected'),      -- 35
(10, 'External Hard Disk (WD Passport 1TB)',
 'f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6',
 'Stored'),         -- 36

-- Case 11 (DDoS-2026-011) — 3 items
(11, 'Network Switch Log Export (SYSLOG)',
 'a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7',
 'In Analysis'),   -- 37
(11, 'Botnet C2 Server Image (VM Snapshot — 18GB)',
 'b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8',
 'Collected'),      -- 38
(11, 'Router Configuration Backup',
 'c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9',
 'Stored'),         -- 39

-- Case 12 (FakeNews-2026-012) — 3 items
(12, 'Social Media Account Export (JSON)',
 'd9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0',
 'In Analysis'),   -- 40
(12, 'Deepfake Video Files (MP4 — 4.5GB)',
 'e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1',
 'Stored'),         -- 41
(12, 'Mobile Phone (Xiaomi 13 Ultra)',
 'f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2',
 'Collected'),      -- 42

-- Case 13 (BankFraud-2026-013) — 4 items
-- This case shares officers 2, 6 with case 1 — suspicious link
(13, 'SWIFT Transaction Log (XML — 890MB)',
 'a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3',
 'In Analysis'),   -- 43
(13, 'Core Banking Malware Sample (EXE)',
 'b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4',
 'In Analysis'),   -- 44
(13, 'Server Log Archive (ZIP — 3.1GB)',  -- ← same type as case 3 server log
 'c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5',
 'Stored'),         -- 45
(13, 'USB Drive (Transcend 16GB)',        -- ← USB again — cross-case pattern
 'd5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6',
 'Collected'),      -- 46

-- Case 14 (IdentityFraud-2025-014) — CLOSED — evidence should be Presented
(14, 'Fake Aadhaar Card Printing Machine',
 'e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7',
 'Presented'),      -- 47
(14, 'Laptop (Acer Nitro 5)',
 'f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8',
 'Presented'),      -- 48
(14, 'SIM Registration Database Dump (SQL)',
 'a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9',
 'Presented'),      -- 49
(14, 'Mobile Phone (Oppo Reno 8)',
 'b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0',
 'Presented'),      -- 50

-- Case 15 (EmailSpoofing-2025-015) — CLOSED
(15, 'Email Server Access Logs (EML)',
 'c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1',
 'Presented'),      -- 51
(15, 'Laptop (HP Spectre x360)',
 'd1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2',
 'Presented'),      -- 52
(15, 'Banking Wire Transfer Records (PDF)',
 'e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3',
 'Presented');      -- 53

-- ============================================================
-- TABLE 7: Storage
-- Already present: (none explicitly in demo, but if present
-- they used evidence_ids 1–4). We insert for all new evidence.
-- For existing evidence 1–4 we also add storage if missing.
-- ============================================================

-- Existing evidence 1–4 (safe insert — if already present, skip)
INSERT IGNORE INTO Storage (evidence_id, location) VALUES
(1, 'Evidence Room A — Shelf 3, Bay 2'),
(2, 'Evidence Room A — Shelf 3, Bay 3'),
(3, 'Forensics Lab — Cabinet B4'),
(4, 'Secure Server Room — Rack 5');

-- New evidence 5–53
INSERT INTO Storage (evidence_id, location) VALUES
(5,  'Forensics Lab — Workstation 7'),
(6,  'Evidence Room B — Shelf 1, Bay 4'),
(7,  'Forensics Lab — Network Analysis Suite'),
(8,  'Secure Server Room — Rack 6'),
(9,  'Evidence Room A — Shelf 4, Bay 1'),
(10, 'Evidence Room B — Shelf 2, Bay 2'),
(11, 'Forensics Lab — Malware Isolation Unit'),
(12, 'Evidence Room B — Shelf 2, Bay 3'),
(13, 'Forensics Lab — Email Analysis Lab'),
(14, 'Evidence Room A — Shelf 5, Bay 1'),
(15, 'Forensics Lab — Cabinet C1'),
(16, 'Evidence Room A — Shelf 5, Bay 2'),
(17, 'Secure Vault — Cold Storage Locker 3'),
(18, 'Evidence Room C — Shelf 1, Bay 1'),
(19, 'Forensics Lab — Hardware Analysis Bay'),
(20, 'Evidence Room C — Shelf 1, Bay 2'),
(21, 'Forensics Lab — USB Analysis Station'),
(22, 'Evidence Room C — Shelf 2, Bay 1'),
(23, 'Secure Vault — Access Control Archive'),
(24, 'Forensics Lab — Video Analysis Suite'),
(25, 'Forensics Lab — Hard Drive Imaging Suite'),
(26, 'Evidence Room B — Shelf 3, Bay 1'),
(27, 'Forensics Lab — Malware Isolation Unit'),
(28, 'Physical Evidence Room — Locker 12'),
(29, 'Forensics Lab — Micro-Device Lab'),
(30, 'Evidence Room A — Shelf 6, Bay 1'),
(31, 'Forensics Lab — Audio Analysis Suite'),
(32, 'Secure Server Room — Rack 7'),
(33, 'Evidence Room B — Shelf 4, Bay 2'),
(34, 'Forensics Lab — Apple Device Analysis Bay'),
(35, 'Evidence Room C — Shelf 3, Bay 1'),
(36, 'Forensics Lab — Cabinet D2'),
(37, 'Forensics Lab — Network Analysis Suite'),
(38, 'Secure Server Room — Rack 8'),
(39, 'Physical Evidence Room — Locker 18'),
(40, 'Forensics Lab — OSINT Analysis Workstation'),
(41, 'Forensics Lab — Video Analysis Suite'),
(42, 'Evidence Room B — Shelf 5, Bay 1'),
(43, 'Forensics Lab — Financial Forensics Lab'),
(44, 'Forensics Lab — Malware Isolation Unit'),
(45, 'Secure Server Room — Rack 9'),
(46, 'Evidence Room A — Shelf 7, Bay 1'),
(47, 'Court Evidence Storage — Exhibit 14-A'),
(48, 'Court Evidence Storage — Exhibit 14-B'),
(49, 'Court Evidence Storage — Exhibit 14-C'),
(50, 'Court Evidence Storage — Exhibit 14-D'),
(51, 'Court Evidence Storage — Exhibit 15-A'),
(52, 'Court Evidence Storage — Exhibit 15-B'),
(53, 'Court Evidence Storage — Exhibit 15-C');

-- ============================================================
-- TABLE 4: Custody_Log
-- NOTE: Trigger trg_custody_force_timestamp overwrites
--       action_time with NOW(). To seed historical timestamps
--       we must temporarily disable/work around the trigger,
--       OR simply INSERT with explicit timestamps and accept
--       that in a live seed scenario all times become NOW().
--
-- For MySQL Workbench demo purposes we use a workaround:
-- Disable the trigger temporarily, insert with explicit times,
-- then re-enable. This is standard practice for seed scripts.
-- ============================================================

-- Temporarily drop and recreate timestamp trigger as a no-op
-- so we can insert historical data cleanly.
DROP TRIGGER IF EXISTS trg_custody_force_timestamp;

-- Insert ALL custody records with explicit historical timestamps
-- Then we will recreate the trigger at the end of this file.

INSERT INTO Custody_Log (evidence_id, officer_id, action, action_time) VALUES

-- ── Evidence 1: Laptop (Dell XPS 15) — Case 1 CyberFraud ──────────────────
(1, 2, 'Evidence collected from suspect premises — 14 MG Road, Bengaluru. Sealed and tagged EV-001.',
 '2026-01-10 09:15:00'),
(1, 2, 'Transported to Evidence Room A. Hash verified on receipt. Seal intact.',
 '2026-01-10 14:30:00'),
(1, 3, 'Received by Forensic Lab — seal intact, hash verified. Assigned to analyst Priya Sharma.',
 '2026-01-11 10:00:00'),
(1, 3, 'Forensic imaging initiated. DD image created. Original returned to storage.',
 '2026-01-12 11:45:00'),
(1, 2, 'Returned from Forensics Lab to Evidence Room A after imaging complete.',
 '2026-01-15 16:00:00'),

-- ── Evidence 2: USB Drive (SanDisk 32GB) — Case 1 ─────────────────────────
(2, 2, 'USB Drive seized from accused laptop bag at arrest. Sealed EV-002.',
 '2026-01-10 09:20:00'),
(2, 2, 'Deposited in Evidence Room A. Catalogued and sealed.',
 '2026-01-10 14:35:00'),
(2, 3, 'Transferred to Forensics Lab for content extraction. Chain maintained.',
 '2026-01-13 09:00:00'),
(2, 3, 'Forensic clone created. File system analysis in progress.',
 '2026-01-14 15:00:00'),

-- ── Evidence 3: Hard Disk (WD 1TB) — Case 2 DataBreach ───────────────────
(3, 7, 'Seized from hospital server room. Supervised by DSP Suresh Pillai.',
 '2026-02-05 08:30:00'),
(3, 7, 'Transported to Forensics Lab under sealed evidence bag.',
 '2026-02-05 13:00:00'),
(3, 8, 'Received by analyst Kavya Nair. SHA-256 hash verified.',
 '2026-02-06 10:00:00'),
-- suspicious: same officer (7) handles it again after analyst ←
(3, 7, 'Returned to Evidence Room B after initial imaging. Re-sealed by DSP Pillai.',
 '2026-02-08 17:00:00'),
(3, 8, 'Recalled to lab for deeper analysis of patient record partitions.',
 '2026-02-12 09:30:00'),
-- suspicious: officer 7 handles AGAIN — many repeated handling
(3, 7, 'Officer Pillai personally transports evidence to court for preliminary hearing.',
 '2026-02-20 10:00:00'),
(3, 4, 'Received by court — judicial authority Justice K. Rao signs custody sheet.',
 '2026-02-20 14:00:00'),
(3, 7, 'Returned from court to Evidence Room B. Seal verified intact.',
 '2026-02-20 18:30:00'),

-- ── Evidence 4: Server Log Archive — Case 3 Ransomware ───────────────────
(4, 5, 'Server logs extracted from electricity company data centre. Bagged and tagged EV-004.',
 '2026-03-01 11:00:00'),
(4, 5, 'Transferred to Secure Server Room Rack 5.',
 '2026-03-01 15:30:00'),
(4, 10, 'Received by senior analyst Deepika Rao for malware timeline reconstruction.',
 '2026-03-02 09:00:00'),
(4, 10, 'Analysis ongoing. Identified 3 distinct ransomware kill-chain stages.',
 '2026-03-05 14:00:00'),

-- ── Evidence 5: Email Archive — Case 1 ────────────────────────────────────
(5, 2, 'Email PST archive extracted from suspect corporate mailbox. Sealed EV-005.',
 '2026-01-10 09:30:00'),
(5, 2, 'Deposited in Evidence Room A after initial hash computation.',
 '2026-01-10 15:00:00'),
(5, 3, 'Transferred to email analysis lab. Priya Sharma assigned.',
 '2026-01-16 09:00:00'),
-- suspicious: officer 2 handles again — same officer repeated
(5, 2, 'Rajan Mehta retrieves evidence for additional verification at prosecutor request.',
 '2026-01-20 11:00:00'),
(5, 3, 'Re-transferred to Priya Sharma after prosecutor review complete.',
 '2026-01-21 09:30:00'),
-- suspicious: AGAIN officer 2
(5, 2, 'Rajan Mehta transports to court for deposition. Unusual — not standard procedure.',
 '2026-01-28 10:00:00'),
(5, 4, 'Received by Justice K. Rao in court. Exhibit admitted.',
 '2026-01-28 14:30:00'),

-- ── Evidence 6: Mobile Phone (Samsung S23) — Case 1 ──────────────────────
(6, 2, 'Phone seized from accused residence during search. Sealed EV-006.',
 '2026-01-11 10:00:00'),
(6, 2, 'Deposited in Evidence Room B. IMEI recorded: 352819301024567.',
 '2026-01-11 14:00:00'),
-- Evidence 6 is idle after this — never moved forward ←

-- ── Evidence 7: Network PCAP — Case 2 ────────────────────────────────────
(7, 7, 'PCAP file exported from hospital network tap. Sealed EV-007.',
 '2026-02-05 09:00:00'),
(7, 7, 'Transferred to Forensics Lab Network Analysis Suite.',
 '2026-02-05 16:00:00'),
(7, 8, 'Received by Kavya Nair. PCAP integrity verified via SHA-256.',
 '2026-02-06 11:00:00'),
-- many transfers — suspicious ←
(7, 9, 'Inspector Rohit Bansal (SIU) requests access to PCAP for parallel investigation.',
 '2026-02-10 09:00:00'),
-- Rohit Bansal is from SIU — working on both Case 2 and Case 6 (suspicious)
(7, 9, 'PCAP returned to Evidence Room. Rohit Bansal signs off.',
 '2026-02-11 17:00:00'),
(7, 8, 'Recalled by analyst Kavya for second-pass deep inspection.',
 '2026-02-14 09:00:00'),
(7, 7, 'Transported by DSP Pillai to court preliminary hearing.',
 '2026-02-20 09:30:00'),
(7, 4, 'Court receipt acknowledged by Justice K. Rao.',
 '2026-02-20 14:15:00'),

-- ── Evidence 8: Database Dump — Case 2 ───────────────────────────────────
(8, 7, 'MySQL dump extracted from compromised hospital server. Sealed EV-008.',
 '2026-02-05 09:15:00'),
(8, 8, 'Transferred to Forensics Lab. Kavya Nair receives and verifies.',
 '2026-02-06 12:00:00'),
(8, 13, 'Vikram Thapar (CFSL Delhi) brought in for second opinion. Receives custody.',
 '2026-02-15 10:00:00'),
(8, 13, 'Analysis complete. Vikram returns DB dump to Evidence Room B.',
 '2026-02-18 16:00:00'),

-- ── Evidence 9: USB Kingston 64GB — Case 2 ───────────────────────────────
(9, 7, 'USB found in IT admin desk during search. Sealed EV-009.',
 '2026-02-05 10:30:00'),
(9, 8, 'Forwarded to Kavya Nair for forensic imaging.',
 '2026-02-07 09:00:00'),

-- ── Evidence 10: Firewall Log — Case 3 ───────────────────────────────────
(10, 5, 'Firewall logs exported from electricity co. network appliance. Sealed EV-010.',
 '2026-03-01 11:30:00'),
(10, 10, 'Deepika Rao receives logs for correlation with server dump.',
 '2026-03-03 10:00:00'),
(10, 5, 'Amit Verma retrieves for senior review.',
 '2026-03-10 14:00:00'),

-- ── Evidence 11: Ransom Note — Case 3 ────────────────────────────────────
(11, 5, 'Encrypted ransom note found embedded in ransomware payload. Sealed EV-011.',
 '2026-03-01 12:00:00'),
(11, 10, 'Deepika Rao analyses note for linguistic and crypto patterns.',
 '2026-03-04 09:00:00'),
-- Evidence 11 never presented to court ←

-- ── Evidence 12: RAM Dump — Case 3 ─────── LARGE TIME GAP ────────────────
(12, 5, 'RAM dump created at scene using WinPmem. Sealed EV-012.',
 '2026-03-01 13:00:00'),
-- Large gap — next event not until April ←
(12, 10, 'Deepika Rao finally receives RAM dump after 45-day delay.',
 '2026-04-15 10:00:00'),
-- Another big gap — suspicious
(12, 5, 'Retrieved from lab by Amit Verma. Unexplained retrieval.',
 '2026-05-01 11:00:00'),

-- ── Evidence 13: Phishing Emails — Case 4 ────────────────────────────────
(13, 6, 'Email headers archive exported from ministry mail server. Sealed EV-013.',
 '2026-01-15 10:00:00'),
-- Neha Kapoor is Financial Crime but is working on PhishNet (case 4) — suspicious link ←
(13, 6, 'Transferred to Forensics Lab for email header analysis.',
 '2026-01-16 09:00:00'),
(13, 19, 'Tanvi Saxena (CFSL Chandigarh) receives for detailed analysis.',
 '2026-01-17 10:30:00'),
(13, 6, 'Neha Kapoor retrieves for prosecutor briefing. Unusual for Financial Crime dept.',
 '2026-01-25 14:00:00'),
(13, 19, 'Returned to Tanvi Saxena for final report preparation.',
 '2026-01-27 09:00:00'),

-- ── Evidence 14: Domain Records — Case 4 ─────────────────────────────────
(14, 6, 'Spoofed domain registration records obtained via court order. Sealed EV-014.',
 '2026-01-15 10:30:00'),
(14, 19, 'Tanvi Saxena analyses domain WHOIS and DNS history.',
 '2026-01-18 11:00:00'),

-- ── Evidence 15: Laptop (HP EliteBook) — Case 4 — MANY TRANSFERS ─────────
(15, 6, 'Laptop seized from phishing operation command centre. Sealed EV-015.',
 '2026-01-15 11:00:00'),
(15, 6, 'Transported to Evidence Room A.',
 '2026-01-15 16:00:00'),
(15, 19, 'Transferred to CFSL Chandigarh for OS forensics.',
 '2026-01-18 09:00:00'),
(15, 6, 'Retrieved by Neha Kapoor — reason: financial trail on device.',
 '2026-01-22 10:00:00'),
(15, 11, 'ACP Manish Gupta reviews laptop personally. Signed out by ACP.',
 '2026-01-24 14:00:00'),
(15, 11, 'Manish Gupta returns to evidence room. High-ranking sign-off.',
 '2026-01-25 17:00:00'),
(15, 19, 'Re-transferred to Tanvi Saxena for browser history deep-dive.',
 '2026-01-27 09:00:00'),
(15, 6, 'Neha Kapoor retrieves again for financial transaction cross-reference.',
 '2026-01-30 11:00:00'),
-- suspicious: 8 transfers — highest for any evidence item ←
(15, 17, 'Court appearance: Judge M. Krishnan signs court receipt.',
 '2026-02-15 10:00:00'),

-- ── Evidence 16: iPhone 14 Pro — Case 4 ──────────────────────────────────
(16, 6, 'iPhone seized from suspected phishing ring leader. Sealed EV-016.',
 '2026-01-15 11:15:00'),
(16, 19, 'Tanvi Saxena receives for mobile forensics — Cellebrite extraction.',
 '2026-01-19 10:00:00'),
(16, 6, 'Transferred back to Evidence Room A after extraction.',
 '2026-01-23 16:00:00'),

-- ── Evidence 17: Cold Wallet — Case 5 ────────────────────────────────────
(17, 12, 'Ledger hardware wallet seized from suspect apartment. Sealed EV-017.',
 '2026-01-20 09:00:00'),
(17, 16, 'Sunita Yadav (CFSL Mumbai) receives for crypto forensics.',
 '2026-01-21 11:00:00'),
(17, 12, 'Anjali Singh returns wallet to Evidence Room after imaging.',
 '2026-01-28 15:00:00'),

-- ── Evidence 18: Blockchain Export — Case 5 — IDLE ───────────────────────
(18, 12, 'JSON blockchain export downloaded from exchange API. Sealed EV-018.',
 '2026-01-20 09:30:00'),
-- last custody — evidence is idle since January ←

-- ── Evidence 19: Mining Rig PC — Case 5 ──────────────────────────────────
(19, 12, 'Mining rig seized from warehouse. 6 GPUs present. Sealed EV-019.',
 '2026-01-20 10:00:00'),
(19, 16, 'Sunita Yadav receives for hardware and OS analysis.',
 '2026-01-22 09:00:00'),
(19, 12, 'Returned from Mumbai CFSL to Chandigarh Evidence Room C.',
 '2026-02-01 14:00:00'),

-- ── Evidence 20: Samsung T7 SSD — Case 5 ─────────────────────────────────
(20, 12, 'SSD seized from safe in suspect residence. Sealed EV-020.',
 '2026-01-20 10:15:00'),
(20, 12, 'Deposited in Evidence Room C.',
 '2026-01-20 15:00:00'),
-- never progressed to court or analysis ←

-- ── Evidence 21: USB Verbatim — Case 6 ───────────────────────────────────
(21, 9, 'USB found on defence contractor employee desk during search. Sealed EV-021.',
 '2026-01-22 10:00:00'),
-- Rohit Bansal (SIU) working on BOTH Case 2 (DataBreach) and Case 6 (Insider) — suspicious ←
(21, 9, 'Transported to Forensics Lab USB Analysis Station.',
 '2026-01-22 16:00:00'),
(21, 10, 'Deepika Rao receives USB for classified document recovery.',
 '2026-01-23 10:00:00'),
(21, 9, 'Rohit Bansal retrieves for SIU parallel review. Cross-case handling.',
 '2026-01-28 11:00:00'),
(21, 10, 'Deepika Rao re-receives for final analysis report.',
 '2026-01-30 09:00:00'),

-- ── Evidence 22: Lenovo ThinkPad — Case 6 — IDLE ────────────────────────
(22, 9, 'Laptop seized from contractor office. Sealed EV-022.',
 '2026-01-22 10:30:00'),
-- idle since January — never moved to analysis ←

-- ── Evidence 23: Access Card Clone — Case 6 ──────────────────────────────
(23, 9, 'Card cloning device recovered from suspect vehicle. Sealed EV-023.',
 '2026-01-22 11:00:00'),
(23, 9, 'Deposited in Secure Vault.',
 '2026-01-22 17:00:00'),
(23, 13, 'Vikram Thapar receives for hardware reverse engineering.',
 '2026-01-25 10:00:00'),

-- ── Evidence 24: CCTV Footage — Case 6 ───────────────────────────────────
(24, 9, 'CCTV footage archive extracted from DVR at contractor facility. Sealed EV-024.',
 '2026-01-22 12:00:00'),
(24, 10, 'Deepika Rao receives for video frame analysis.',
 '2026-01-24 09:00:00'),

-- ── Evidence 25: Hard Disk (Seagate) — Case 7 ────────────────────────────
(25, 18, 'Hard disk seized from suspect bedroom. Sealed EV-025.',
 '2026-02-01 09:00:00'),
(25, 8, 'Kavya Nair receives for CSAM scan and file carving.',
 '2026-02-02 10:00:00'),
(25, 18, 'Returned to Evidence Room B after initial imaging.',
 '2026-02-08 16:00:00'),

-- ── Evidence 26: Realme Phone — Case 7 ───────────────────────────────────
(26, 18, 'Mobile phone seized from suspect. Sealed EV-026.',
 '2026-02-01 09:15:00'),
(26, 8, 'Kavya Nair receives for mobile forensics — Cellebrite UFED.',
 '2026-02-03 10:00:00'),

-- ── Evidence 27: Tor Config Files — Case 7 ───────────────────────────────
(27, 18, 'Config files found on suspect laptop. Sealed EV-027.',
 '2026-02-01 09:30:00'),
(27, 8, 'Transferred to Malware Isolation Unit for analysis.',
 '2026-02-04 11:00:00'),

-- ── Evidence 28: ATM Skimmer PCB — Case 8 ────────────────────────────────
(28, 15, 'PCB skimmer module physically removed from ATM by bank engineer. Bagged EV-028.',
 '2026-02-08 10:00:00'),
(28, 15, 'Deposited in Physical Evidence Room.',
 '2026-02-08 14:00:00'),
(28, 13, 'Vikram Thapar receives for circuit analysis and firmware extraction.',
 '2026-02-10 09:00:00'),
(28, 15, 'Arjun Malhotra retrieves for prosecutor evidence review.',
 '2026-02-18 11:00:00'),
(28, 17, 'Presented in court before Judge M. Krishnan.',
 '2026-03-01 10:00:00'),

-- ── Evidence 29: Micro SD Card — Case 8 ──────────────────────────────────
(29, 15, 'Micro SD found inside ATM skimmer. Sealed EV-029.',
 '2026-02-08 10:15:00'),
(29, 13, 'Vikram Thapar receives for card data recovery.',
 '2026-02-10 09:30:00'),
(29, 16, 'Sunita Yadav (Mumbai CFSL) brought in for second opinion on card data.',
 '2026-02-20 10:00:00'),
(29, 15, 'Returned to Evidence Room after dual analyst report.',
 '2026-02-25 16:00:00'),

-- ── Evidence 30: Dell Inspiron Laptop — Case 8 ───────────────────────────
(30, 15, 'Laptop seized from ATM fraud syndicate HQ raid. Sealed EV-030.',
 '2026-02-08 11:00:00'),
(30, 13, 'Vikram Thapar receives for OS and browser forensics.',
 '2026-02-12 10:00:00'),

-- ── Evidence 31: VoIP Recording — Case 9 ─────────────────────────────────
(31, 14, 'VoIP archive exported from call centre server. Sealed EV-031.',
 '2026-02-12 10:00:00'),
(31, 19, 'Tanvi Saxena receives for audio analysis and voice matching.',
 '2026-02-13 09:00:00'),
(31, 14, 'Pooja Desai retrieves for case file compilation.',
 '2026-02-20 14:00:00'),

-- ── Evidence 32: Call Centre DB Export — Case 9 ──────────────────────────
(32, 14, 'CSV database exported from call centre CRM. Sealed EV-032.',
 '2026-02-12 10:30:00'),
(32, 16, 'Sunita Yadav receives for victim data cross-referencing.',
 '2026-02-14 11:00:00'),

-- ── Evidence 33: OnePlus Phone — Case 9 ──────────────────────────────────
(33, 14, 'OnePlus phone seized from call centre manager. Sealed EV-033.',
 '2026-02-12 11:00:00'),
(33, 19, 'Tanvi Saxena performs Cellebrite extraction.',
 '2026-02-15 10:00:00'),
(33, 14, 'Returned to Evidence Room B after extraction.',
 '2026-02-19 16:00:00'),

-- ── Evidence 34: MacBook Pro — Case 10 ───────────────────────────────────
(34, 11, 'MacBook seized from pharma researcher suspect office. Sealed EV-034.',
 '2026-02-18 09:00:00'),
-- ACP Manish Gupta (Cybercrime) appearing in Corp Espionage — suspicious link ←
(34, 10, 'Deepika Rao receives for cloud sync artifact recovery.',
 '2026-02-19 10:00:00'),
(34, 11, 'ACP Gupta retrieves MacBook for senior briefing. Unusual.',
 '2026-02-26 11:00:00'),
(34, 10, 'Re-transferred to Deepika Rao after ACP review.',
 '2026-02-27 09:30:00'),

-- ── Evidence 35: Cloud Log ZIP — Case 10 ─────────────────────────────────
(35, 11, 'Cloud sync logs exported from Dropbox forensics API. Sealed EV-035.',
 '2026-02-18 09:30:00'),
(35, 10, 'Deepika Rao analyses upload timestamps and file destinations.',
 '2026-02-20 09:00:00'),

-- ── Evidence 36: WD Passport — Case 10 ───────────────────────────────────
(36, 11, 'External drive seized from suspect home safe. Sealed EV-036.',
 '2026-02-18 10:00:00'),
(36, 13, 'Vikram Thapar receives for deleted file recovery.',
 '2026-02-22 11:00:00'),
(36, 11, 'Manish Gupta retrieves for management review. Cross-dept transfer.',
 '2026-03-01 14:00:00'),

-- ── Evidence 37: Switch Log — Case 11 ────────────────────────────────────
(37, 5, 'Syslog export from hospital network switches. Sealed EV-037.',
 '2026-02-25 09:00:00'),
(37, 8, 'Kavya Nair receives for traffic analysis — DDoS pattern identification.',
 '2026-02-26 10:00:00'),
(37, 5, 'Amit Verma retrieves for incident report preparation.',
 '2026-03-05 14:00:00'),

-- ── Evidence 38: Botnet VM Snapshot — Case 11 ────────────────────────────
(38, 5, 'VM snapshot exported from compromised C2 cloud server. Sealed EV-038.',
 '2026-02-25 10:00:00'),
(38, 10, 'Deepika Rao receives for malware reverse engineering.',
 '2026-02-27 09:00:00'),

-- ── Evidence 39: Router Config — Case 11 ─────────────────────────────────
(39, 5, 'Router config backup extracted on-site. Sealed EV-039.',
 '2026-02-25 10:30:00'),
(39, 8, 'Kavya Nair receives for network topology reconstruction.',
 '2026-02-28 11:00:00'),
(39, 5, 'Returned to Physical Evidence Room.',
 '2026-03-06 15:00:00'),

-- ── Evidence 40: Social Media Export — Case 12 ───────────────────────────
(40, 18, 'Social media account data exported via law enforcement request. Sealed EV-040.',
 '2026-03-05 09:00:00'),
(40, 19, 'Tanvi Saxena receives for OSINT and bot network analysis.',
 '2026-03-06 10:00:00'),
(40, 18, 'Returned to Evidence Room after initial analysis.',
 '2026-03-12 16:00:00'),

-- ── Evidence 41: Deepfake Videos — Case 12 ───────────────────────────────
(41, 18, 'Deepfake video files downloaded from suspect cloud server. Sealed EV-041.',
 '2026-03-05 09:30:00'),
(41, 16, 'Sunita Yadav receives for AI-generated content forensics.',
 '2026-03-07 10:00:00'),
(41, 18, 'Returned to Video Analysis Suite evidence storage.',
 '2026-03-14 15:00:00'),

-- ── Evidence 42: Xiaomi Phone — Case 12 ──────────────────────────────────
(42, 18, 'Xiaomi phone seized from social media influencer suspect. Sealed EV-042.',
 '2026-03-05 10:00:00'),
(42, 19, 'Tanvi Saxena receives for Cellebrite extraction.',
 '2026-03-08 11:00:00'),

-- ── Evidence 43: SWIFT Log — Case 13 ─────────────────────────────────────
-- Officer 2 (Rajan Mehta) and Officer 6 (Neha Kapoor) both in Case 13 AND Case 1
-- This makes them officers working across both CyberFraud and BankFraud ← suspicious
(43, 6, 'SWIFT XML logs obtained from bank compliance team. Sealed EV-043.',
 '2026-03-10 09:00:00'),
(43, 6, 'Neha Kapoor transfers to Financial Forensics Lab.',
 '2026-03-10 15:00:00'),
(43, 16, 'Sunita Yadav receives for transaction pattern analysis.',
 '2026-03-11 10:00:00'),
(43, 6, 'Neha Kapoor retrieves for prosecutor presentation.',
 '2026-03-20 11:00:00'),
(43, 2, 'Rajan Mehta co-signs custody — cross-case officer involvement (Case 1 + Case 13).',
 '2026-03-22 10:00:00'),

-- ── Evidence 44: Malware Sample — Case 13 ────────────────────────────────
(44, 6, 'Malware EXE extracted from bank middleware server. Sealed EV-044.',
 '2026-03-10 09:30:00'),
(44, 13, 'Vikram Thapar receives for reverse engineering and signature analysis.',
 '2026-03-12 10:00:00'),
(44, 10, 'Deepika Rao receives for second opinion — different CFSL.',
 '2026-03-18 11:00:00'),

-- ── Evidence 45: Server Log ZIP — Case 13 ────────────────────────────────
(45, 6, 'Banking server logs exported. Sealed EV-045.',
 '2026-03-10 10:00:00'),
(45, 16, 'Sunita Yadav receives for log correlation with SWIFT records.',
 '2026-03-13 09:00:00'),
(45, 6, 'Neha Kapoor retrieves for combined report.',
 '2026-03-24 14:00:00'),

-- ── Evidence 46: USB Transcend — Case 13 ─────────────────────────────────
(46, 6, 'USB found in banking system administrator desk. Sealed EV-046.',
 '2026-03-10 10:30:00'),
(46, 16, 'Sunita Yadav receives for content analysis.',
 '2026-03-14 10:00:00'),

-- ── Evidence 47–50: Case 14 CLOSED — full chain to court ─────────────────
(47, 12, 'Aadhaar printing machine seized in raid. Sealed EV-047.',
 '2025-11-01 10:00:00'),
(47, 13, 'Vikram Thapar receives for device forensics.',
 '2025-11-05 09:00:00'),
(47, 12, 'Returned to Evidence Room after analysis.',
 '2025-11-15 16:00:00'),
(47, 12, 'Transferred to Court Evidence Storage for trial.',
 '2025-12-10 10:00:00'),
(47, 17, 'Justice M. Krishnan signs exhibit receipt.',
 '2025-12-10 14:00:00'),

(48, 12, 'Acer Nitro laptop seized from printing lab. Sealed EV-048.',
 '2025-11-01 10:15:00'),
(48, 13, 'Vikram Thapar receives for browser and document forensics.',
 '2025-11-06 09:00:00'),
(48, 12, 'Returned to Evidence Room after imaging.',
 '2025-11-16 15:00:00'),
(48, 12, 'Transferred to court for trial.',
 '2025-12-10 10:30:00'),
(48, 17, 'Judge M. Krishnan confirms court receipt.',
 '2025-12-10 14:15:00'),

(49, 12, 'SIM database dump exported from server in raid. Sealed EV-049.',
 '2025-11-01 11:00:00'),
(49, 16, 'Sunita Yadav receives for database forensics.',
 '2025-11-08 10:00:00'),
(49, 12, 'Returned to Evidence Room C.',
 '2025-11-20 16:00:00'),
(49, 12, 'Court transfer for trial.',
 '2025-12-10 11:00:00'),
(49, 17, 'Exhibit admitted by Judge Krishnan.',
 '2025-12-10 14:30:00'),

(50, 12, 'Oppo phone seized from accused. Sealed EV-050.',
 '2025-11-01 11:15:00'),
(50, 16, 'Sunita Yadav performs Cellebrite extraction.',
 '2025-11-09 10:00:00'),
(50, 12, 'Returned to Evidence Room.',
 '2025-11-22 15:00:00'),
(50, 12, 'Transferred to court.',
 '2025-12-10 11:30:00'),
(50, 17, 'Court receipt confirmed.',
 '2025-12-10 14:45:00'),

-- ── Evidence 51–53: Case 15 CLOSED ───────────────────────────────────────
(51, 15, 'Email server logs extracted per court order. Sealed EV-051.',
 '2025-10-15 09:00:00'),
(51, 13, 'Vikram Thapar receives for email header and IP trace analysis.',
 '2025-10-18 10:00:00'),
(51, 15, 'Arjun Malhotra returns to Evidence Room.',
 '2025-10-28 16:00:00'),
(51, 15, 'Transferred to Court Evidence Storage.',
 '2025-11-20 10:00:00'),
(51, 17, 'Exhibit admitted by Judge M. Krishnan.',
 '2025-11-20 14:00:00'),

(52, 15, 'HP laptop seized from CEO office of spoofed company. Sealed EV-052.',
 '2025-10-15 09:30:00'),
(52, 13, 'Vikram Thapar performs forensic imaging.',
 '2025-10-20 10:00:00'),
(52, 15, 'Returned to Evidence Room after analysis.',
 '2025-10-30 15:00:00'),
(52, 15, 'Court transfer.',
 '2025-11-20 10:30:00'),
(52, 17, 'Court receipt confirmed by Judge Krishnan.',
 '2025-11-20 14:15:00'),

(53, 15, 'Wire transfer records obtained from bank. Sealed EV-053.',
 '2025-10-15 10:00:00'),
(53, 16, 'Sunita Yadav receives for financial document forensics.',
 '2025-10-22 10:00:00'),
(53, 15, 'Returned to Evidence Room.',
 '2025-11-01 16:00:00'),
(53, 15, 'Court transfer.',
 '2025-11-20 11:00:00'),
(53, 17, 'Exhibit admitted.',
 '2025-11-20 14:30:00');

-- Recreate the timestamp trigger (now that historical data is loaded)
DELIMITER $$
CREATE TRIGGER trg_custody_force_timestamp
    BEFORE INSERT ON Custody_Log
    FOR EACH ROW
BEGIN
    SET NEW.action_time = NOW();
END$$
DELIMITER ;

-- ============================================================
-- TABLE 5: Forensic_Report
-- ============================================================

INSERT INTO Forensic_Report (evidence_id, analyst_name, report_date) VALUES
-- Case 1
(1,  'Priya Sharma',   '2026-01-20'),
(2,  'Priya Sharma',   '2026-01-22'),
(5,  'Priya Sharma',   '2026-01-25'),
-- Case 2
(3,  'Kavya Nair',     '2026-02-15'),
(7,  'Kavya Nair',     '2026-02-18'),
(8,  'Vikram Thapar',  '2026-02-22'),
(9,  'Kavya Nair',     '2026-02-20'),
-- Case 3
(4,  'Deepika Rao',    '2026-03-12'),
(10, 'Deepika Rao',    '2026-03-15'),
(11, 'Deepika Rao',    '2026-03-18'),
-- Case 4
(13, 'Tanvi Saxena',   '2026-02-05'),
(14, 'Tanvi Saxena',   '2026-02-08'),
(15, 'Tanvi Saxena',   '2026-02-12'),
(16, 'Tanvi Saxena',   '2026-02-10'),
-- Case 5
(17, 'Sunita Yadav',   '2026-02-10'),
(19, 'Sunita Yadav',   '2026-02-15'),
-- Case 6
(21, 'Deepika Rao',    '2026-02-08'),
(23, 'Vikram Thapar',  '2026-02-12'),
(24, 'Deepika Rao',    '2026-02-10'),
-- Case 7
(25, 'Kavya Nair',     '2026-02-18'),
(26, 'Kavya Nair',     '2026-02-20'),
(27, 'Kavya Nair',     '2026-02-22'),
-- Case 8
(28, 'Vikram Thapar',  '2026-02-22'),
(29, 'Vikram Thapar',  '2026-02-25'),
(29, 'Sunita Yadav',   '2026-03-01'),
(30, 'Vikram Thapar',  '2026-02-28'),
-- Case 9
(31, 'Tanvi Saxena',   '2026-03-01'),
(32, 'Sunita Yadav',   '2026-03-05'),
(33, 'Tanvi Saxena',   '2026-03-03'),
-- Case 10
(34, 'Deepika Rao',    '2026-03-10'),
(35, 'Deepika Rao',    '2026-03-08'),
(36, 'Vikram Thapar',  '2026-03-12'),
-- Case 11
(37, 'Kavya Nair',     '2026-03-15'),
(38, 'Deepika Rao',    '2026-03-18'),
(39, 'Kavya Nair',     '2026-03-16'),
-- Case 12
(40, 'Tanvi Saxena',   '2026-03-20'),
(41, 'Sunita Yadav',   '2026-03-22'),
-- Case 13
(43, 'Sunita Yadav',   '2026-04-01'),
(44, 'Vikram Thapar',  '2026-04-05'),
(44, 'Deepika Rao',    '2026-04-08'),
(45, 'Sunita Yadav',   '2026-04-03'),
-- Case 14 (closed)
(47, 'Vikram Thapar',  '2025-11-20'),
(48, 'Vikram Thapar',  '2025-11-22'),
(49, 'Sunita Yadav',   '2025-11-25'),
(50, 'Sunita Yadav',   '2025-11-26'),
-- Case 15 (closed)
(51, 'Vikram Thapar',  '2025-10-30'),
(52, 'Vikram Thapar',  '2025-11-02'),
(53, 'Sunita Yadav',   '2025-11-05');

-- ============================================================
-- TABLE 6: Forensic_Findings_Log  [APPEND-ONLY]
-- NOTE: Trigger trg_findings_force_timestamp overwrites
--       recorded_at with NOW(). Same workaround as Custody_Log.
-- ============================================================

DROP TRIGGER IF EXISTS trg_findings_force_timestamp;

INSERT INTO Forensic_Findings_Log (evidence_id, reported_by, finding_text, recorded_at) VALUES

-- ── Evidence 1: Laptop Dell XPS 15 ────────────────────────────────────────
(1, 3, 'Browser history confirms access to 47 known phishing domains between Oct–Dec 2025. Domains hosted on Russian-registered infrastructure.',
 '2026-01-13 14:00:00'),
(1, 3, 'Keylogger malware (TrickBot variant) found in %AppData% folder. Deployment timestamp: 2025-10-15 03:22 IST. Matches initial phishing email date.',
 '2026-01-14 16:00:00'),
(1, 3, 'Deleted files recovered via Recuva: 12 Excel sheets containing customer PAN and Aadhaar data from 3 banks. Total 22,400 records.',
 '2026-01-18 11:00:00'),

-- ── Evidence 2: USB Drive SanDisk ────────────────────────────────────────
(2, 3, 'USB contains 4 partitions. Partition 3 hidden using VeraCrypt. Brute-force cracked. Contents: 8,200 credit card dumps in Track 1+2 format.',
 '2026-01-15 10:00:00'),
(2, 3, 'Metadata on card dumps indicates they were collected between Aug–Nov 2025 from 3 different ATMs in Ludhiana and Amritsar.',
 '2026-01-16 14:00:00'),

-- ── Evidence 3: Hard Disk WD 1TB ─────────────────────────────────────────
(3, 8, 'Disk image analysis reveals 12,000 patient records exfiltrated. FTP connection logs show transfer to IP 91.213.50.17 (registered: Minsk, Belarus).',
 '2026-02-08 15:00:00'),
(3, 8, 'Database schema matches production schema of hospital management system. Attacker had DBA-level access credentials stored in plaintext config file.',
 '2026-02-10 11:00:00'),
(3, 13, 'Second-opinion analysis by Vikram Thapar confirms data exfiltration. Timestamp correlation shows breach initiated on 2026-01-28 02:17 IST — off-hours access.',
 '2026-02-18 14:00:00'),

-- ── Evidence 4: Server Log Archive ───────────────────────────────────────
(4, 10, 'Log analysis confirms ransomware (LockBit 3.0) initial access via vulnerable RDP port 3389 exposed on electricity SCADA system.',
 '2026-03-04 16:00:00'),
(4, 10, 'Lateral movement detected across 14 internal servers before encryption. C2 server callbacks to domain: update-microsoft-cdn.net (fake domain).',
 '2026-03-06 14:00:00'),
(4, 10, 'Ransom payment demand of 3.2 BTC received via ProtonMail. Wallet address traced to previous LockBit campaign in Germany (Jan 2025).',
 '2026-03-08 11:00:00'),

-- ── Evidence 5: Email Archive ─────────────────────────────────────────────
(3, 3, 'Cross-reference finding: Email PST from case EV-005 contains thread discussing hospital breach — possible accomplice in DataBreach-2026-002 case.',
 '2026-01-24 14:00:00'),
(5, 3, 'PST archive analysis: 3 email accounts used. Headers show message routing through 5 countries. IP anonymisation via Tor exit nodes.',
 '2026-01-20 10:00:00'),
(5, 3, 'Phishing template repository found in Drafts folder — 23 unique templates targeting SBI, HDFC and ICICI customers. Professionally designed.',
 '2026-01-22 11:00:00'),

-- ── Evidence 7: Network PCAP ─────────────────────────────────────────────
(7, 8, 'PCAP analysis confirms data exfiltration: 12GB of encrypted traffic to external IP over 6-hour window on night of breach.',
 '2026-02-08 14:00:00'),
(7, 8, 'Protocol analysis shows attacker used custom exfiltration tool disguised as HTTPS traffic on port 443. Certificate spoofed to mimic Microsoft.',
 '2026-02-12 15:00:00'),
(7, 9, 'SIU note: PCAP IP destination (91.213.50.17) matches IP found in InsiderTheft-2026-006 USB analysis. Possible coordinated attack.',
 '2026-02-11 16:00:00'),
-- NOTE: Finding by officer 9 (Rohit Bansal, SIU) links this to Case 6 — this is
-- the suspicious cross-case finding detectable by query.

-- ── Evidence 8: Database Dump ─────────────────────────────────────────────
(8, 8, 'Database dump confirms 12,000 records compromised. Attacker inserted backdoor stored procedure sp_xp_exec allowing remote command execution.',
 '2026-02-10 11:00:00'),
(8, 13, 'Vikram Thapar confirms backdoor procedure. Analysis of procedure metadata shows it was created using same tool signature as evidence EV-003 attack.',
 '2026-02-18 15:00:00'),

-- ── Evidence 11: Ransom Note ──────────────────────────────────────────────
(11, 10, 'Ransom note language analysis: written by non-native English speaker. Linguistic patterns match Eastern European grammar structures (NLP analysis).',
 '2026-03-05 15:00:00'),
(11, 10, 'Encryption algorithm: AES-256-CBC. Key derivation function: PBKDF2-SHA512. Professional-grade implementation — not script-kiddie level.',
 '2026-03-07 11:00:00'),

-- ── Evidence 12: RAM Dump ─────────────────────────────────────────────────
(12, 10, 'RAM dump analysis reveals encryption keys still in memory — ransomware had not completed key wiping. 3 partial decryption keys recovered.',
 '2026-04-18 14:00:00'),
(12, 10, 'Volatile memory shows attacker had active RDP session from IP 194.165.16.96 at time of dump. Geo-located to Moldova.',
 '2026-04-20 11:00:00'),

-- ── Evidence 13: Phishing Email Headers ──────────────────────────────────
(13, 19, 'Email headers confirm 7 ministry accounts compromised. Spear-phishing emails sent from spoofed nic.in domains. SPF/DKIM deliberately misconfigured.',
 '2026-01-20 14:00:00'),
(13, 19, 'Attacker used open-source phishing kit PhishX-v3 (modified). Kit fingerprint matches 3 previous attacks in 2025 (Rajasthan, Maharashtra, UP).',
 '2026-01-24 11:00:00'),

-- ── Evidence 15: HP EliteBook ─────────────────────────────────────────────
(15, 19, 'OS forensics: 4 VMs running on host — each configured for different phishing campaign. VMware encrypted. Passphrase cracked via dictionary attack.',
 '2026-01-22 14:00:00'),
(15, 19, 'Browser history: suspect visited dark web forum RaidForums (now defunct) mirror daily. Downloaded 3 credential databases in Oct 2025.',
 '2026-01-28 11:00:00'),
(15, 6, 'Financial finding: Laptop used to access 3 crypto exchanges. Transaction history shows conversion of phishing proceeds to Monero (XMR) — privacy coin.',
 '2026-02-01 14:00:00'),

-- ── Evidence 16: iPhone 14 Pro ────────────────────────────────────────────
(16, 19, 'Cellebrite UFED extraction: 2,400 SMS messages. 340 contain OTP codes from banking apps — confirms credential harvesting operation.',
 '2026-01-22 15:00:00'),
(16, 19, 'WhatsApp encrypted backup cracked. Chats confirm ring has 12 members across 4 cities. Codenames used — no real names in conversation.',
 '2026-01-24 14:00:00'),

-- ── Evidence 17: Ledger Cold Wallet ──────────────────────────────────────
(17, 16, 'Ledger wallet contains 47 cryptocurrency addresses. Total balance: 14.7 BTC (approx. Rs 10.3 crore). Funds traced through 3 mixing layers.',
 '2026-01-25 14:00:00'),
(17, 16, 'Transaction graph analysis confirms wallet received funds from 2 known ransomware payment addresses (LockBit, BlackCat). Laundering confirmed.',
 '2026-01-28 11:00:00'),

-- ── Evidence 19: Mining Rig ───────────────────────────────────────────────
(19, 16, 'Mining rig running XMRig (Monero miner). Log files show it has been mining since August 2025 — continuous operation. Estimated earnings: Rs 8 lakh/month.',
 '2026-01-26 14:00:00'),
(19, 16, 'Remote management interface exposed on port 45560. Auth log shows access from 6 different IPs across 3 countries — distributed control.',
 '2026-01-28 14:00:00'),

-- ── Evidence 21: USB Verbatim — Case 6 ───────────────────────────────────
(21, 10, 'USB contains 847 classified documents tagged RESTRICTED and CONFIDENTIAL. Documents date from 2024-2025 fiscal year defence procurement files.',
 '2026-01-26 14:00:00'),
(21, 10, 'File metadata analysis: documents were last modified on a system with hostname CONTRACTOR-PC-073 — matches suspect workstation. Creation timestamps tampered.',
 '2026-01-28 15:00:00'),
(21, 9, 'SIU cross-reference: IP address used to exfiltrate files matches IP found in DataBreach-2026-002 PCAP analysis. SAME ATTACKER infrastructure likely.',
 '2026-01-30 11:00:00'),
-- This finding by Rohit Bansal (SIU) establishes the suspicious cross-case link
-- between Case 2 and Case 6 — detectable via forensic query.

-- ── Evidence 23: Access Card Clone ───────────────────────────────────────
(23, 13, 'PCB contains RFID reader chip (ISO 14443A standard). Firmware modified to capture and replay card credentials. Commercial kit modified by expert.',
 '2026-01-28 14:00:00'),
(23, 13, 'Firmware analysis: device captures Mifare Classic 1K credentials — compatible with the contractor facility access cards. Design is highly specific.',
 '2026-01-30 11:00:00'),

-- ── Evidence 24: CCTV Footage ─────────────────────────────────────────────
(24, 10, 'Frame analysis at 2x speed: suspect identified entering server room 3 times between Nov 2025–Jan 2026 outside authorised hours. Face partially obscured.',
 '2026-01-27 15:00:00'),
(24, 10, 'Metadata confirms footage was not tampered (hash matches original DVR export). Timestamp correlation places suspect at scene during USB data copy window.',
 '2026-01-29 11:00:00'),

-- ── Evidence 25: Seagate Hard Disk — Case 7 ──────────────────────────────
(25, 8, 'PhotoDNA scan confirms presence of CSAM material. 1,247 images flagged. All material encrypted in TrueCrypt container — passphrase cracked.',
 '2026-02-06 14:00:00'),
(25, 8, 'File carving recovered 340 additional deleted images. Metadata shows some files were downloaded from Tor .onion addresses active in 2024.',
 '2026-02-10 11:00:00'),

-- ── Evidence 26: Realme Phone ─────────────────────────────────────────────
(26, 8, 'Cellebrite extraction reveals encrypted messaging apps (Telegram, Session). Session backups extracted — confirm distribution to 4 other users.',
 '2026-02-05 15:00:00'),
(26, 8, 'EXIF data on images confirms device location during transmission — Sector 22, Chandigarh. Matches suspect home address.',
 '2026-02-08 11:00:00'),

-- ── Evidence 27: Tor Config Files ────────────────────────────────────────
(27, 8, 'Tor config customised for hidden service hosting. .onion address matches address found in investigation lead from Interpol (Case Ref: ICPO-CY-2025-887).',
 '2026-02-06 16:00:00'),

-- ── Evidence 28: ATM Skimmer Hardware ────────────────────────────────────
(28, 13, 'PCB circuit analysis: device records Track 2 magnetic stripe data and PIN via GSM module. SIM card IMSI traced to prepaid SIM registered with fake ID.',
 '2026-02-13 14:00:00'),
(28, 13, 'Firmware contains version string: SkimKit-Pro-v2.4. Same version detected in ATM fraud case in Delhi (2025). Likely same supplier.',
 '2026-02-15 11:00:00'),

-- ── Evidence 29: Micro SD Card ───────────────────────────────────────────
(29, 13, 'SD card contains 1,247 credit card dumps (Track 1+2). Data collected over 14-day period. Cards belong to customers of 3 different Punjab banks.',
 '2026-02-13 15:00:00'),
(29, 16, 'Cross-reference by Sunita Yadav: 340 cards on SD also appear in EV-002 USB dump from CyberFraud-2026-001. SAME VICTIM POOL — cases are linked.',
 '2026-02-22 14:00:00'),
-- This finding establishes cross-case evidence link between Case 1 and Case 8.

-- ── Evidence 30: Dell Inspiron Laptop ────────────────────────────────────
(30, 13, 'Browser history: suspect ordered skimmer kits from darknet market Incognito Market. Order history shows 12 units purchased between May–Sep 2025.',
 '2026-02-16 14:00:00'),
(30, 13, 'Telegram chat logs recovered: conversation with alias "SkimMaster" reveals card data sold to 3 buyers in Mumbai, Hyderabad, and Kolkata.',
 '2026-02-18 11:00:00'),

-- ── Evidence 31: VoIP Recording ──────────────────────────────────────────
(31, 19, 'Audio analysis identifies 6 distinct voices across 847 call recordings. Speaker-ID confirms voice 3 matches suspect Harjinder Singh (arrested).',
 '2026-02-18 14:00:00'),
(31, 19, 'Call scripts found in recording metadata folder: 12 scripts targeting different age groups and banks. Professionally written — legal expert involvement suspected.',
 '2026-02-20 11:00:00'),

-- ── Evidence 32: Call Centre DB ──────────────────────────────────────────
(32, 16, 'Database contains 47,000 victim records: name, phone, bank details. Records sourced from 3 data brokers operating on Telegram.',
 '2026-02-18 15:00:00'),
(32, 16, 'Query analysis shows 4,200 records marked as "converted" — confirmed financial victims. Total documented loss: Rs 4.2 crore. Matches FIR amount.',
 '2026-02-20 14:00:00'),

-- ── Evidence 33: OnePlus Phone ────────────────────────────────────────────
(33, 19, 'Cellebrite extraction: suspect has conversation confirming receipt of victim data lists from a contact in Ahmedabad. Cross-state operation.',
 '2026-02-18 16:00:00'),

-- ── Evidence 34: MacBook Pro ─────────────────────────────────────────────
(34, 10, 'Cloud sync artifacts show 340MB of R&D files synced to personal Dropbox account on 2026-01-15. Files include unpublished drug synthesis formulas.',
 '2026-02-22 14:00:00'),
(34, 10, 'Keychain analysis: suspect stored credentials for 3 internal research portals and one external competitor intelligence platform.',
 '2026-02-25 11:00:00'),
(34, 10, 'Timeline analysis confirms data exfiltration occurred on 6 separate occasions between Sep 2025 and Jan 2026 — systematic, not accidental.',
 '2026-02-27 15:00:00'),

-- ── Evidence 35: Cloud Log ZIP ────────────────────────────────────────────
(35, 10, 'Dropbox API logs confirm 340MB upload to account registered under alias. Account email traced to suspect via IP login from company VPN.',
 '2026-02-22 16:00:00'),
(35, 10, 'Files were shared with external email: research@pharmacompetitor.io — domain registered 2 months before exfiltration began. Pre-planned operation.',
 '2026-02-24 14:00:00'),

-- ── Evidence 37: Switch Log — Case 11 ────────────────────────────────────
(37, 8, 'Traffic analysis: DDoS peak volume reached 847 Gbps. Attack vector: amplified DNS and NTP reflection. Botnet of ~12,000 compromised IoT devices.',
 '2026-03-01 14:00:00'),
(37, 8, 'Source IP analysis: 340 attacking IPs traced to compromised home routers running vulnerable Mirai variant. 12 IPs resolved to Indian ISP customers.',
 '2026-03-03 11:00:00'),

-- ── Evidence 38: Botnet VM ────────────────────────────────────────────────
(38, 10, 'VM image contains Mirai botnet C2 panel (web interface). Log of 12,000 infected bot IPs. Attack target list: hospital IPs matches actual DDoS target.',
 '2026-03-02 15:00:00'),
(38, 10, 'C2 admin panel login history: 3 unique operator logins from Tor exit nodes. Panel admin alias "DrDoS" matches alias in CERT-In advisory from 2025.',
 '2026-03-04 14:00:00'),

-- ── Evidence 40: Social Media Export ────────────────────────────────────
(40, 19, 'Bot network analysis: 847 coordinated accounts created within 72-hour window before election. All use same posting template with minor variations.',
 '2026-03-10 14:00:00'),
(40, 19, 'Account registration IPs cluster around 3 data centres (AWS Mumbai, GCP Singapore, Azure Dubai) — automated creation confirmed.',
 '2026-03-12 11:00:00'),

-- ── Evidence 41: Deepfake Videos ─────────────────────────────────────────
(41, 16, 'AI model analysis: deepfake generated using FaceSwap-GAN. Model training data likely sourced from suspect YouTube channel — same artefact pattern.',
 '2026-03-10 15:00:00'),
(41, 16, 'Forensic watermark analysis: original video metadata (GPS, device ID) partially recoverable. Device: iPhone 13 — serial matches phone seized in case.',
 '2026-03-12 14:00:00'),

-- ── Evidence 43: SWIFT Log ────────────────────────────────────────────────
(43, 16, 'SWIFT log analysis: 47 fraudulent MT103 messages sent over 6-day window. Beneficiary accounts in 4 countries: UAE, Hong Kong, Singapore, Cyprus.',
 '2026-03-15 14:00:00'),
(43, 16, 'Correlation finding: SWIFT message authentication codes (MACs) were generated using stolen HSM credentials — insider access suspected.',
 '2026-03-18 11:00:00'),
(43, 6, 'Financial Crime finding: funds from SWIFT fraud partially converted to crypto — same mixing service used in CryptoLaunder-2026-005 (Case 5). CASES LINKED.',
 '2026-03-25 14:00:00'),
-- This finding by Neha Kapoor links Case 13 (BankFraud) to Case 5 (CryptoLaunder).

-- ── Evidence 44: Banking Malware Sample ──────────────────────────────────
(44, 13, 'Malware is a custom SWIFT-targeting implant named "BankerBot-NG". Static analysis reveals 3 modules: credential harvester, SWIFT message injector, log cleaner.',
 '2026-03-16 14:00:00'),
(44, 13, 'Code similarity analysis: 67% code overlap with malware used in Bangladesh Bank SWIFT heist (2016 variant, updated). Nation-state tool reuse suspected.',
 '2026-03-18 15:00:00'),
(44, 10, 'Second opinion: Deepika Rao confirms code similarity finding. Adds: C2 beacon interval matches LockBit 3.0 config from Case 3 (Ransomware-2026-003).',
 '2026-04-10 14:00:00'),
-- This finding links Case 13 malware to Case 3 ransomware infrastructure.

-- ── Evidence 47–50: Case 14 CLOSED ───────────────────────────────────────
(47, 13, 'Printer firmware modified to produce documents with micro-perforations identical to genuine Aadhaar card stock. Sourced from underground market.',
 '2025-11-10 14:00:00'),
(48, 13, 'Laptop image contains design files for 12 Aadhaar and 8 PAN card templates. Photoshop layers show incremental design refinement — ongoing operation.',
 '2025-11-15 11:00:00'),
(49, 16, 'Database dump contains 12,000 SIM registrations linked to fake IDs. Cross-reference with TRAI database confirms all SIMs have been deactivated.',
 '2025-11-20 14:00:00'),
(50, 16, 'Cellebrite extraction reveals communication with 3 SIM card vendors and 1 Aadhaar enrollment operator (since arrested). Conspiracy fully mapped.',
 '2025-11-22 11:00:00'),

-- ── Evidence 51–53: Case 15 CLOSED ───────────────────────────────────────
(51, 13, 'Email header analysis confirms spoofed domain was registered 3 hours before first fraudulent email sent. Registrant used stolen payment card.',
 '2025-10-22 14:00:00'),
(52, 13, 'Laptop contains spear-phishing email templates targeting 22 different companies. Personalised with publicly available LinkedIn data — OSINT-based attack.',
 '2025-10-25 11:00:00'),
(53, 16, 'Wire transfer analysis: Rs 2.8 crore moved across 7 mule accounts in 4 banks within 90 minutes — rapid dispersion to prevent tracing.',
 '2025-10-28 14:00:00');

-- Recreate the findings timestamp trigger
DELIMITER $$
CREATE TRIGGER trg_findings_force_timestamp
    BEFORE INSERT ON Forensic_Findings_Log
    FOR EACH ROW
BEGIN
    SET NEW.recorded_at = NOW();
END$$
DELIMITER ;

-- Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- ADDITIONAL FORENSIC REPORTS (to reach 120+ total)
-- ============================================================

INSERT INTO Forensic_Report (evidence_id, analyst_name, report_date) VALUES
-- Additional reports on evidence items that needed supplemental analysis
(1,  'Vikram Thapar',  '2026-01-28'),  -- second opinion on EV-001 laptop
(2,  'Vikram Thapar',  '2026-01-25'),  -- second opinion on USB
(4,  'Vikram Thapar',  '2026-03-20'),  -- supplemental ransomware report
(5,  'Kavya Nair',     '2026-01-26'),  -- email archive additional analysis
(6,  'Priya Sharma',   '2026-01-30'),  -- mobile phone report
(7,  'Vikram Thapar',  '2026-02-25'),  -- PCAP second opinion
(10, 'Vikram Thapar',  '2026-03-20'),  -- firewall log additional
(11, 'Vikram Thapar',  '2026-03-25'),  -- ransom note second opinion
(12, 'Vikram Thapar',  '2026-04-22'),  -- RAM dump supplemental
(16, 'Priya Sharma',   '2026-02-12'),  -- iPhone additional
(17, 'Kavya Nair',     '2026-02-12'),  -- cold wallet second opinion
(18, 'Sunita Yadav',   '2026-02-05'),  -- blockchain export
(20, 'Kavya Nair',     '2026-02-10'),  -- SSD preliminary
(21, 'Vikram Thapar',  '2026-02-15'),  -- USB second opinion
(22, 'Kavya Nair',     '2026-02-20'),  -- Lenovo laptop
(24, 'Vikram Thapar',  '2026-02-15'),  -- CCTV supplemental
(25, 'Vikram Thapar',  '2026-02-25'),  -- second opinion on CSAM disk
(27, 'Priya Sharma',   '2026-02-26'),  -- Tor config
(29, 'Kavya Nair',     '2026-03-05'),  -- micro SD additional
(31, 'Kavya Nair',     '2026-03-10'),  -- VoIP audio additional
(33, 'Kavya Nair',     '2026-03-08'),  -- OnePlus supplemental
(34, 'Vikram Thapar',  '2026-03-15'),  -- MacBook supplemental
(36, 'Deepika Rao',    '2026-03-15'),  -- WD Passport additional
(37, 'Deepika Rao',    '2026-03-20'),  -- switch log second opinion
(38, 'Kavya Nair',     '2026-03-22'),  -- botnet VM supplemental
(40, 'Sunita Yadav',   '2026-03-25'),  -- social media supplemental
(41, 'Tanvi Saxena',   '2026-03-26'),  -- deepfake additional
(42, 'Sunita Yadav',   '2026-03-15'),  -- Xiaomi phone report
(43, 'Kavya Nair',     '2026-04-10'),  -- SWIFT log additional
(44, 'Kavya Nair',     '2026-04-15'),  -- malware third opinion
(45, 'Deepika Rao',    '2026-04-08'),  -- server log additional
(46, 'Tanvi Saxena',   '2026-04-12'),  -- USB additional
(47, 'Sunita Yadav',   '2025-11-25'),  -- printer device second
(48, 'Kavya Nair',     '2025-11-28'),  -- Acer laptop additional
(50, 'Vikram Thapar',  '2025-11-30'),  -- Oppo phone additional
(51, 'Kavya Nair',     '2025-11-05'),  -- email server logs additional
(52, 'Sunita Yadav',   '2025-11-08'),  -- HP laptop supplemental
(9,  'Tanvi Saxena',   '2026-02-25'),  -- Kingston USB supplemental
(15, 'Kavya Nair',     '2026-02-20'),  -- HP EliteBook supplemental
(19, 'Kavya Nair',     '2026-02-10'),  -- mining rig additional
(23, 'Kavya Nair',     '2026-02-15'),  -- access card additional
(26, 'Priya Sharma',   '2026-02-25'),  -- Realme phone additional
(28, 'Deepika Rao',    '2026-02-28'),  -- skimmer hardware additional
(30, 'Deepika Rao',    '2026-03-05'),  -- Dell laptop additional
(32, 'Tanvi Saxena',   '2026-03-10'),  -- call centre DB additional
(35, 'Vikram Thapar',  '2026-03-12'),  -- cloud log additional
(39, 'Deepika Rao',    '2026-03-20'),  -- router config additional
(53, 'Kavya Nair',     '2025-11-10'),  -- wire transfer records additional
(13, 'Kavya Nair',     '2026-02-15'),  -- phishing emails supplemental
(14, 'Priya Sharma',   '2026-02-20');  -- domain records supplemental

-- ============================================================
-- ADDITIONAL FORENSIC FINDINGS (to reach 120+ total)
-- ============================================================

DROP TRIGGER IF EXISTS trg_findings_force_timestamp;

INSERT INTO Forensic_Findings_Log (evidence_id, reported_by, finding_text, recorded_at) VALUES

-- Additional findings expanding on initial analysis
(1, 13, 'Second-opinion analysis by Vikram Thapar: TrickBot malware communicates with 3 C2 servers — all previously attributed to TA505 threat actor group (Europol 2024 report).',
 '2026-01-28 14:00:00'),
(2, 13, 'Second opinion: USB file allocation table confirms files were written using a write-blocker bypass tool — attacker had forensic-grade equipment.',
 '2026-01-25 14:00:00'),
(3, 13, 'SHA-256 hash of 12,000-record dump matches hash on darkweb forum post dated 3 days after breach — data was immediately monetised.',
 '2026-02-20 11:00:00'),
(4, 13, 'Supplemental analysis: ransomware binary signed with stolen certificate issued to "Contoso Tech Solutions" — certificate revoked Nov 2025.',
 '2026-03-22 14:00:00'),
(5, 8, 'Email archive cross-analysis: 3 IP addresses in headers also appear in network PCAP of Case 2 (DataBreach). Possible infrastructure reuse.',
 '2026-01-28 14:00:00'),
(6, 3, 'Mobile phone extraction: suspect communicated with 2 numbers that appear in call records of InsiderTheft-2026-006 case. Cross-case link established.',
 '2026-01-30 14:00:00'),
(7, 13, 'Supplemental PCAP analysis: exfiltration volume (12GB) over 6 hours corresponds precisely to database dump size (EV-008) — confirms deliberate targeted extraction.',
 '2026-02-25 14:00:00'),
(9, 19, 'USB analysis: Kingston USB contains a portable Kali Linux installation with pre-configured exploitation tools: Metasploit, SQLmap, Hydra.',
 '2026-02-20 14:00:00'),
(10, 13, 'Supplemental: Firewall logs show 3 reconnaissance scans from same IP 12 days before ransomware deployment — 12-day dwell time confirmed.',
 '2026-03-22 14:00:00'),
(11, 13, 'Second opinion on ransom note: embedded Bitcoin wallet address has 0 received transactions — no payment was made. Victim successfully restored from backup.',
 '2026-03-26 11:00:00'),
(12, 5, 'Officer review note: 45-day gap before RAM analysis is concerning — volatile evidence value may have degraded. Chain-of-custody irregularity flagged.',
 '2026-05-01 14:00:00'),
(13, 6, 'Financial cross-finding: IP address used to send phishing emails also accessed banking portal of one victim — attacker directly harvested and used credentials.',
 '2026-01-28 14:00:00'),
(14, 19, 'Domain registration analysis: 3 out of 7 spoofed domains used the same hosting provider and registrar, paid via prepaid card traced to Delhi purchase.',
 '2026-01-22 14:00:00'),
(15, 6, 'Financial finding update: 3 crypto exchange accounts confirmed linked to physical wallet (EV-017) in CryptoLaunder-2026-005 — cases financially connected.',
 '2026-02-05 11:00:00'),
(16, 3, 'Supplemental mobile analysis: iCloud backup downloaded — contains additional deleted WhatsApp messages confirming 2 more accomplices in different cities.',
 '2026-02-15 14:00:00'),
(17, 16, 'Updated wallet tracing: 2 BTC transferred out to exchange after device seizure — suspect has a remote access mechanism. Court order for exchange freeze filed.',
 '2026-01-30 14:00:00'),
(18, 16, 'Blockchain export analysis (delayed): 847 transactions in export. 12 transactions directly traceable to ransomware victim payment addresses from 2025.',
 '2026-02-15 14:00:00'),
(19, 16, 'Mining pool analysis: rig was member of pool "xmrpool.eu" under alias "minedge99". Pool records show 22 months of continuous mining — operation pre-dates FIR.',
 '2026-01-30 14:00:00'),
(20, 16, 'SSD preliminary analysis: drive contains encrypted volume (VeraCrypt). Size: 1.8TB. Password cracking in progress — GPU cluster engaged.',
 '2026-02-10 14:00:00'),
(21, 13, 'Second opinion: file creation timestamps on classified docs show batch copy operation at 02:30 AM on 3 separate nights — systematic, not opportunistic.',
 '2026-02-12 14:00:00'),
(22, 8, 'Laptop preliminary analysis (delayed): device never formally analysed. Found browsing history shows access to competitor intelligence forum from contractor network.',
 '2026-02-20 14:00:00'),
(23, 8, 'Access card clone device hardware supplement: SIM IMSI on device belongs to a SIM batch from IdentityFraud-2025-014 (Case 14) — SIM cards reused.',
 '2026-02-18 14:00:00'),
-- Finding above links Case 6 to Case 14 (identity fraud SIM cards).
(24, 13, 'CCTV supplemental: facial recognition software (70% confidence) matches suspect face against passport photo. Cross-referenced with biometric DB.',
 '2026-02-16 14:00:00'),
(25, 13, 'Second opinion confirms PhotoDNA results. Additionally: 47 images contain GPS metadata placing them in specific residential area of Sector 34, Chandigarh.',
 '2026-02-25 14:00:00'),
(26, 3, 'Cellebrite supplemental: app notification data recovered shows suspect received 240 file-sharing notifications from 4 different users over 6 months.',
 '2026-02-25 14:00:00'),
(27, 3, 'Tor config note: hidden service private key recovered from config. OPSEC failure — .onion address can now be traced and shut down via Tor Project cooperation request.',
 '2026-02-28 11:00:00'),
(28, 10, 'Hardware supplement: GSM module inside skimmer registered to Tower ID in sector overlapping with 3 known crime locations — physical proximity confirmed.',
 '2026-02-20 14:00:00'),
(29, 8, 'Additional card analysis: 87 of 1,247 cards on SD are premium/corporate cards — attacker specifically targeted high-value cardholders by bank identification number.',
 '2026-02-28 14:00:00'),
(30, 10, 'Laptop supplement: browser cache shows suspect viewed YouTube tutorials on ATM skimmer assembly 3 months before first skimmer placement. Premeditation confirmed.',
 '2026-03-08 14:00:00'),
(31, 8, 'VoIP additional analysis: background noise analysis identifies office fan hum consistent with an open-plan call centre. Acoustic profile narrows location search.',
 '2026-02-25 14:00:00'),
(32, 8, 'Database supplement: victim records include 340 deceased individuals — fraudulent entries created by accomplice with access to govt death registry database.',
 '2026-02-25 14:00:00'),
(33, 8, 'OnePlus supplemental: call logs show 12 calls to numbers traced to Ahmedabad boiler room — confirms multi-city operation with centralised data source.',
 '2026-02-22 14:00:00'),
(34, 13, 'MacBook supplement: Keychain contained API key for competitor intelligence platform — competitor company may be complicit or victim of secondary breach.',
 '2026-03-15 14:00:00'),
(35, 13, 'Cloud log supplement: Dropbox account was accessed from 3 different countries on same day files were shared — possible cloud account compromise by third party.',
 '2026-03-15 14:00:00'),
(36, 10, 'WD Passport supplement: device contains backup of MacBook (EV-034). 2 additional R&D files found in backup not present on original laptop — prior exfiltration.',
 '2026-03-18 14:00:00'),
(37, 10, 'Switch log supplement: 3 management interface logins using default credentials (admin/admin) detected 2 weeks before DDoS — initial access via misconfiguration.',
 '2026-03-22 14:00:00'),
(38, 8, 'Botnet VM supplement: C2 panel contains a "kill switch" module that can disable all bots simultaneously. Activation would destroy evidence — court order for preservation.',
 '2026-03-25 14:00:00'),
(39, 10, 'Router config supplement: default SNMP community string "public" was enabled — attacker used SNMP to monitor hospital network traffic without detection for 6 days.',
 '2026-03-24 14:00:00'),
(40, 8, 'Social media supplement: 12 accounts trace back to political consulting firm via common API key used in registration scripts. Commissioned disinformation suspected.',
 '2026-03-18 14:00:00'),
(41, 19, 'Deepfake supplement: GAN model weights found in suspect cloud storage — suspect created deepfakes locally, not via third-party service. Technical expertise confirmed.',
 '2026-03-18 14:00:00'),
(42, 8, 'Xiaomi supplement: device contains Python script for automated social media posting with random delays — confirms bot-assisted amplification of human-created content.',
 '2026-03-15 14:00:00'),
(43, 10, 'SWIFT supplemental: 3 of 47 fraudulent transfers were reversed by receiving banks within 24 hours — Rs 3.2 crore of the Rs 18 crore partially recovered.',
 '2026-04-15 14:00:00'),
(44, 8, 'Malware third opinion: Kavya Nair confirms — malware uses same encryption key derivation as Case 3 (Ransomware) payload. Single threat actor behind both attacks.',
 '2026-04-18 14:00:00'),
-- This finding by Kavya definitively links Case 3 and Case 13 to single actor.
(45, 10, 'Server log supplement: attacker accessed SWIFT system 11 days before first fraudulent transfer — 11-day dwell time used to study transaction patterns.',
 '2026-04-10 14:00:00'),
(46, 19, 'USB supplement: device contains AutoRun script that executed malware automatically when inserted — confirms this was the initial infection vector for banking system.',
 '2026-04-15 14:00:00'),
(47, 16, 'Printer device supplement: hidden compartment in printer base contained 340 blank Aadhaar card stock sheets sourced from govt printing press (supply chain breach).',
 '2025-11-25 14:00:00'),
(48, 8, 'Acer laptop supplement: Photoshop file versioning shows 47 iterations of Aadhaar template — 18-month design refinement. Operation pre-dates case registration by 14 months.',
 '2025-11-28 14:00:00'),
(49, 13, 'SIM database supplement: cross-reference with telecom CDR confirms SIMs used in SocialEngr-2026-009 (Case 9) call centre operation. Cases 9 and 14 linked.',
 '2025-11-28 14:00:00'),
-- Finding above links Case 14 to Case 9.
(50, 13, 'Oppo phone supplement: contact list contains number of individual arrested in EmailSpoofing-2025-015 (Case 15). Identity fraud and email spoofing networks connected.',
 '2025-11-30 14:00:00'),
-- This links Case 14 and Case 15 via shared contact.
(51, 8, 'Email server log supplement: spoofed domain used same email infrastructure (same MX records) as phishing domains in CyberFraud-2026-001 (Case 1). Network overlap.',
 '2025-10-28 14:00:00'),
(52, 8, 'HP laptop supplement: suspect had automated script that scraped LinkedIn to build targeted victim lists — 340 companies profiled over 3 months.',
 '2025-11-05 14:00:00'),
(53, 13, 'Wire transfer supplement: 2 of 7 mule accounts are also listed in SocialEngr-2026-009 (Case 9) victim database — mule accounts shared across crime networks.',
 '2025-11-08 14:00:00');

-- Recreate findings trigger after final batch
DELIMITER $$
CREATE TRIGGER trg_findings_force_timestamp
    BEFORE INSERT ON Forensic_Findings_Log
    FOR EACH ROW
BEGIN
    SET NEW.recorded_at = NOW();
END$$
DELIMITER ;

-- ============================================================
-- RECORD COUNTS (run these to verify)
-- ============================================================
-- SELECT 'Case_Details'          AS tbl, COUNT(*) AS total FROM Case_Details    UNION ALL
-- SELECT 'Officer',                        COUNT(*)         FROM Officer          UNION ALL
-- SELECT 'Evidence',                       COUNT(*)         FROM Evidence         UNION ALL
-- SELECT 'Storage',                        COUNT(*)         FROM Storage          UNION ALL
-- SELECT 'Custody_Log',                    COUNT(*)         FROM Custody_Log      UNION ALL
-- SELECT 'Forensic_Report',                COUNT(*)         FROM Forensic_Report  UNION ALL
-- SELECT 'Forensic_Findings_Log',          COUNT(*)         FROM Forensic_Findings_Log;

-- ============================================================
-- INTERESTING QUERY DEMOS
-- (Uncomment and run individually to showcase findings)
-- ============================================================

-- 1. Common evidence TYPE between two cases (e.g. USB Drives across cases)
-- SELECT DISTINCT e1.type, e1.case_id AS case_A, e2.case_id AS case_B
-- FROM Evidence e1 JOIN Evidence e2
--   ON e1.type LIKE CONCAT('%', SUBSTRING_INDEX(e2.type,' ',2), '%')
--   AND e1.case_id < e2.case_id
-- WHERE e1.type LIKE '%USB%' OR e1.type LIKE '%Laptop%' OR e1.type LIKE '%Server Log%';

-- 2. Officers who worked on BOTH Case 1 (CyberFraud) AND Case 13 (BankFraud)
-- SELECT DISTINCT o.officer_id, o.name, o.department
-- FROM Custody_Log cl1
-- JOIN Custody_Log cl2 ON cl1.officer_id = cl2.officer_id
-- JOIN Evidence e1 ON cl1.evidence_id = e1.evidence_id AND e1.case_id = 1
-- JOIN Evidence e2 ON cl2.evidence_id = e2.evidence_id AND e2.case_id = 13
-- JOIN Officer o ON cl1.officer_id = o.officer_id;

-- 3. Evidence with forensic findings linking to another case
-- SELECT ffl.finding_id, e.evidence_id, cd.case_title, ffl.finding_text, o.name AS analyst
-- FROM Forensic_Findings_Log ffl
-- JOIN Evidence e ON ffl.evidence_id = e.evidence_id
-- JOIN Case_Details cd ON e.case_id = cd.case_id
-- JOIN Officer o ON ffl.reported_by = o.officer_id
-- WHERE ffl.finding_text LIKE '%Case%' OR ffl.finding_text LIKE '%linked%' OR ffl.finding_text LIKE '%matches%';

-- 4. Crime scenes sharing common evidence type (Laptop)
-- SELECT e.type, GROUP_CONCAT(DISTINCT cd.case_title ORDER BY cd.case_id SEPARATOR ' | ') AS linked_cases
-- FROM Evidence e
-- JOIN Case_Details cd ON e.case_id = cd.case_id
-- WHERE e.type LIKE '%Laptop%'
-- GROUP BY e.type
-- HAVING COUNT(DISTINCT e.case_id) > 1;

-- 5. Idle evidence (no custody update in last 60+ days relative to latest date)
-- SELECT e.evidence_id, e.type, cd.case_title, MAX(cl.action_time) AS last_action,
--        DATEDIFF(NOW(), MAX(cl.action_time)) AS days_idle
-- FROM Evidence e
-- JOIN Case_Details cd ON e.case_id = cd.case_id
-- JOIN Custody_Log cl ON e.evidence_id = cl.evidence_id
-- GROUP BY e.evidence_id, e.type, cd.case_title
-- HAVING days_idle > 60
-- ORDER BY days_idle DESC;

-- 6. Suspicious cases linked by same officers
-- SELECT o.officer_id, o.name, o.department,
--        GROUP_CONCAT(DISTINCT cd.case_title ORDER BY cd.case_id SEPARATOR ' | ') AS cases_handled,
--        COUNT(DISTINCT e.case_id) AS case_count
-- FROM Custody_Log cl
-- JOIN Evidence e ON cl.evidence_id = e.evidence_id
-- JOIN Case_Details cd ON e.case_id = cd.case_id
-- JOIN Officer o ON cl.officer_id = o.officer_id
-- GROUP BY o.officer_id, o.name, o.department
-- HAVING case_count > 2
-- ORDER BY case_count DESC;

-- 7. Evidence collected but never Presented to court
-- SELECT e.evidence_id, e.type, e.status, cd.case_title, cd.status AS case_status
-- FROM Evidence e
-- JOIN Case_Details cd ON e.case_id = cd.case_id
-- WHERE e.status != 'Presented'
--   AND cd.status = 'Closed';

-- 8. Evidence with too many custody transfers (suspicious churn)
-- SELECT e.evidence_id, e.type, cd.case_title, COUNT(cl.log_id) AS transfer_count
-- FROM Evidence e
-- JOIN Case_Details cd ON e.case_id = cd.case_id
-- JOIN Custody_Log cl ON e.evidence_id = cl.evidence_id
-- GROUP BY e.evidence_id, e.type, cd.case_title
-- HAVING transfer_count > 5
-- ORDER BY transfer_count DESC;

-- 9. Evidence with large time gaps between consecutive transfers
-- SELECT e.evidence_id, e.type,
--        cl1.action_time AS transfer_1, cl2.action_time AS transfer_2,
--        DATEDIFF(cl2.action_time, cl1.action_time) AS gap_days
-- FROM Custody_Log cl1
-- JOIN Custody_Log cl2 ON cl1.evidence_id = cl2.evidence_id AND cl2.log_id = (
--     SELECT MIN(log_id) FROM Custody_Log WHERE evidence_id = cl1.evidence_id AND log_id > cl1.log_id
-- )
-- JOIN Evidence e ON cl1.evidence_id = e.evidence_id
-- HAVING gap_days > 30
-- ORDER BY gap_days DESC;

-- 10. Same evidence handled repeatedly by same officer (suspicious)
-- SELECT cl.evidence_id, e.type, cl.officer_id, o.name AS officer_name,
--        COUNT(*) AS times_handled
-- FROM Custody_Log cl
-- JOIN Evidence e ON cl.evidence_id = e.evidence_id
-- JOIN Officer o ON cl.officer_id = o.officer_id
-- GROUP BY cl.evidence_id, cl.officer_id
-- HAVING times_handled >= 3
-- ORDER BY times_handled DESC;
