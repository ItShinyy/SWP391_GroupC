const sql = require('mssql');

/*
 * SQL Server connection for the Node payment API.
 *
 * Default values match ClinicLocate/src/main/resources/ConnectDB.properties.
 * When deploying elsewhere, set DB_SERVER, DB_PORT, DB_NAME, DB_USER and
 * DB_PASSWORD as environment variables instead of editing this file.
 */
const dbConfig = {
    server: process.env.DB_SERVER || 'localhost',
    port: Number(process.env.DB_PORT || 1433),
    database: process.env.DB_NAME || 'SWP391',
    user: process.env.DB_USER || 'sa',
    password: process.env.DB_PASSWORD || '123',
    options: {
        encrypt: process.env.DB_ENCRYPT === 'true',
        trustServerCertificate: true,
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000,
    },
};

let poolPromise;

// A single pool is reused by every API request; do not open one connection per payment.
function getPool() {
    if (!poolPromise) {
        poolPromise = new sql.ConnectionPool(dbConfig).connect().catch((error) => {
            poolPromise = undefined;
            throw error;
        });
    }

    return poolPromise;
}

async function closePool() {
    if (poolPromise) {
        const pool = await poolPromise;
        await pool.close();
        poolPromise = undefined;
    }
}

module.exports = { sql, getPool, closePool, dbConfig };
