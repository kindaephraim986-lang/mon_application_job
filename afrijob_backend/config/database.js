const mysql = require('mysql2');
require('dotenv').config();

// Debug: Log des variables d'environnement
console.log('🔍 Variables d\'environnement reçues:');
console.log('   DB_HOST:', process.env.DB_HOST);
console.log('   DB_USER:', process.env.DB_USER);
console.log('   DB_PASSWORD:', process.env.DB_PASSWORD ? '✓ (défini)' : '✗ (vide)');
console.log('   DB_NAME:', process.env.DB_NAME);
console.log('   DB_PORT:', process.env.DB_PORT);

const pool = mysql.createPool({
    host:     process.env.DB_HOST || process.env.MYSQL_HOST || 'localhost',
    user:     process.env.DB_USER || process.env.MYSQL_USER || 'root',
    password: process.env.DB_PASSWORD || process.env.MYSQL_PASSWORD || '',
    database: process.env.DB_NAME || process.env.MYSQL_DATABASE || 'bddiane_sp',
    port:     process.env.DB_PORT || process.env.MYSQL_PORT || 3306,
    ssl:      { rejectUnauthorized: false }, // Support PlanetScale/Remote MySQL
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
