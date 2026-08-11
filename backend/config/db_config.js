const { URL } = require('url');

function parseDatabaseUrl(databaseUrl) {
  try {
    const url = new URL(databaseUrl);
    return {
      host: url.hostname,
      port: Number(url.port || 3306),
      user: decodeURIComponent(url.username) || 'root',
      password: decodeURIComponent(url.password) || '',
      database: url.pathname ? url.pathname.replace(/^\//, '') : 'bddiane_sp',
      waitForConnections: true,
      connectionLimit: Number(process.env.DB_CONNECTION_LIMIT || 10),
      queueLimit: 0,
    };
  } catch (err) {
    return null;
  }
}

function getDatabaseConfig() {
  if (process.env.DATABASE_URL) {
    const parsed = parseDatabaseUrl(process.env.DATABASE_URL);
    if (parsed) {
      return parsed;
    }
  }

  const host = process.env.DB_HOST || process.env.DATABASE_HOST || (process.env.NODE_ENV === 'production' ? '' : '127.0.0.1');
  const user = process.env.DB_USER || (process.env.NODE_ENV === 'production' ? '' : 'root');
  const password = process.env.DB_PASSWORD || '';
  const sslEnabled = String(process.env.DB_SSL || 'false').toLowerCase() === 'true';

  const config = {
    host,
    port: Number(process.env.DB_PORT || 3306),
    user,
    password,
    database: process.env.DB_NAME || 'bddiane_sp',
    waitForConnections: true,
    connectionLimit: Number(process.env.DB_CONNECTION_LIMIT || 10),
    queueLimit: 0,
  };

  if (sslEnabled) {
    config.ssl = { rejectUnauthorized: false };
  }

  return config;
}

function validateDatabaseConfig(config) {
  const missing = [];
  if (!config.host) missing.push('DB_HOST');
  if (!config.user) missing.push('DB_USER');
  if (!config.database) missing.push('DB_NAME');
  if (config.password == null || config.password === '') missing.push('DB_PASSWORD');
  return missing;
}

module.exports = {
  getDatabaseConfig,
  validateDatabaseConfig,
};
