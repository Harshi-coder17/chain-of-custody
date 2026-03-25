const express = require('express');
const cors = require('cors');
require('dotenv').config();
const app = express();
app.use(cors({ origin: 'http://localhost:5173', credentials: true }));
app.use(express.json());
// ── Route mounting ────────────────────────────────
app.use('/api/auth', require('./routes/auth'));
app.use('/api/cases', require('./routes/cases'));
app.use('/api/evidence', require('./routes/evidence'));
app.use('/api/custody', require('./routes/custody'));
app.use('/api/forensic', require('./routes/forensic'));
app.use('/api/officers', require('./routes/officers'));
// ── Health check ─────────────────────────────────
app.get('/api/ping', (req, res) => res.json({ status: 'ok' }));
// ── Global error handler ─────────────────────────
// eslint-disable-next-line no-unused-vars
// Catches unhandled errors and returns clean JSON
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
console.log(`Chain-of-Custody API running on port ${PORT}`);
});