# Build stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application files
COPY . .

# Expose port (the actual port is provided by Railway at runtime)
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); const port = process.env.PORT || 3001; const req = http.get({ host: '127.0.0.1', port, path: '/health' }, (res) => { if (res.statusCode !== 200) { throw new Error(res.statusCode); } }); req.on('error', (err) => { throw err; });"

# Start application
CMD ["npm", "start"]
