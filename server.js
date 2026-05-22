// backend/server.js
require('dotenv').config();
const express    = require('express');
const cors       = require('cors');
const path       = require('path');
const rateLimit  = require('express-rate-limit');

const app = express();

// ─── Rate Limiting ────────────────────────────
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests. Please wait a moment and try again.' },
});
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { error: 'Too many login attempts. Please try again in 15 minutes.' },
});

// ─── Middleware ───────────────────────────────
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use('/api', apiLimiter);

// ─── Serve Uploaded Files (ID docs — admin only) ─
app.use('/uploads', require('./middleware/auth').requireAdmin,
  express.static(path.resolve(process.env.UPLOAD_DIR || './uploads'))
);

// ─── Serve Frontend ───────────────────────────
app.use(express.static(path.join(__dirname, '../frontend/public')));

// ─── API Routes ───────────────────────────────
app.use('/api/sellers', require('./routes/sellers'));
app.use('/api/admin',   authLimiter, require('./routes/admin'));
app.use('/api/buyers',  require('./routes/buyers').router);
app.use('/api/commissions', require('./routes/commissions'));
app.use('/api/dashboard',   require('./routes/dashboard'));
app.use('/api/commissions', require('./routes/commissions'));
app.use('/api/dashboard',   require('./routes/dashboard'));

// ─── Frontend Catch-all ───────────────────────
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/public/index.html'));
});

// ─── Error Handler ────────────────────────────
app.use((err, req, res, next) => {
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: `File too large. Max size is ${process.env.MAX_FILE_SIZE_MB || 5}MB.` });
  }
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error.' });
});

// ─── Start ────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n🚀 CharloTech server running on http://localhost:${PORT}`);
  console.log(`   ENV: ${process.env.NODE_ENV || 'development'}`);
  console.log(`   Admin login: ${process.env.MAIL_USER || 'admin@charlotech.co.za'}\n`);
});
