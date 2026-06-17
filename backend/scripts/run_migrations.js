const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
const mysql = require('mysql2/promise');

const MIGRATIONS_DIR = path.join(__dirname, '..', 'migrations');

const DB_CONFIG = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'bddiane_sp',
  multipleStatements: true,
};

(async () => {
  try {
    if (!fs.existsSync(MIGRATIONS_DIR)) {
      console.log('No migrations directory:', MIGRATIONS_DIR);
      process.exit(0);
    }

    const files = fs.readdirSync(MIGRATIONS_DIR)
      .filter(f => f.endsWith('.sql'))
      .sort();

    if (files.length === 0) {
      console.log('No .sql migration files found.');
      process.exit(0);
    }

    const conn = await mysql.createConnection(DB_CONFIG);
    console.log('Connected to DB for migrations:', DB_CONFIG.database);

    for (const file of files) {
      const filePath = path.join(MIGRATIONS_DIR, file);
      console.log('Applying migration:', file);
      const sql = fs.readFileSync(filePath, 'utf8');
      try {
        await conn.query(sql);
        console.log('Applied:', file);
      } catch (e) {
        console.warn('Failed to apply migration', file, e.message);
      }
    }

    await conn.end();
    console.log('Migrations complete.');
  } catch (err) {
    console.error('Migration runner error:', err);
    process.exit(1);
  }
})();
