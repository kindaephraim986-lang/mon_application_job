FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts --no-audit --no-fund

COPY . .

RUN mkdir -p uploads logs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "const http=require('http'); const port=process.env.PORT || 3000; http.get({host:'127.0.0.1', port, path:'/api/health'}, (r) => {process.exit(r.statusCode === 200 ? 0 : 1);}).on('error', () => process.exit(1));"

ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "server.js"]
