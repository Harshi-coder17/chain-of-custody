const router = require('express').Router();
const bcrypt = require('bcryptjs');
const db = require('../db');
const { generateToken } = require('../auth');

router.post('/login', async (req, res) => {
  console.log("LOGIN ROUTE HIT");   // 👈 ADD THIS LINE HERE

  const { officer_id, password } = req.body;


  if (!officer_id || !password)
    return res.status(400).json({ error: 'officer_id and password are required.' });

  try {
    const [rows] = await db.query(
      'SELECT * FROM Officer WHERE officer_id = ?',
      [officer_id]
    );

    if (rows.length === 0)
      return res.status(401).json({ error: 'Invalid credentials.' });

    const officer = rows[0];

console.log("Entered password:", password);
console.log("Stored hash:", officer.password_hash);

const valid = await bcrypt.compare(password, officer.password_hash);

console.log("Match result:", valid);

    if (!valid)
      return res.status(401).json({ error: 'Invalid credentials.' });

    const token = generateToken(officer);

    res.json({
      token,
      role: officer.role,
      name: officer.name,
      officer_id: officer.officer_id,
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;