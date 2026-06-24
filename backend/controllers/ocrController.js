const fs = require('fs');
const { createWorker } = require('tesseract.js');
const { compareOcrData } = require('../utils/ocrCompare');

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

    return res.json({
      success: true,
      text: data.text || ''
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
