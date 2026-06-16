const mysql = require('mysql2');
require('dotenv').config();

const pool = mysql.createPool({
    host:     process.env.DB_HOST     || 'localhost',
    user:     process.env.DB_USER     || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME     || 'bddiane_sp',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

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
