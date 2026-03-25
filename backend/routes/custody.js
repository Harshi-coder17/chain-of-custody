const router = require('express').Router();
const db = require('../db');
const { authenticate, requireRole } = require('../auth');

// GET custody history for an evidence item
router.get('/evidence/:id', authenticate, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT cl.log_id,
              cl.evidence_id,
              cl.action,
              cl.action_time,
              o.name AS officer_name,
              o.rank AS officer_rank
       FROM Custody_Log cl
       JOIN Officer o ON cl.officer_id = o.officer_id
       WHERE cl.evidence_id = ?
       ORDER BY cl.action_time ASC`,
      [req.params.id]
    );

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST custody transfer — calls stored procedure
router.post(
  '/transfer',
  authenticate,
  requireRole('admin', 'officer'),
  async (req, res) => {
    const { evidence_id, officer_id, action, new_status } = req.body;

    if (!evidence_id || !officer_id || !action || !new_status) {
      return res.status(400).json({
        error: 'All fields are required.'
      });
    }

    try {
      await db.query(
        `CALL TransferCustody(?, ?, ?, ?)`,
        [evidence_id, officer_id, action, new_status]
      );

      res.json({ message: "Custody transferred successfully." });

    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// GET Court_View — judicial and admin only
router.get(
  '/court-view',
  authenticate,
  requireRole('admin', 'judicial'),
  async (req, res) => {
    try {
      const [rows] = await db.query(`SELECT * FROM Court_View`);
      res.json(rows);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// GET Audit_View — judicial and admin only
router.get(
  '/audit-view',
  authenticate,
  requireRole('admin', 'judicial'),
  async (req, res) => {
    try {
      const [rows] = await db.query(`SELECT * FROM Audit_View`);
      res.json(rows);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

module.exports = router;