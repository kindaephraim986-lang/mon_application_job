const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
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