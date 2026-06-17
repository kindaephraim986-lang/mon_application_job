const jwt = require('jsonwebtoken');
const db = require('../config/database');
const fs = require('fs');
const path = require('path');

const usersFile = path.join(__dirname, '../data/users.json');

const loadUsers = () => {
    try {
        if (fs.existsSync(usersFile)) {
            return JSON.parse(fs.readFileSync(usersFile, 'utf8'));
        }
    } catch (e) {
        console.warn('Impossible de lire users.json');
    }
    return {};
};

const protect = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
        return res.status(401).json({ message: 'Non autorisé, token manquant' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'afrijob_dev_secret');

        if (decoded.id && decoded.id.toString().startsWith('user_')) {
            const users = loadUsers();
            const user = users[decoded.id];

            if (!user) {
                return res.status(401).json({ message: 'Utilisateur introuvable' });
            }

            req.user = {
                id: user.id,
                email: user.email,
                type_utilisateur: user.userType,
                user_type: user.userType
            };
            return next();
        }

        const [users] = await db.query(
            'SELECT id, email, type_utilisateur FROM utilisateurs WHERE id = ?',
            [decoded.id]
        );

        if (users.length === 0) {
            return res.status(401).json({ message: 'Utilisateur introuvable' });
        }

        req.user = users[0];
        // Alias pour compatibilité
        req.user.user_type = users[0].type_utilisateur;
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Token invalide ou expiré' });
    }
};

const authorize = (...types) => {
    return (req, res, next) => {
        if (!types.includes(req.user.type_utilisateur)) {
            return res.status(403).json({ message: 'Accès refusé pour ce type de compte' });
        }
        next();
    };
};

module.exports = { protect, authorize };
