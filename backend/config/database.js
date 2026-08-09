const mysql = require('mysql2');
const { getDatabaseConfig, validateDatabaseConfig } = require('./db_config');

if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

const poolOptions = getDatabaseConfig();

if (process.env.NODE_ENV === 'production') {
  const missing = validateDatabaseConfig(poolOptions);
  if (missing.length > 0) {
    throw new Error(
      `MySQL environment variables required in production: ${missing.join(', ')}. ` +
      'Set them in Railway service variables or via DATABASE_URL.'
    );
  }
  const invalidHost = ['localhost', '127.0.0.1', '::1'];
  if (invalidHost.includes(poolOptions.host.trim().toLowerCase())) {
    throw new Error(
      `Invalid DB_HOST for production: ${poolOptions.host}. ` +
      'Railway cannot connect to a local MySQL host. Use the internal Railway private host or an external host reachable from Railway.'
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
    console.log('✅ Connecté à MySQL — base: ' + poolOptions.database);
  } catch (err) {
    console.error('❌ Erreur connexion MySQL:', err.message);
    console.error('   Vérifiez que les variables d\'environnement Railway sont configurées correctement.');
  }
})();

pool.on('error', (err) => {
  console.error('❌ Erreur de pool MySQL:', err.message);
});

db.testConnection = testConnection;

module.exports = db;
