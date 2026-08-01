const mysql = require('mysql2/promise');
(async () => {
  try {
    const cfg = {
      host: process.env.DB_HOST || '127.0.0.1',
      port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 3306,
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'bddiane_sp'
    };
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
