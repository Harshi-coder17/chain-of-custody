const express = require('express');
const router = express.Router();
const db = require('../db');


//  Create Officer
router.post('/', async (req, res) => {
    try {
        const { name, rank_name, department, password_hash } = req.body;

        if (!name || !rank_name || !department || !password_hash) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const [result] = await db.execute(
            `INSERT INTO Officer (name, rank_name, department, password_hash)
             VALUES (?, ?, ?, ?)`,
            [name, rank_name, department, password_hash]
        );

        res.status(201).json({
            message: 'Officer created successfully',
            officer_id: result.insertId
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


//  Get All Officers
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.execute(`
            SELECT officer_id, name, rank_name, department
            FROM Officer
            ORDER BY officer_id DESC
        `);

        res.json(rows);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


//  Get Officer by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const [rows] = await db.execute(
            `SELECT officer_id, name, rank_name, department
             FROM Officer WHERE officer_id = ?`,
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Officer not found' });
        }

        res.json(rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;