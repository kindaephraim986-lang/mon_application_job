
# Multi-stage Dockerfile: build backend (Node) and frontend (Flutter web)
FROM node:18-alpine AS backend-builder
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install --production
COPY backend/ .

FROM cirrusci/flutter:stable-web AS frontend-builder
WORKDIR /app/frontend
COPY frontend/pubspec.* ./
RUN flutter pub get
COPY frontend/ .
ARG API_BASE_URL
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM node:18-alpine AS runtime
WORKDIR /app/backend
ENV NODE_ENV=production
ENV PORT=3000

COPY --from=backend-builder /app/backend /app/backend
COPY --from=frontend-builder /app/frontend/build/web /app/public

EXPOSE 3000
CMD ["node", "server.js"]

