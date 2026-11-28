// Connection pool shared by all routes
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    dateStrings: true,
    decimalNumbers: true,
    ssl: process.env.DB_SSL === 'true' ? {rejectUnauthorized: true } : undefined,
});

// Run as all-or-nothing, rollback on any throw
async function withTransaction(work) {
    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();
        const result = await work(conn);
        await conn.commit();
        return result;
    } 
    catch (err) {
        await conn.rollback();
        throw err;
    }
    finally {
        conn.release();
    }
}

module.exports = { pool, withTransaction };