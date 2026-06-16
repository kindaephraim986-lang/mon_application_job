const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRE || '30d'
    });
};

// ===================== INSCRIPTION =====================
const register = async (req, res) => {
    try {
        const {
            email, password, userType,
            // Candidat
            nom, filiere, telephone, age, domicile, sexe,
            // Entreprise
            nomSociete, domaine, adresse, villeLieu
        } = req.body;

        if (!email || !password || !userType) {
            return res.status(400).json({ message: 'Email, mot de passe et type requis' });
        }

        // Vérifier si email existe déjà
        const [existing] = await db.query(
            'SELECT id FROM utilisateurs WHERE email = ?', [email]
        );
        if (existing.length > 0) {
            return res.status(400).json({ message: 'Cet email est déjà utilisé' });
        }

        // Hasher le mot de passe
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insérer dans utilisateurs
        const [result] = await db.query(
            'INSERT INTO utilisateurs (email, mot_de_passe, type_utilisateur) VALUES (?, ?, ?)',
            [email, hashedPassword, userType]
        );
        const userId = result.insertId;

        // Insérer dans la table profil selon le type
        if (userType === 'candidat') {
            await db.query(
                `INSERT INTO candidats (id, nom_complet, telephone, filiere_specialite, age, domicile, sexe)
                 VALUES (?, ?, ?, ?, ?, ?, ?)`,
                [
                    userId,
                    nom || '',
                    telephone || null,
                    filiere || null,
                    age ? parseInt(age) : null,
                    domicile || null,
                    sexe || null
                ]
            );
        } else if (userType === 'entreprise') {
            await db.query(
                `INSERT INTO entreprises (id, nom_societe, domaine_activite, telephone, adresse_complete, ville_lieu)
                 VALUES (?, ?, ?, ?, ?, ?)`,
                [
                    userId,
                    nomSociete || '',
                    domaine || null,
                    telephone || null,
                    adresse || null,
                    villeLieu || null
                ]
            );
        }

        const token = generateToken(userId);

        res.status(201).json({
            success: true,
            token,
            user: {
                id: userId,
                email,
                userType,
                nom: userType === 'candidat' ? nom : nomSociete,
                telephone: telephone || '',
                age: userType === 'candidat' ? (age ? age.toString() : '') : '',
                domicile: userType === 'candidat' ? domicile || '' : '',
                sexe: userType === 'candidat' ? sexe || '' : '',
            }
        });

    } catch (error) {
        console.error('REGISTER ERROR:', error);
        res.status(500).json({ message: error.message });
    }
};

// ===================== CONNEXION =====================
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Email et mot de passe requis' });
        }

        // Récupérer l'utilisateur
        const [users] = await db.query(
            'SELECT * FROM utilisateurs WHERE email = ?', [email]
        );
        if (users.length === 0) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        const user = users[0];

        // Vérifier le mot de passe
        const isValid = await bcrypt.compare(password, user.mot_de_passe);
        if (!isValid) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        // Récupérer les infos du profil
        let profileData = {};
        if (user.type_utilisateur === 'candidat') {
            const [rows] = await db.query(
                'SELECT nom_complet, telephone, filiere_specialite, age, domicile, sexe, photo_profil_url FROM candidats WHERE id = ?',
                [user.id]
            );
            if (rows.length > 0) profileData = rows[0];
        } else {
            const [rows] = await db.query(
                'SELECT nom_societe, domaine_activite, telephone, logo_url, ville_lieu FROM entreprises WHERE id = ?',
                [user.id]
            );
            if (rows.length > 0) profileData = rows[0];
        }

        const token = generateToken(user.id);

        res.json({
            success: true,
            token,
            user: {
                id: user.id,
                email: user.email,
                userType: user.type_utilisateur,
                nom: profileData.nom_complet || profileData.nom_societe || '',
                telephone: profileData.telephone || '',
                filiere: profileData.filiere_specialite || '',
                domaine: profileData.domaine_activite || '',
                age: profileData.age || '',
                domicile: profileData.domicile || '',
                sexe: profileData.sexe || '',
                photo: profileData.photo_profil_url || profileData.logo_url || ''
            }
        });

    } catch (error) {
        console.error('LOGIN ERROR:', error);
        res.status(500).json({ message: error.message });
    }
};

