const jwt = require('jsonwebtoken');

// Generated a JWT token for a logged-in officer
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

// verify token on every protected route using middlewares
function authenticate(req, res, next) {
  const header = req.headers['authorization'];

  // ✅ CHANGE: allow requests without token (for public routes like /api/ping)
  if (!header) return next();

  const token = header.split(' ')[1];

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token invalid or expired.' });
  }
}

// Middleware factory: restrict to specific roles
function requireRole(...roles) {
  return (req, res, next) => {
    // ✅ CHANGE: added check for req.user
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Access denied: insufficient role.' });
    }
    next();
  };
}

module.exports = { generateToken, authenticate, requireRole };