require('dotenv').config();

const path = require('path');
const express = require('express');
const session = require('express-session');
const { pool } = require('./database');
const { asyncHandler, notFound, errorHandler } = require('./errors');
const { requireLogin, requireAdmin } = require('./middleware/auth');

if (!process.env.SESSION_SECRET) {
    console.error('secret missing');
    process.exit(1);
}

const app = express();
const isProduction = process.env.NODE_ENV === 'production';

app.disable('x-powered-by');
app.set('trust proxy', 1);
app.use(express.json({ limit: '100kb' }));
app.use(session({
    name: 'sid',
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
        httpOnly: true,
        sameSite: lax,
        secure: isProduction,
        maxAge: 8 * 60 * 60 * 1000,
    },
}));

// Routes
app.get('/api/health', asyncHandler(async (req, res) => {
    await pool.query('SELECT 1');
    res.json({ ok: true, database: 'connected' })
}));

app.use(errorHandler);

app.use('/api/auth', require('./routes/auth'));
app.use('/api', require('./routes/programs'));
app.use('/api/applicants', requireLogin, require('./routes/applicants'));
app.use('/api/applications', requireLogin, require('./routes/applications'));
app.use('/api/stats', requireLogin, require('./routes/stats'));
app.use('/api/staff', requireAdmin, require('./routes/staff'));
app.use('/api', notFound);

const port = Number(process.env.PORT || 3000);
if (require.main === module) {
    app.listen(port, () => console.log('Admissions running at ${port}'));
}

module.exports = app;