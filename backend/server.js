const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors({ origin: 'http://localhost:5173', credentials: true }));
app.use(express.json());

// ── Import routes (NEW - important fix) ───────────
const authRoutes = require('./routes/auth');
const caseRoutes = require('./routes/cases');
const evidenceRoutes = require('./routes/evidence');
const custodyRoutes = require('./routes/custody');
const forensicRoutes = require('./routes/forensic');
const officerRoutes = require('./routes/officers');

// 🔍 Debug (temporary - helps find error)
console.log('auth:', typeof authRoutes);
console.log('cases:', typeof caseRoutes);
console.log('evidence:', typeof evidenceRoutes);
console.log('custody:', typeof custodyRoutes);
console.log('forensic:', typeof forensicRoutes);
console.log('officers:', typeof officerRoutes);

// ── Health check ─────────────────────────────────
app.get('/api/ping', (req, res) => res.json({ status: 'ok' }));

// ── Route mounting (same logic, just using variables) ──
app.use('/api/auth', authRoutes);
app.use('/api/cases', caseRoutes);
app.use('/api/evidence', evidenceRoutes);
app.use('/api/custody', custodyRoutes);
app.use('/api/forensic', forensicRoutes);
app.use('/api/officers', officerRoutes);

// ── Start server ─────────────────────────
const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
  console.log(`Chain-of-Custody API running on port ${PORT}`);
});