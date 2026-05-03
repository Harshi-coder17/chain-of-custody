require('dotenv').config();
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors({ origin: ['http://localhost:5173','http://localhost:5174'],
   credentials: true }));
app.use(express.json());

app.use((req, res, next) => {
  console.log("Incoming:", req.method, req.url);
  next();
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/cases', require('./routes/cases'));
app.use('/api/evidence', require('./routes/evidence'));
app.use('/api/custody', require('./routes/custody'));
app.use('/api/forensic', require('./routes/forensic'));
app.use('/api/officers', require('./routes/officers'));

// Health check
app.get('/api/ping', (req, res) => res.json({ status: 'ok' }));


app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong' });
});

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Chain-of-Custody API running on port ${PORT}`);
});