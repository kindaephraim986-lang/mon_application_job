const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');

// Charger les variables d'environnement
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Vérifier les variables d'environnement essentielles
const requiredEnvs = ['JWT_SECRET'];
requiredEnvs.forEach((name) => {
  if (!process.env[name]) {
    console.warn(`⚠️ Variable d'environnement manquante: ${name}`);
  }
});

// ======== MIDDLEWARE ========
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  maxAge: 86400
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Servir les fichiers uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Si un build web Flutter est présent, servir l'application web
const possibleFrontendPaths = [
  path.join(__dirname, 'build', 'web'),
  path.join(__dirname, '..', 'build', 'web'),
];
let frontendStaticPath = possibleFrontendPaths.find((frontendPath) => fs.existsSync(frontendPath));

if (frontendStaticPath) {
  app.use(express.static(frontendStaticPath));
  app.get(/^\/(?!api|uploads|health).*/, (req, res) => {
    res.sendFile(path.join(frontendStaticPath, 'index.html'));
  });
} else {
  app.get('/', (req, res) => {
    res.send(`
      <html>
        <head>
          <title>AfriJob Backend</title>
          <meta charset="utf-8" />
        </head>
        <body>
          <h1>AfriJob API</h1>
          <p>Le backend est actif, mais le frontend web n'est pas encore déployé ici.</p>
          <ul>
            <li><a href="/health">/health</a></li>
            <li><a href="/api/auth">/api/auth</a></li>
            <li><a href="/api/offers">/api/offers</a></li>
            <li><a href="/api/applications">/api/applications</a></li>
          </ul>
          <p>Pour voir l'application complète, déployez le frontend Flutter Web et placez les fichiers dans <code>build/web</code>.</p>
        </body>
      </html>
    `);
  });
}

// Test de connexion à la base de données
let db;
try {
  db = require('./config/database');
  console.log('✅ Base de données configurée');
} catch (err) {
  console.error('❌ Échec import config/database — la base peut ne pas être accessible:', err && err.message ? err.message : err);
}

// ======== ROUTES ========
const authRoutes = require('./routes/auth');
const offersRoutes = require('./routes/offers');
const applicationsRoutes = require('./routes/applications');
const uploadRoutes = require('./routes/upload');

app.use('/api/auth', authRoutes);
app.use('/api/offers', offersRoutes);
app.use('/api/applications', applicationsRoutes);
app.use('/api/upload', uploadRoutes);

// Route de santé
app.options('/health', cors());
app.get('/health', cors(), (req, res) => {
  res.json({ status: 'OK', message: 'Serveur actif', timestamp: new Date().toISOString() });
});

// 404 pour les routes API non trouvées
app.use('/api', (req, res, next) => {
  res.status(404).json({ message: 'Route API introuvable' });
});

// Middleware de gestion des erreurs centralisé
app.use((err, req, res, next) => {
  console.error('Unhandled route error:', err && err.stack ? err.stack : err);
  if (res.headersSent) return next(err);
  res.status(err.status || 500).json({ message: err.message || 'Erreur interne du serveur' });
});

// ======== DÉMARRAGE ========
const startServer = (port) => {
  const server = app.listen(port, '0.0.0.0', () => {
    console.log(`✅ Serveur actif sur http://localhost:${port}`);
    console.log(`   Base de données: ${process.env.DB_NAME}`);
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.warn(`⚠️ Port ${port} occupé, tentative sur ${port + 1}`);
      // Essayer un autre port localement
      startServer(port + 1);
    } else {
      console.error('Server error:', err);
    }
  });
};

startServer(Number(PORT));

// Gestion des promesses non gérées et exceptions
process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Rejection non gérée:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('❌ Exception non interceptée:', err && err.stack ? err.stack : err);
  // Ne pas forcer exit immédiatement en environnement géré par Railway; laisser le service redémarrer si nécessaire.
});