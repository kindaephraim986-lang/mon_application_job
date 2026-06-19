const express = require('express');
const cors = require('cors');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.join(__dirname, '.env') });

const authRoutes = require('./routes/auth');
const offersRoutes = require('./routes/offers');
const applicationsRoutes = require('./routes/applications');
const uploadRoutes = require('./routes/upload');
const messagesRoutes = require('./routes/messages');
const notificationsRoutes = require('./routes/notifications');
const paymentsRoutes = require('./routes/payments');
const ocrRoutes = require('./routes/ocr');
const healthRoutes = require('./routes/health');

const app = express();

const rawOrigins = process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',').map(origin => origin.trim()).filter(origin => origin.length > 0) : [];
const isDev = process.env.NODE_ENV !== 'production';
const corsOptions = {
  origin: isDev
    ? true // permissive in development to avoid browser CORS blocking during local testing
    : (rawOrigins.length > 0
      ? (origin, callback) => {
          if (!origin) return callback(null, true);
          if (rawOrigins.includes(origin)) return callback(null, true);
          return callback(new Error('Not allowed by CORS'));
        }
      : true),
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'Origin', 'X-Requested-With'],
  exposedHeaders: ['Authorization'],
  credentials: true,
  optionsSuccessStatus: 204,
};

// CORS debug middleware (logs Origin and Authorization for incoming requests)
app.use((req, res, next) => {
  try {
    const origin = req.headers.origin || '(none)';
    const auth = req.headers.authorization ? '[present]' : '(none)';
    console.log(`[CORS DEBUG] ${req.method} ${req.originalUrl} origin=${origin} authorization=${auth}`);
  } catch (e) {
    // ignore logging errors
  }
  next();
});

app.use(cors(corsOptions));
app.options('*', cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Simple request logger for debugging (show method, path and body)
app.use((req, res, next) => {
  try {
    const auth = req.headers.authorization || '';
    const authPreview = auth ? auth.slice(0, 20) + (auth.length > 20 ? '...' : '') : '(none)';
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - auth: ${authPreview} - body: ${JSON.stringify(req.body)}`);
  } catch (e) {
    // ignore logging errors
  }
  next();
});
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/offers', offersRoutes);
app.use('/api/applications', applicationsRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/messages', messagesRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/payments', paymentsRoutes);
app.use('/api/ocr', ocrRoutes);
app.use('/api/health', healthRoutes);

app.use((req, res) => {
  res.status(404).json({ message: 'Route introuvable' });
});

app.use((err, req, res, next) => {
  console.error('SERVER ERROR:', err);
  res.status(500).json({ message: err.message || 'Erreur serveur interne' });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Serveur actif sur http://0.0.0.0:${PORT}`);
});
