const sql = require('mssql');

// Giá»¯ má»™t connection pool dĂ¹ng chung Ä‘á»ƒ khĂ´ng má»Ÿ káº¿t ná»‘i SQL Server cho má»—i request.
let poolPromise;

// Äá»c biáº¿n mĂ´i trÆ°á»ng báº¯t buá»™c; dá»«ng sá»›m náº¿u thiáº¿u cáº¥u hĂ¬nh káº¿t ná»‘i database.
function required(name) {
    const value = process.env[name];
    if (!value) {
        throw new Error(`Missing required environment variable: ${name}`);
    }
    return value;
}

// Äá»•i chuá»—i cáº¥u hĂ¬nh "true"/"false" trong .env thĂ nh kiá»ƒu boolean.
function readBoolean(name, fallback) {
    const value = process.env[name];
    return value === undefined ? fallback : value.toLowerCase() === 'true';
}

// Táº¡o cáº¥u hĂ¬nh mssql tá»« .env, dĂ¹ng cĂ¹ng SQL Server vá»›i dá»± Ă¡n ClinicLocate/SkinAI.
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

// Khá»Ÿi táº¡o (hoáº·c tĂ¡i sá»­ dá»¥ng) pool SQL Server; náº¿u káº¿t ná»‘i lá»—i thĂ¬ cho phĂ©p láº§n sau táº¡o láº¡i.
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

// ÄĂ³ng pool khi Node.js nháº­n lá»‡nh dá»«ng Ä‘á»ƒ giáº£i phĂ³ng káº¿t ná»‘i database.
async function closePool() {
    if (!poolPromise) return;

    const pool = await poolPromise;
    poolPromise = undefined;
    await pool.close();
}

module.exports = { sql, getPool, closePool };

