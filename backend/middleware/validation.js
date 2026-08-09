const isValidPhoneInput = (value) => {
  if (typeof value !== 'string') return false;

  const trimmed = value.trim();
  if (!trimmed) return false;

  const digits = trimmed.replace(/[^\d]/g, '');
  return digits.length >= 7 && digits.length <= 15;
};

const validateRegister = (req, res, next) => {
  const { email, password, userType, nom, telephone, age, domicile, filiere, sexe, nomSociete, domaine, villeLieu } = req.body || {};
  const errors = [];

  if (!email || typeof email !== 'string' || !email.trim().includes('@')) {
    errors.push({ msg: 'Email invalide' });
  }

  if (!password || typeof password !== 'string' || password.length < 8) {
    errors.push({ msg: 'Le mot de passe doit contenir au moins 8 caractères' });
  }

  if (userType !== 'candidat' && userType !== 'entreprise' && userType !== 'admin') {
    errors.push({ msg: 'Type utilisateur invalide' });
  }

  if (userType === 'candidat') {
    if (!nom || typeof nom !== 'string' || !nom.trim()) {
      errors.push({ msg: 'Le nom complet est requis' });
    }

    if (telephone && typeof telephone === 'string' && telephone.trim() && !isValidPhoneInput(telephone)) {
      errors.push({ msg: 'Téléphone candidat invalide' });
    }

    if (age !== undefined && age !== null && age !== '' && !/^(\d{1,2})$/.test(String(age))) {
      errors.push({ msg: 'L’âge doit être compris entre 18 et 65 ans' });
    }
  }

  if (userType === 'entreprise') {
    if (!nomSociete || typeof nomSociete !== 'string' || !nomSociete.trim()) {
      errors.push({ msg: 'Le nom de la société est requis' });
    }
    if (!domaine || typeof domaine !== 'string' || !domaine.trim()) {
      errors.push({ msg: 'Le domaine est requis' });
    }
    if (!villeLieu || typeof villeLieu !== 'string' || !villeLieu.trim()) {
      errors.push({ msg: 'La ville / lieu est requis' });
    }

    if (telephone && typeof telephone === 'string' && telephone.trim() && !isValidPhoneInput(telephone)) {
      errors.push({ msg: 'Téléphone entreprise invalide' });
    }
  }

  if (errors.length > 0) {
    return res.status(422).json({ errors });
  }

  return next();
};

const validateProfileUpdate = (req, res, next) => {
  const { telephone } = req.body || {};

  if (telephone && typeof telephone === 'string' && telephone.trim() && !isValidPhoneInput(telephone)) {
    return res.status(422).json({ errors: [{ msg: 'Téléphone invalide' }] });
  }

  return next();
};

module.exports = {
  isValidPhoneInput,
  validateRegister,
  validateProfileUpdate
};
