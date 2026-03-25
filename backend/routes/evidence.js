const express = require('express');
const router = express.Router();
const db = require('../db'); // adjust if your path differs

//  Create Evidence
router.post('/', async (req, res) => {
    try {
        const { case_id, type, hash_value } = req.body;

        if (!case_id || !type || !hash_value) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const [result] = await db.execute(
            `INSERT INTO Evidence (case_id, type, hash_value)
             VALUES (?, ?, ?)`,
            [case_id, type, hash_value]
        );

        res.status(201).json({
            message: 'Evidence created successfully',
            evidence_id: result.insertId
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


//  Get All Evidence
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.execute(`
            SELECT e.*, c.case_title
            FROM Evidence e
            JOIN Case_Details c ON e.case_id = c.case_id
            ORDER BY e.evidence_id DESC
        `);

        res.json(rows);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


//  Get Evidence by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const [rows] = await db.execute(
            `SELECT * FROM Evidence WHERE evidence_id = ?`,
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Evidence not found' });
        }

        res.json(rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;