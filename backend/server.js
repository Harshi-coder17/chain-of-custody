const express = require('express');
const app = express();

app.get('/api/ping', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(5000, () => console.log("Server running"));