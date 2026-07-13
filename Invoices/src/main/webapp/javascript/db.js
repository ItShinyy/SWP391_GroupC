const sql = require('mssql');

let poolPromise;

function required(name) {
    const value = process.env[name];
    if (!value) {
        throw new Error(`Missing required environment variable: ${name}`);
    }
    return value;
}

function readBoolean(name, fallback) {
    const value = process.env[name];
    return value === undefined ? fallback : value.toLowerCase() === 'true';
}

function getDatabaseConfig() {
    return {
        user: required('DB_USER'),
        password: required('DB_PASSWORD'),
        server: required('DB_SERVER'),
        database: required('DB_DATABASE'),
        port: Number(process.env.DB_PORT || 1433),
        options: {
            encrypt: readBoolean('DB_ENCRYPT', true),
            trustServerCertificate: readBoolean('DB_TRUST_SERVER_CERTIFICATE', false),
        },
        pool: {
            max: 10,
            min: 0,
            idleTimeoutMillis: 30000,
        },
    };
}

function getPool() {
    if (!poolPromise) {
        poolPromise = new sql.ConnectionPool(getDatabaseConfig())
            .connect()
            .catch((error) => {
                poolPromise = undefined;
                throw error;
            });
    }
    return poolPromise;
}

async function closePool() {
    if (!poolPromise) return;

    const pool = await poolPromise;
    poolPromise = undefined;
    await pool.close();
}

module.exports = { sql, getPool, closePool };
