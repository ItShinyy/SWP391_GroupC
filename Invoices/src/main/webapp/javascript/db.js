const sql = require('mssql');

// Giữ một connection pool dùng chung để không mở kết nối SQL Server cho mỗi request.
let poolPromise;

// Đọc biến môi trường bắt buộc; dừng sớm nếu thiếu cấu hình kết nối database.
function required(name) {
    const value = process.env[name];
    if (!value) {
        throw new Error(`Missing required environment variable: ${name}`);
    }
    return value;
}

// Đổi chuỗi cấu hình "true"/"false" trong .env thành kiểu boolean.
function readBoolean(name, fallback) {
    const value = process.env[name];
    return value === undefined ? fallback : value.toLowerCase() === 'true';
}

// Tạo cấu hình mssql từ .env, dùng cùng SQL Server với dự án ClinicLocate/SkinAI.
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

// Khởi tạo (hoặc tái sử dụng) pool SQL Server; nếu kết nối lỗi thì cho phép lần sau tạo lại.
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

// Đóng pool khi Node.js nhận lệnh dừng để giải phóng kết nối database.
async function closePool() {
    if (!poolPromise) return;

    const pool = await poolPromise;
    poolPromise = undefined;
    await pool.close();
}

module.exports = { sql, getPool, closePool };
