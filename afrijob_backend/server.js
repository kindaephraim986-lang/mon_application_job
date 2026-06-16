const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');

// Charger les variables d'environnement
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

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
const db = require('./config/database');
console.log('✅ Base de données configurée');

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

// ======== DÉMARRAGE ========
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Serveur actif sur http://localhost:${PORT}`);
  console.log(`   Base de données: ${process.env.DB_NAME}`);
});