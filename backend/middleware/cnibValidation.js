/**
 * CNIB Validation Middleware
 * Valide que les uploads de documents sont bien des Cartes Nationales d'Identité
 */

const fs = require('fs');
const path = require('path');
const { createWorker } = require('tesseract.js');

/**
 * Valide si le texte extrait provient d'une Carte Nationale d'Identité (CNIB)
 * @param {string} text - Texte extrait par OCR
 * @returns {object} Validation result with isValid boolean and message
 */
const isCNIBDocument = (text) => {
  if (!text || typeof text !== 'string') {
    return {
      isValid: false,
      message: 'Aucun texte détecté dans l\'image. Veuillez fournir une image claire.'
    };
  }

  // Normaliser le texte pour la comparaison
  const normalizedText = text.toLowerCase().replace(/\s+/g, ' ').trim();

  const containsAny = (words) => words.some(word => normalizedText.includes(word));

  const docTypeIndicators = [
    'carte nationale d\'identité',
    'carte nationale',
    'carte d\'identité',
    'carte d\'identite',
    'cnib',
    'cni'
  ];
  const nameLabelIndicators = ['nom', 'prénom', 'prenom', 'nom et prénom', 'nom complet', 'nom patronymique'];
  const photoLabelIndicators = ['photo', 'signature', 'photographie'];
  const birthDateLabels = ['né le', 'née le', 'date de naissance', 'date de naissance', 'né(e) le'];
  const additionalIdentityLabels = ['sexe', 'nationalité', 'lieu de naissance', 'lieu de délivrance', 'date de délivrance', 'autorité délivrante', 'numéro d’identité', 'numero d’identité', 'numéro identité', 'numero identité'];

  const hasDocTypeIndicator = containsAny(docTypeIndicators);
  const hasNameLabel = containsAny(nameLabelIndicators);
  const hasPhotoLabel = containsAny(photoLabelIndicators);
  const hasBirthDateLabel = containsAny(birthDateLabels);
  const hasAdditionalIdentityLabel = containsAny(additionalIdentityLabels);

  const datePattern = /\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}\b/;
  const hasDatePattern = datePattern.test(normalizedText);

  const identityNumberPattern = /\b(?:n(?:°|º|o|r)\s*[:\-]?\s*\w+|num(?:éro|ero)?\b.*?\d+|[A-Z]{2}\d{3,}|\d{7,})\b/i;
  const hasIdentityNumber = identityNumberPattern.test(normalizedText);

  const evidenceCount = [
    hasDocTypeIndicator,
    hasNameLabel,
    hasPhotoLabel,
    hasBirthDateLabel,
    hasAdditionalIdentityLabel,
    hasDatePattern,
    hasIdentityNumber
  ].filter(Boolean).length;

  // Accept when document clearly carries CNIB/CNI indicators with several identity fields.
  if (hasDocTypeIndicator && evidenceCount >= 3) {
    return {
      isValid: true,
      message: 'Image de CNIB validée avec succès'
    };
  }

  // Accept when the document likely contains multiple identity fields even if the exact CNIB label was not recognized.
  if (!hasDocTypeIndicator && evidenceCount >= 4) {
    return {
      isValid: true,
      message: 'Image de CNIB validée avec succès'
    };
  }

  // Accept a well-formed identity card with a number, date, and one or more identity labels.
  if (hasIdentityNumber && hasDatePattern && (hasNameLabel || hasBirthDateLabel || hasAdditionalIdentityLabel)) {
    return {
      isValid: true,
      message: 'Image de CNIB validée avec succès'
    };
  }

  return {
    isValid: false,
    message: 'L\'image fournie ne semble pas être une Carte d\'Identité valide. Assurez-vous que l\'image est claire et contient des éléments typiques de la CNIB (nom, date, numéro, photo).'
  };
};

/**
 * Valide un upload d'image CNIB par OCR
 * @param {string} filePath - Chemin du fichier uploadé
 * @returns {Promise<object>} Validation result
 */
const validateCNIBImageViaOCR = async (filePath) => {
  const worker = await createWorker({
    errorHandler: (error) => {
      console.error('TESSERACT WORKER ERROR:', error);
    }
  });

  try {
    // Vérifier les magic bytes du fichier
    const buf = fs.readFileSync(filePath);
    const isJpeg = buf.length >= 3 && buf[0] === 0xFF && buf[1] === 0xD8 && buf[2] === 0xFF;
    const isPng = buf.length >= 8 && buf[0] === 0x89 && buf[1] === 0x50 && buf[2] === 0x4E && buf[3] === 0x47;

    if (!isJpeg && !isPng) {
      return {
        isValid: false,
        message: 'Format de fichier invalide. Seuls JPG et PNG sont acceptés pour les CNIB.'
      };
    }

    // Charger Tesseract et extraire le texte
    await worker.load();
    await worker.loadLanguage('fra');
    await worker.initialize('fra');

    const buffer = fs.readFileSync(filePath);
    const { data } = await worker.recognize(buffer);
    const extractedText = data.text || '';

    const validation = isCNIBDocument(extractedText);
    console.log('[CNIB VALIDATION] extractedTextLength=', extractedText.length, 'valid=', validation.isValid, 'message=', validation.message);

    return validation;
  } catch (error) {
    console.error('CNIB VALIDATION ERROR:', error);
    return {
      isValid: false,
      message: 'Impossible de valider le document. Veuillez vérifier que l\'image est claire et lisible.'
    };
  } finally {
    try {
      await worker.terminate();
    } catch (e) {
      // ignore termination errors
    }
  }
};

/**
 * Middleware pour valider les uploads CNIB
 * À utiliser après multer pour valider les images uploadées
 */
const validateCNIBUpload = async (req, res, next) => {
  if (!req.file) {
    return next();
  }

  // Vérifier que c'est une image
  const imageExtensions = ['.jpg', '.jpeg', '.png'];
  const ext = path.extname(req.file.originalname).toLowerCase();

  if (!imageExtensions.includes(ext)) {
    // Supprimer le fichier si ce n'est pas une image
    fs.unlink(req.file.path, (err) => {
      if (err) console.error('Failed to remove invalid file:', err);
    });
    return res.status(400).json({
      success: false,
      message: 'Seules les images JPG et PNG sont acceptées pour les documents d\'identité.',
      error: 'INVALID_FILE_TYPE'
    });
  }

  // Valider par OCR que c'est une CNIB
  const validation = await validateCNIBImageViaOCR(req.file.path);

  if (!validation.isValid) {
    // Supprimer le fichier si la validation échoue
    fs.unlink(req.file.path, (err) => {
      if (err) console.error('Failed to remove invalid CNIB:', err);
    });
    return res.status(400).json({
      success: false,
      message: validation.message,
      error: 'DOCUMENT_TYPE_NOT_SUPPORTED'
    });
  }

  // Passer au middleware suivant avec validation réussie
  req.cnibValidated = true;
  next();
};

module.exports = {
  isCNIBDocument,
  validateCNIBImageViaOCR,
  validateCNIBUpload
};
