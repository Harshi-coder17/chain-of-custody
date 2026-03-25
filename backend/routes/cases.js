const router = require('express').Router();
const db = require('../db');
const { authenticate, requireRole } = require('../auth');

// GET all cases — all authenticated roles
router.get('/', authenticate, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT * FROM Case_Details ORDER BY start_date DESC`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET single case
router.get('/:id', authenticate, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT * FROM Case_Details WHERE case_id = ?`,
      [req.params.id]
    );

    if (!rows.length) {
      return res.status(404).json({ error: 'Case not found.' });
    }

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST new case — admin and officer only
router.post(
  '/',
  authenticate,
  requireRole('admin', 'officer'),
  async (req, res) => {
    const { case_title, description, start_date, status } = req.body;

    if (!case_title || !start_date) {
      return res.status(400).json({
        error: 'case_title and start_date are required.'
      });
    }

    try {
      const [result] = await db.query(
        `INSERT INTO Case_Details (case_title, description, start_date, status)
         VALUES (?, ?, ?, ?)`,
        [case_title, description || '', start_date, status || 'Open']
      );

      res.status(201).json({
        case_id: result.insertId,
        message: "Case created."
      });

    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

module.exports = router;