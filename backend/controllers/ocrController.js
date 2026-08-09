const fs = require('fs');
const { createWorker } = require('tesseract.js');
const { compareOcrData } = require('../utils/ocrCompare');

/**
 * Valide si le texte extrait provient d'une Carte Nationale d'Identité (CNIB)
 * @param {string} text - Texte extrait par OCR
 * @returns {object} Validation result with success boolean and message
 */
const validateCNIBDocument = (text) => {
  if (!text || typeof text !== 'string') {
    return {
      isValid: false,
      message: 'Aucun texte détecté dans l\'image. Veuillez fournir une image claire.'
    };
  }

  // Normaliser le texte pour la comparaison
  const normalizedText = text.toLowerCase().trim();

  // Indicateurs clés d'une CNIB/CNI/Carte d'identité
  const cnibIndicators = [
    'carte nationale',
    'carte d\'identite',
    'carte d\'identité',
    'cnib',
    'cni',
    'identité',
    'identite'
  ];

  // Vérifier si le texte contient au moins un indicateur d'une CNI
  const hasCNIIndicator = cnibIndicators.some(indicator => normalizedText.includes(indicator));

  if (!hasCNIIndicator) {
    return {
      isValid: false,
      message: 'Cette image n\'est pas une Carte Nationale d\'Identité. Veuillez fournir une image de CNIB valide (recto ou verso).'
    };
  }

  // Vérifier si le document a des éléments typiques d'une CNIB:
  // - Numéro de pièce (pattern alphanumeric)
  // - Date (format DD/MM/YYYY ou DD-MM-YYYY)
  // - Nom et prénom
  const datePattern = /\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}/;
  const hasDatePattern = datePattern.test(text);

  // Pattern pour détecter un numéro de pièce d'identité (généralement commençant par des lettres)
  const identityNumberPattern = /[A-Z]{2}\d+|N°|numéro|numero|num\b/i;
  const hasIdentityNumber = identityNumberPattern.test(text);

  // Un minimum d'indicateurs doit être présent
  const indicatorCount = (hasCNIIndicator ? 1 : 0) + (hasDatePattern ? 1 : 0) + (hasIdentityNumber ? 1 : 0);

  if (indicatorCount < 2) {
    return {
      isValid: false,
      message: 'L\'image fournie ne semble pas être une Carte d\'Identité valide. Assurez-vous que l\'image est claire et contient tous les éléments de la CNIB.'
    };
  }

  return {
    isValid: true,
    message: 'Image de CNIB validée avec succès'
  };
};

const verifyDocumentData = async (req, res) => {
  try {
    const { userData, ocrData } = req.body;

    if (!userData || !ocrData) {
      return res.status(422).json({
        success: false,
        message: 'userData et ocrData sont requis dans le corps de la requête'
      });
    }

    const comparison = compareOcrData(userData, ocrData);

    return res.json({
      success: true,
      comparison
    });
  } catch (error) {
    console.error('OCR VERIFICATION ERROR:', error);
    return res.status(500).json({
      success: false,
      message: 'Erreur lors de la comparaison OCR',
      error: error.message
    });
  }
};

const extractDocumentText = async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, message: 'Aucun fichier image reçu.' });
  }

  const filePath = req.file.path;
  const worker = await createWorker({
    errorHandler: (error) => {
      console.error('TESSERACT WORKER ERROR:', error);
    }
  });

  try {
    // Basic validation: check file magic bytes to ensure it's PNG or JPEG
    const buf = fs.readFileSync(filePath);
    const isJpeg = buf.length >= 3 && buf[0] === 0xFF && buf[1] === 0xD8 && buf[2] === 0xFF;
    const isPng = buf.length >= 8 && buf[0] === 0x89 && buf[1] === 0x50 && buf[2] === 0x4E && buf[3] === 0x47;
    if (!isJpeg && !isPng) {
      // remove file and reject
      fs.unlink(filePath, (err) => {
        if (err) console.error('Failed to remove invalid upload:', err);
      });
      return res.status(400).json({ success: false, message: 'Format de fichier invalide. JPG ou PNG requis.' });
    }

    await worker.load();
    await worker.loadLanguage('fra');
    await worker.initialize('fra');

    const buffer = fs.readFileSync(filePath);
    const { data } = await worker.recognize(buffer);
    const extractedText = data.text || '';

    // Valider que le document est une CNIB
    const validation = validateCNIBDocument(extractedText);
    
    if (!validation.isValid) {
      // Rejeter l'image qui n'est pas une CNIB
      return res.status(400).json({
        success: false,
        message: validation.message,
        error: 'DOCUMENT_TYPE_NOT_SUPPORTED'
      });
    }

    return res.json({
      success: true,
      text: extractedText,
      message: validation.message
    });
  } catch (error) {
    console.error('OCR EXTRACTION ERROR:', error);
    return res.status(500).json({ success: false, message: 'Impossible d’extraire le texte OCR', error: error.message });
  } finally {
    // ensure worker termination and clean up file
    try {
      await worker.terminate();
    } catch (e) {
      // ignore termination errors
    }
    fs.unlink(filePath, (err) => {
      if (err) console.error('Failed to remove temp file:', filePath, err);
    });
  }
};

module.exports = {
  verifyDocumentData,
  extractDocumentText
};
