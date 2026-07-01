#!/bin/sh
set -eu
cd /app/backend
node -e "const { initializeDatabase } = require('./scripts/initialize_database'); initializeDatabase({ quiet: false, maxAttempts: 8, retryDelayMs: 5000 }).then(() => process.exit(0)).catch((err) => { console.error(err.message); process.exit(1); })"
