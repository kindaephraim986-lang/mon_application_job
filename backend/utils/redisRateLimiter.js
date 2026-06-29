const { createClient } = require('redis');

const REDIS_URL = process.env.REDIS_URL || 'redis://127.0.0.1:6379';

const client = createClient({ url: REDIS_URL });

client.on('error', (err) => {
  console.error('Redis client error:', err);
});

let connected = false;
async function connect() {
  if (!connected) {
    try {
      await client.connect();
      connected = true;
      console.log('Connected to Redis for rate limiting');
    } catch (e) {
      console.error('Failed to connect to Redis:', e.message);
    }
  }
}

// Basic fixed-window counter rate limiter using INCR + EXPIRE
// key: string, limit: number of allowed requests, windowSeconds: window length
async function allowKey(key, limit, windowSeconds) {
  try {
    if (!connected) await connect();
    const value = await client.incr(key);
    if (value === 1) {
      await client.expire(key, windowSeconds);
    }
    return value <= limit;
  } catch (e) {
    // On Redis error, fail open (allow) but log
    console.error('Redis rate limiter error:', e.message);
    return true;
  }
}

async function allowActionForUser(userId, actionName, limit, windowSeconds) {
  const key = `rate:${actionName}:${userId}`;
  return allowKey(key, limit, windowSeconds);
}

module.exports = { allowActionForUser, connect };
