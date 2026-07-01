const mysql = require('mysql2');
require('dotenv').config();

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
