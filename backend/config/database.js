const mysql = require('mysql2');
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

const poolOptions = {
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'bddiane_sp',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    connectTimeout: 10000,
    acquireTimeout: 10000,
    timezone: 'Z'
};

if (process.env.DB_SSL === 'true') {
    poolOptions.ssl = { rejectUnauthorized: false };
}

if (process.env.NODE_ENV === 'production') {
    const missing = [];
    if (!process.env.DB_HOST) missing.push('DB_HOST');
    if (!process.env.DB_USER) missing.push('DB_USER');
    if (!process.env.DB_NAME) missing.push('DB_NAME');
    if (missing.length > 0) {
        throw new Error(
            `MySQL environment variables required in production: ${missing.join(', ')}. ` +
            'Set them in Render service environment variables or render.yaml with sync=false.'
        );
    }
    const invalidHost = ['localhost', '127.0.0.1', '::1'];
    if (invalidHost.includes(process.env.DB_HOST.trim().toLowerCase())) {
        throw new Error(
            `Invalid DB_HOST for production: ${process.env.DB_HOST}. ` +
            'Render cannot connect to a local MySQL host. Use an external MySQL host reachable from Render.'
        );
    }
}

const pool = mysql.createPool(poolOptions);
const db = pool.promise();

const testConnection = async () => {
    const connection = await db.getConnection();
    connection.release();
    return true;
};

(async () => {
    try {
        await testConnection();
        console.log('✅ Connecté à MySQL — base: ' + (process.env.DB_NAME || 'bddiane_sp'));
    } catch (err) {
        console.error('❌ Erreur connexion MySQL:', err.message);
        console.error('   Vérifiez que MySQL est démarré et que la base existe.');
    }
})();

pool.on('error', (err) => {
    console.error('❌ Erreur de pool MySQL:', err.message);
});

db.testConnection = testConnection;

module.exports = db;
