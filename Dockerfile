FROM node:18-alpine AS builder

# Build backend dependencies
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install --production
COPY backend/ .

FROM node:18-alpine
WORKDIR /app

# Copy backend from builder
COPY --from=builder /app/backend /app

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "server.js"]
