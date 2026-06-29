const mysql = require('mysql2');
require('dotenv').config();

const poolOptions = {
    host:     process.env.DB_HOST     || '127.0.0.1',
    port:     parseInt(process.env.DB_PORT, 10) || 3306,
    user:     process.env.DB_USER     || 'root',
    database: process.env.DB_NAME     || 'bddiane_sp',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

if (process.env.DB_PASSWORD) {
    poolOptions.password = process.env.DB_PASSWORD;
}

if (process.env.DB_SSL === 'true') {
    poolOptions.ssl = { rejectUnauthorized: false };
}

const pool = mysql.createPool(poolOptions);

// Tester la connexion au démarrage
pool.getConnection((err, connection) => {
    if (err) {
        console.error('❌ Erreur connexion MySQL:', err.message);
        console.error('   Vérifiez que MySQL est démarré et que bddiane_sp existe.');
    } else {
        console.log('✅ Connecté à MySQL — base: ' + process.env.DB_NAME);
        connection.release();
    }
});

module.exports = pool.promise();
