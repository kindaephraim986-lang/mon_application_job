const fs = require('fs');
const path = require('path');
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
}
const mysql = require('mysql2/promise');
const { getDatabaseConfig, validateDatabaseConfig } = require('../config/db_config');

function getMigrationFiles() {
  const migrationsDir = path.join(__dirname, '..', 'migrations');
  if (!fs.existsSync(migrationsDir)) {
    return [];
  }

  return fs.readdirSync(migrationsDir)
    .filter((file) => file.endsWith('.sql'))
    .sort()
    .map((file) => path.join(migrationsDir, file));
}

async function initializeDatabase(options = {}) {
  const dbName = options.dbName || process.env.DB_NAME || 'bddiane_sp';
  const maxAttempts = Number(options.maxAttempts || process.env.DB_INIT_MAX_ATTEMPTS || 6);
  const retryDelayMs = Number(options.retryDelayMs || process.env.DB_INIT_RETRY_DELAY_MS || 5000);
  const quiet = Boolean(options.quiet);

  const config = getDatabaseConfig();
  const missing = validateDatabaseConfig(config);
  if (process.env.NODE_ENV === 'production' && missing.length > 0) {
    throw new Error(
      `MySQL environment variables required in production: ${missing.join(', ')}. ` +
      'Set them in Railway service variables or via DATABASE_URL.'
    );
  }

  while (attempt <= maxAttempts) {
    let connection;
    try {
      connection = await mysql.createConnection(config);

      await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
      await connection.query(`USE \`${dbName}\``);

      const schemaPathCandidates = [
        path.join(__dirname, '..', '..', 'bddiane_sp.sql'),
        path.join(__dirname, '..', 'bddiane_sp.sql'),
        path.join(__dirname, '..', '..', '..', 'bddiane_sp.sql'),
      ];
      const schemaPath = schemaPathCandidates.find(fs.existsSync);
      if (schemaPath) {
        const schemaSql = fs.readFileSync(schemaPath, 'utf8');
        if (schemaSql.trim()) {
          await connection.query(schemaSql);
        }
      } else {
        console.warn('⚠️ Fichier de schéma MySQL non trouvé. Aucun SQL initial n’a été appliqué.');
      }

      for (const migrationFile of getMigrationFiles()) {
        const sql = fs.readFileSync(migrationFile, 'utf8');
        if (sql.trim()) {
          try {
            await connection.query(sql);
          } catch (migrationError) {
            if (!quiet) {
              console.warn(`⚠️ Migration ignorée ${path.basename(migrationFile)}: ${migrationError.message}`);
            }
          }
        }
      }

      await connection.end();
      if (!quiet) {
        console.log(`✅ Base MySQL prête: ${dbName}`);
      }
      return { success: true, dbName, attempts: attempt };
    } catch (error) {
      if (connection) {
        try {
          await connection.end();
        } catch (closeError) {
          // Ignore close errors
        }
      }

      if (attempt >= maxAttempts) {
        const message = `Initialisation MySQL impossible après ${attempt} tentative(s): ${error.message}`;
        if (!quiet) {
          console.error(`❌ ${message}`);
        }
        throw new Error(message);
      }

      if (!quiet) {
        console.warn(`⚠️ Tentative d'initialisation MySQL ${attempt}/${maxAttempts} échouée: ${error.message}`);
      }
      await new Promise((resolve) => setTimeout(resolve, retryDelayMs));
      attempt += 1;
    }
  }

  throw new Error('Initialisation MySQL impossible');
}

module.exports = {
  initializeDatabase,
  getDatabaseConfig,
};
