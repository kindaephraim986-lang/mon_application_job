const mysql = require('mysql2/promise');
const { getDatabaseConfig, validateDatabaseConfig } = require('../config/db_config');
(async () => {
  try {
    const cfg = getDatabaseConfig();
    if (process.env.NODE_ENV === 'production') {
      const missing = validateDatabaseConfig(cfg);
      if (missing.length > 0) {
        throw new Error(
          `MySQL environment variables required in production: ${missing.join(', ')}. ` +
          'Set them in Railway service variables or via DATABASE_URL.'
        );
      }
    }
    const conn = await mysql.createConnection(cfg);
    const needed = [
      { name: 'profile_photo_url', sql: "ALTER TABLE candidats ADD COLUMN profile_photo_url VARCHAR(500)" },
      { name: 'photo_cache_buster', sql: "ALTER TABLE candidats ADD COLUMN photo_cache_buster VARCHAR(50)" },
      { name: 'last_photo_update', sql: "ALTER TABLE candidats ADD COLUMN last_photo_update TIMESTAMP NULL" },
    ];

    for (const col of needed) {
      const [rows] = await conn.query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'candidats' AND COLUMN_NAME = ?", [cfg.database, col.name]);
      if (!rows || rows.length === 0) {
        await conn.query(col.sql);
        console.log(`Added column ${col.name}`);
      } else {
        console.log(`Column ${col.name} exists`);
      }
    }
    await conn.end();
  } catch (e) {
    console.error('ERROR', e.message || e);
    process.exit(1);
  }
})();
