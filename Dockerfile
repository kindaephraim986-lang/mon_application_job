FROM node:18-alpine AS backend-builder

WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install --production
COPY backend/ .

FROM cirrusci/flutter:latest AS frontend-builder

WORKDIR /app/frontend
COPY frontend/pubspec*.yaml ./
RUN flutter pub get
COPY frontend/ .
ARG API_BASE_URL
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM node:18-alpine
WORKDIR /app

# Copy backend from builder
COPY --from=backend-builder /app/backend /app

# Copy frontend static build from flutter builder
COPY --from=frontend-builder /app/frontend/build/web /app/public

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "server.js"]
