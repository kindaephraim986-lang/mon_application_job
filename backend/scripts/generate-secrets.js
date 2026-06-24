#!/usr/bin/env node
/**
 * 🔐 GENERATE PRODUCTION SECRETS
 * 
 * This script generates secure random strings for production deployment.
 * Run ONCE before deployment and save the output to .env
 * 
 * Usage:
 *   node scripts/generate-secrets.js
 */

const crypto = require('crypto');

function generateSecret(length = 32) {
  return crypto.randomBytes(length).toString('hex');
}

function generateBase64Secret(length = 32) {
  return crypto.randomBytes(length).toString('base64');
}

console.log('\n🔐 PRODUCTION SECRETS GENERATOR\n');
console.log('=' .repeat(70));

const secrets = {
  JWT_SECRET: generateSecret(64),  // 64 bytes = 128 hex chars (very strong)
  FILE_SIGNATURE_SECRET: generateSecret(32),
  SESSION_SECRET: generateSecret(32),
  DATABASE_PASSWORD: generateSecret(24), // Database password
};

console.log('\n📋 COPY THESE VALUES TO YOUR .env FILE:\n');

console.log('# JWT Secret (for token signing)');
console.log(`JWT_SECRET=${secrets.JWT_SECRET}`);

console.log('\n# File Signature Secret');
console.log(`FILE_SIGNATURE_SECRET=${secrets.FILE_SIGNATURE_SECRET}`);

console.log('\n# Session Secret');
console.log(`SESSION_SECRET=${secrets.SESSION_SECRET}`);

console.log('\n# Database Password (suggested, CHANGE to your actual password)');
console.log(`DB_PASSWORD=${generateSecret(16)}`);

console.log('\n' + '='.repeat(70));
console.log('\n⚠️  IMPORTANT SECURITY NOTES:\n');
console.log('1. Copy secrets above to .env file');
console.log('2. DO NOT commit .env to git (add to .gitignore)');
console.log('3. Use environment variables in production deployment');
console.log('4. Rotate secrets every 90 days for enhanced security');
console.log('5. Store backups of secrets in secure vault (1Password, Vault, etc)');

console.log('\n📌 CORS Configuration:\n');
console.log('Update these in .env based on your deployment domain:');
console.log('CORS_ORIGIN=https://yourdomain.com');
console.log('BACKEND_URL=https://api.yourdomain.com');
console.log('FRONTEND_URL=https://yourdomain.com');

console.log('\n💾 Environment Variables Summary:\n');
console.log(`JWT_SECRET length: ${secrets.JWT_SECRET.length} chars`);
console.log(`FILE_SIGNATURE_SECRET length: ${secrets.FILE_SIGNATURE_SECRET.length} chars`);
console.log(`SESSION_SECRET length: ${secrets.SESSION_SECRET.length} chars`);

console.log('\n✅ Secrets generated successfully!\n');
