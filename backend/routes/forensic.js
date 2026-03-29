const router = require('express').Router();
const db = require('../db');
const { authenticate, requireRole } = require('../auth');

// GET findings for an evidence item — all roles
router.get('/findings/:evidenceId', authenticate, async (req, res) => {
 try {
 const [rows] = await db.query(
 `SELECT ffl.finding_id,
 ffl.finding_text,
ffl.recorded_at,
o.name AS reporter_name,
 o.rank AS reporter_rank
 FROM Forensic_Findings_Log ffl
 JOIN Officer o ON ffl.reported_by = o.officer_id
 WHERE ffl.evidence_id = ?
 ORDER BY ffl.recorded_at ASC`,
 [req.params.evidenceId]
 );
 res.json(rows);
 } catch (err) { res.status(500).json({ error: err.message }); }
});

// POST append finding — analyst and admin only — calls procedure
router.post('/findings', authenticate, requireRole('admin', 'analyst'), async (req,
res) => {
 const { evidence_id, finding_text } = req.body;
 const reported_by = req.user.id; // from JWT token — cannot be spoofed
 if (!evidence_id || !finding_text)
 return res.status(400).json({ error: 'evidence_id and finding_text are required.' });
 try {
 await db.query(
 `CALL AppendForensicFinding(?, ?, ?)`,
 [evidence_id, reported_by, finding_text]
 );
 res.status(201).json({ message: "Finding appended successfully." });
 } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;