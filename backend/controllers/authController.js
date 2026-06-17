const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET || 'afrijob_dev_secret', {
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
            nomSociete, nom_societe, domaine, adresse, villeLieu
        } = req.body;

        const nomEntreprise = nomSociete || nom_societe || '';

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
                    nomEntreprise,
                    domaine || null,
                    telephone || null,
                    adresse || null,
                    villeLieu || null
                ]
            );
        }

        const token = generateToken(userId);

        const userResponse = {
            id: userId,
            email,
            userType,
            nom: userType === 'candidat' ? nom : nomEntreprise,
            telephone: telephone || '',
            filiere: userType === 'candidat' ? filiere || '' : '',
            domaine: userType === 'entreprise' ? domaine || '' : '',
            age: userType === 'candidat' ? age || null : null,
            domicile: userType === 'candidat' ? domicile || '' : '',
            sexe: userType === 'candidat' ? sexe || '' : '',
            adresse: userType === 'entreprise' ? adresse || '' : '',
            villeLieu: userType === 'entreprise' ? villeLieu || '' : ''
        };

        res.status(201).json({
            success: true,
            token,
            user: userResponse
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
                'SELECT nom_complet, telephone, filiere_specialite, age, domicile, sexe, photo_profil_url, cv_url, cnib_recto_url, cnib_verso_url FROM candidats WHERE id = ?',
                [user.id]
            );
            if (rows.length > 0) profileData = rows[0];
        } else {
            const [rows] = await db.query(
                'SELECT nom_societe, domaine_activite, telephone, adresse_complete, ville_lieu, logo_url FROM entreprises WHERE id = ?',
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
                age: profileData.age != null ? profileData.age.toString() : '',
                domicile: profileData.domicile || '',
                sexe: profileData.sexe || '',
                adresse: profileData.adresse_complete || '',
                villeLieu: profileData.ville_lieu || '',
                photo: profileData.photo_profil_url || profileData.logo_url || '',
                cvUrl: profileData.cv_url || '',
                cnibRectoUrl: profileData.cnib_recto_url || '',
                cnibVersoUrl: profileData.cnib_verso_url || ''
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
            nom: profileData.nom_complet || profileData.nom_societe || '',
            telephone: profileData.telephone || '',
            filiere: profileData.filiere_specialite || '',
            age: profileData.age != null ? profileData.age.toString() : '',
            domicile: profileData.domicile || '',
            sexe: profileData.sexe || '',
            adresse: profileData.adresse_complete || '',
            villeLieu: profileData.ville_lieu || '',
            photo: profileData.photo_profil_url || profileData.logo_url || '',
            cvUrl: profileData.cv_url || '',
            cnibRectoUrl: profileData.cnib_recto_url || '',
            cnibVersoUrl: profileData.cnib_verso_url || ''
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ===================== MODIFIER PROFIL =====================
const updateProfile = async (req, res) => {
    try {
        if (req.user.type_utilisateur === 'candidat') {
            const { nom, telephone, filiere, age, domicile, sexe, photoUrl, cvUrl, cnibRectoUrl, cnibVersoUrl } = req.body;

            await db.query(
                `UPDATE candidats
                 SET nom_complet = ?,
                     telephone = ?,
                     filiere_specialite = ?,
                     age = ?,
                     domicile = ?,
                     sexe = ?,
                     photo_profil_url = COALESCE(?, photo_profil_url),
                     cv_url = COALESCE(?, cv_url),
                     cnib_recto_url = COALESCE(?, cnib_recto_url),
                     cnib_verso_url = COALESCE(?, cnib_verso_url)
                 WHERE id = ?`,
                [
                    nom || '',
                    telephone || null,
                    filiere || null,
                    age ? parseInt(age) : null,
                    domicile || null,
                    sexe || null,
                    photoUrl || null,
                    cvUrl || null,
                    cnibRectoUrl || null,
                    cnibVersoUrl || null,
                    req.user.id
                ]
            );

            // Récupérer le profil mis à jour
            const [rows] = await db.query(
                'SELECT nom_complet, telephone, filiere_specialite, age, domicile, sexe, photo_profil_url, cv_url, cnib_recto_url, cnib_verso_url FROM candidats WHERE id = ?',
                [req.user.id]
            );
            const profileData = rows[0] || {};

            res.json({
                success: true,
                message: 'Profil mis à jour avec succès',
                user: {
                    nom: profileData.nom_complet || '',
                    telephone: profileData.telephone || '',
                    filiere: profileData.filiere_specialite || '',
                    age: profileData.age != null ? profileData.age.toString() : '',
                    domicile: profileData.domicile || '',
                    sexe: profileData.sexe || '',
                    photo: profileData.photo_profil_url || '',
                    cvUrl: profileData.cv_url || '',
                    cnibRectoUrl: profileData.cnib_recto_url || '',
                    cnibVersoUrl: profileData.cnib_verso_url || ''
                }
            });
        } else {
            const { nom, telephone, domaine, adresse, villeLieu } = req.body;

            await db.query(
                'UPDATE entreprises SET nom_societe = ?, telephone = ?, domaine_activite = ?, adresse_complete = ?, ville_lieu = ? WHERE id = ?',
                [nom || '', telephone || null, domaine || null, adresse || null, villeLieu || null, req.user.id]
            );

            // Récupérer le profil mis à jour
            const [rows] = await db.query(
                'SELECT nom_societe, telephone, domaine_activite, adresse_complete, ville_lieu FROM entreprises WHERE id = ?',
                [req.user.id]
            );
            const profileData = rows[0] || {};

            res.json({
                success: true,
                message: 'Profil mis à jour avec succès',
                user: {
                    nom: profileData.nom_societe || '',
                    telephone: profileData.telephone || '',
                    domaine: profileData.domaine_activite || '',
                    adresse: profileData.adresse_complete || '',
                    villeLieu: profileData.ville_lieu || ''
                }
            });
        }
    } catch (error) {
        console.error('UPDATE PROFILE ERROR:', error);
        res.status(500).json({ message: error.message });
    }
};

module.exports = { register, login, getMe, updateProfile };