// ===================== MON PROFIL =====================
const getMe = async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, email, type_utilisateur FROM utilisateurs WHERE id = ?',
            [req.user.id]
        );
        if (users.length === 0) {
            return res.status(404).json({ message: 'Utilisateur introuvable' });
        }

        const user = users[0];
        let profileData = {};

        if (user.type_utilisateur === 'candidat') {
            const [rows] = await db.query('SELECT * FROM candidats WHERE id = ?', [user.id]);
            if (rows.length > 0) profileData = rows[0];
        } else {
            const [rows] = await db.query('SELECT * FROM entreprises WHERE id = ?', [user.id]);
            if (rows.length > 0) profileData = rows[0];
        }

        res.json({
            id: user.id,
            email: user.email,
            userType: user.type_utilisateur,
            ...profileData
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ===================== MODIFIER PROFIL =====================
const updateProfile = async (req, res) => {
    try {
        const { nom, telephone } = req.body;

        if (req.user.type_utilisateur === 'candidat') {
            await db.query(
                'UPDATE candidats SET nom_complet = ?, telephone = ? WHERE id = ?',
                [nom, telephone, req.user.id]
            );
        } else {
            await db.query(
                'UPDATE entreprises SET nom_societe = ?, telephone = ? WHERE id = ?',
                [nom, telephone, req.user.id]
            );
        }
        res.json({ success: true, message: 'Profil mis à jour avec succès' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ===================== INSCRIPTION/CONNEXION INTELLIGENTE =====================
// Si compte existe → connexion automatique
// Si compte n'existe pas → création + connexion automatique
const smartRegisterOrLogin = async (req, res) => {
    try {
        const {
            email, password, userType,
            // Candidat
            nom, filiere, telephone, age, domicile, sexe,
            // Entreprise
            nomSociete, domaine, adresse, villeLieu
        } = req.body;

        if (!email || !password || !userType) {
            return res.status(400).json({ message: 'Email, mot de passe et type requis' });
        }

        // ÉTAPE 1: Chercher si le compte existe
        const [existing] = await db.query(
            'SELECT * FROM utilisateurs WHERE email = ?', [email]
        );

        let userId;
        let user;
        let profileData = {};

        if (existing.length > 0) {
            // ✅ COMPTE EXISTE → Connexion automatique
            user = existing[0];
            userId = user.id;

            // Vérifier le mot de passe
            const isValid = await bcrypt.compare(password, user.mot_de_passe);
            if (!isValid) {
                return res.status(401).json({ message: 'Mot de passe incorrect' });
            }

            console.log(`✓ Connexion automatique: ${email}`);

        } else {
            // ✅ COMPTE N'EXISTE PAS → Création + Connexion automatique
            const hashedPassword = await bcrypt.hash(password, 10);

            // Insérer dans utilisateurs
            const [result] = await db.query(
                'INSERT INTO utilisateurs (email, mot_de_passe, type_utilisateur) VALUES (?, ?, ?)',
                [email, hashedPassword, userType]
            );
            userId = result.insertId;
            user = { id: userId, email, type_utilisateur: userType };

            // Insérer le profil selon le type
            if (userType === 'candidat') {
                await db.query(
                    `INSERT INTO candidats (id, nom_complet, telephone, filiere_specialite, age, domicile, sexe)
                     VALUES (?, ?, ?, ?, ?, ?, ?)`,
                    [
                        userId,
                        nom || '',
                        telephone || null,
                        filiere || null,
                        age ? parseInt(age) : null,
                        domicile || null,
                        sexe || null
                    ]
                );
            } else if (userType === 'entreprise') {
                await db.query(
                    `INSERT INTO entreprises (id, nom_societe, domaine_activite, telephone, adresse_complete, ville_lieu)
                     VALUES (?, ?, ?, ?, ?, ?)`,
                    [
                        userId,
                        nomSociete || '',
                        domaine || null,
                        telephone || null,
                        adresse || null,
                        villeLieu || null
                    ]
                );
            }

            console.log(`✓ Nouveau compte créé et connecté: ${email}`);
        }

        // ÉTAPE 2: Récupérer les infos du profil
        if (user.type_utilisateur === 'candidat') {
            const [rows] = await db.query(
                'SELECT nom_complet, telephone, filiere_specialite, age, domicile, sexe, photo_profil_url FROM candidats WHERE id = ?',
                [userId]
            );
            if (rows.length > 0) profileData = rows[0];
        } else {
            const [rows] = await db.query(
                'SELECT nom_societe, domaine_activite, telephone, logo_url, ville_lieu FROM entreprises WHERE id = ?',
                [userId]
            );
            if (rows.length > 0) profileData = rows[0];
        }

        // ÉTAPE 3: Générer token et envoyer réponse
        const token = generateToken(userId);

        res.status(200).json({
            success: true,
            token,
            isNewAccount: existing.length === 0,
            user: {
                id: userId,
                email: user.email,
                userType: user.type_utilisateur,
                nom: profileData.nom_complet || profileData.nom_societe || '',
                telephone: profileData.telephone || '',
                filiere: profileData.filiere_specialite || '',
                domaine: profileData.domaine_activite || '',
                age: profileData.age || '',
                domicile: profileData.domicile || '',
                sexe: profileData.sexe || '',
                photo: profileData.photo_profil_url || profileData.logo_url || ''
            }
        });

    } catch (error) {
        console.error('SMART REGISTER/LOGIN ERROR:', error);
        res.status(500).json({ message: error.message });
    }
};

module.exports = { register, login, getMe, updateProfile, smartRegisterOrLogin };
