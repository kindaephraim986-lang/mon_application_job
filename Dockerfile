FROM node:18-alpine AS backend-builder
WORKDIR /app

COPY backend/package*.json ./backend/
RUN cd /app/backend && npm install --production
COPY backend ./backend

FROM cirrusci/flutter:3.7.7 AS frontend-builder
WORKDIR /app/frontend

COPY frontend/pubspec.* ./
RUN flutter pub get

COPY frontend/ ./
RUN flutter build web --release --dart-define=API_BASE_URL=https://afrijob-backend.onrender.com/api --dart-define=APP_ENV=production

FROM node:18-alpine AS runtime
WORKDIR /app

COPY --from=backend-builder /app/backend ./backend
COPY --from=frontend-builder /app/frontend/build/web ./public

WORKDIR /app/backend
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000
CMD ["node", "server.js"]
