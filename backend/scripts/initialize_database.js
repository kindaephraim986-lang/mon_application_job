const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
const mysql = require('mysql2/promise');

function getDatabaseConfig() {
  const config = {
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    connectTimeout: 10000,
    multipleStatements: true,
  };

  if (process.env.DB_SSL === 'true') {
    config.ssl = { rejectUnauthorized: false };
  }

  return config;
}

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
  let attempt = 1;

  while (attempt <= maxAttempts) {
    let connection;
    try {
      connection = await mysql.createConnection(config);

      await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
      await connection.query(`USE \`${dbName}\``);

      const schemaPath = path.join(__dirname, '..', '..', 'bddiane_sp.sql');
      if (fs.existsSync(schemaPath)) {
        const schemaSql = fs.readFileSync(schemaPath, 'utf8');
        await connection.query(schemaSql);
      }

      for (const migrationFile of getMigrationFiles()) {
        const sql = fs.readFileSync(migrationFile, 'utf8');
        if (sql.trim()) {
          await connection.query(sql);
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
