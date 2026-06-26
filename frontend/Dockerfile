# Build stage
FROM ghcr.io/cirruslabs/flutter:stable as builder

WORKDIR /app

# Copier les fichiers pubspec
COPY pubspec.* ./

# Récupérer les dépendances
RUN flutter pub get

# Copier tout le code
COPY . .

# Passer l'URL de l'API à la compilation Flutter
ARG API_BASE_URL
ENV API_BASE_URL=${API_BASE_URL}

# Générer le build web en mode release
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# ========================================
# Production stage avec Nginx
FROM nginx:alpine

# Copier les fichiers buildés
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copier la configuration nginx personnalisée
RUN cat <<'EOF' > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name _;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css text/javascript application/javascript application/json;
    gzip_min_length 1000;

    root /usr/share/nginx/html;
    index index.html index.htm;

    # Cache busting pour les fichiers avec hash
    location ~* \.[\da-f]+\.js$ {
        expires 365d;
        add_header Cache-Control "public, immutable";
    }

    location ~* \.[\da-f]+\.css$ {
        expires 365d;
        add_header Cache-Control "public, immutable";
    }

    # SPA fallback
    location / {
        try_files \$uri \$uri/ /index.html;
        expires 1h;
        add_header Cache-Control "public";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
EOF

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80 || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
