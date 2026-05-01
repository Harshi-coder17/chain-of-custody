const jwt = require('jsonwebtoken');

// Generate token
function generateToken(officer) {
  return jwt.sign(
    {
      id: officer.officer_id,
      role: officer.role,
      name: officer.name,
    },
    process.env.JWT_SECRET,
    { expiresIn: '8h' }
  );
}

// Authenticate middleware
function authenticate(req, res, next) {
  const header = req.headers['authorization'];
  const token = header && header.split(' ')[1];

  if (!token) return res.status(401).json({ error: 'Authentication required.' });

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token invalid or expired.' });
  }
}

// Role middleware
function requireRole(...roles) {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Access denied: insufficient role.' });
    }
    next();
  };
}

module.exports = { generateToken, authenticate, requireRole };