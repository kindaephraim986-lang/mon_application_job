const fs = require('fs');
const path = require('path');

const root = 'c:\\Users\\SYST\\Desktop\\Job_Research';
const outputDocx = path.join(root, 'Rapport_soutenance_JobResearch.docx');
const tmpDir = path.join(root, 'report_docx_tmp');
const mediaDir = path.join(tmpDir, 'word', 'media');
const wordDir = path.join(tmpDir, 'word');
const relsDir = path.join(tmpDir, '_rels');
const wordRelsDir = path.join(wordDir, '_rels');

fs.rmSync(tmpDir, { recursive: true, force: true });
fs.mkdirSync(mediaDir, { recursive: true });
fs.mkdirSync(wordRelsDir, { recursive: true });
fs.mkdirSync(relsDir, { recursive: true });

const screenshot = path.join(root, 'screenshots', 'app_home.png');
if (!fs.existsSync(screenshot)) {
  console.error('Screenshot introuvable:', screenshot);
  process.exit(1);
}
fs.copyFileSync(screenshot, path.join(mediaDir, 'app_home.png'));

const escapeXml = (value) => String(value)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/\"/g, '&quot;');

const documentXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p>
      <w:pPr><w:pStyle w:val="Title"/></w:pPr>
      <w:r><w:t>Rapport de soutenance</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr><w:pStyle w:val="Subtitle"/></w:pPr>
      <w:r><w:t>Application de recherche d’emploi – Job Research</w:t></w:r>
    </w:p>
    <w:p><w:r><w:t>Présenté par : KINDA</w:t></w:r></w:p>
    <w:p><w:r><w:t>Date : 05 juillet 2026</w:t></w:r></w:p>
    <w:p><w:r><w:t> </w:t></w:r></w:p>

    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <w:r><w:t>1. Introduction</w:t></w:r>
    </w:p>
    <w:p><w:r><w:t>Cette application a été développée dans le but de faciliter la mise en relation entre les candidats à la recherche d’emploi et les entreprises à la recherche de profils qualifiés. Elle propose une expérience utilisateur fluide, une inscription simple et des interfaces dédiées pour chaque type d’utilisateur.</w:t></w:r></w:p>
    <w:p><w:r><w:t>L’objectif principal est de fournir une plateforme moderne, accessible et fonctionnelle, capable de couvrir les besoins essentiels de la recherche d’emploi en ligne : création de compte, connexion, consultation d’offres, candidature, gestion de profil et administration.</w:t></w:r></w:p>

    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <w:r><w:t>2. Présentation du projet</w:t></w:r>
    </w:p>
    <w:p><w:r><w:t>Le projet Job Research combine un frontend Flutter Web et un backend Node.js/Express avec une base de données MySQL. Cette architecture permet de garantir une meilleure évolutivité, une maintenance simplifiée et une séparation claire entre la logique métier et l’interface utilisateur.</w:t></w:r></w:p>
    <w:p><w:r><w:t>Le système permet aux utilisateurs de s’inscrire selon leur profil, de se connecter de façon sécurisée, de consulter des offres d’emploi, de postuler et d’accéder à des tableaux de bord adaptés à leur rôle.</w:t></w:r></w:p>

    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <w:r><w:t>3. Fonctionnalités principales</w:t></w:r>
    </w:p>
    <w:p><w:r><w:t>• Inscription et connexion sécurisées</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Interface dédiée pour les candidats</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Interface dédiée pour les entreprises</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Tableau de bord administrateur</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Gestion des offres et des candidatures</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Messagerie, notifications et gestion de profil</w:t></w:r></w:p>

    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <w:r><w:t>4. Interfaces de l’application</w:t></w:r>
    </w:p>
    <w:p><w:r><w:t>4.1 Page d’authentification</w:t></w:r></w:p>
    <w:p><w:r><w:t>La page d’authentification permet à l’utilisateur de se connecter à son espace ou de créer un nouveau compte selon son statut. Elle représente la porte d’entrée de l’application et assure l’accès aux interfaces adaptées au profil.</w:t></w:r></w:p>
    <w:p><w:r><w:t>4.2 Interface candidat</w:t></w:r></w:p>
    <w:p><w:r><w:t>Le tableau de bord candidat permet de consulter les offres, de gérer son profil, de suivre ses candidatures et de recevoir des notifications importantes. L’interface a été pensée pour offrir une navigation simple et intuitive.</w:t></w:r></w:p>
    <w:p><w:r><w:t>4.3 Interface entreprise</w:t></w:r></w:p>
    <w:p><w:r><w:t>Le tableau de bord entreprise permet de visualiser les profils des candidats, de gérer les offres d’emploi et d’interagir avec les demandes de recrutement. Cette interface est conçue pour répondre aux besoins des recruteurs.</w:t></w:r></w:p>
    <w:p><w:r><w:t>4.4 Interface administrateur</w:t></w:r></w:p>
    <w:p><w:r><w:t>L’interface administrateur offre une vue d’ensemble du système. Elle permet de superviser les utilisateurs, les offres et les candidatures, ainsi que de garantir une bonne gestion du fonctionnement de la plateforme.</w:t></w:r></w:p>

    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <w:r><w:t>5. Capture d’écran de l’interface</w:t></w:r>
    </w:p>
    <w:p><w:r><w:t>La capture ci-dessous illustre l’interface de l’application ouverte dans le navigateur. Elle montre la première vue de l’application et son caractère moderne et accessible.</w:t></w:r></w:p>
    <w:p>
      <w:r>
        <w:drawing>
          <wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" distT="0" distB="0" distL="0" distR="0">
            <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:nvPicPr>
                    <pic:cNvPr id="0" name="Capture application"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="rId1" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>
                    <a:stretch><a:fillRect/></a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm><a:off x="0" y="0"/><a:ext cx="18288000" cy="10287000"/></a:xfrm>
                    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
                  </pic:spPr>
                </pic:pic>
              </a:graphicData>
            </a:graphic>
          </wp:inline>
        </w:drawing>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>Figure 1 : Capture de l’interface principale de l’application.</w:t></w:r></w:p>

    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <w:r><w:t>6. Conclusion</w:t></w:r>
    </w:p>
    <w:p><w:r><w:t>Ce projet constitue une base solide pour une plateforme de recherche d’emploi moderne. Il répond aux besoins essentiels des différents profils utilisateurs et offre une expérience pratique, intuitive et orientée vers l’efficacité. Les perspectives d’évolution sont nombreuses, notamment l’ajout de fonctionnalités avancées et l’amélioration continue de l’ergonomie.</w:t></w:r></w:p>

    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="708" w:footer="708" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>`;

const contentTypesXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/media/app_home.png" ContentType="image/png"/>
</Types>`;

const relsXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>`;

const documentRelsXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/app_home.png"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>`;

const stylesXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:after="120"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:after="240"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="28"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle">
    <w:name w:val="Subtitle"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:after="180"/></w:pPr>
    <w:rPr><w:i/><w:sz w:val="24"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="240" w:after="120"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="26"/></w:rPr>
  </w:style>
</w:styles>`;

fs.writeFileSync(path.join(tmpDir, '[Content_Types].xml'), contentTypesXml);
fs.writeFileSync(path.join(relsDir, '.rels'), relsXml);
fs.writeFileSync(path.join(wordDir, 'document.xml'), documentXml);
fs.writeFileSync(path.join(wordRelsDir, 'document.xml.rels'), documentRelsXml);
fs.writeFileSync(path.join(wordDir, 'styles.xml'), stylesXml);

const { spawnSync } = require('child_process');
const archiveCmd = process.platform === 'win32' ? 'powershell' : 'zip';
if (process.platform === 'win32') {
  const args = [
    '-NoProfile', '-Command',
    `Compress-Archive -Path '${path.join(tmpDir, '*')}' -DestinationPath '${outputDocx}' -Force`
  ];
  const result = spawnSync(archiveCmd, args, { stdio: 'inherit' });
  if (result.status !== 0) process.exit(result.status || 1);
} else {
  const result = spawnSync('zip', ['-rq', outputDocx, '.'], { cwd: tmpDir, stdio: 'inherit' });
  if (result.status !== 0) process.exit(result.status || 1);
}

console.log('DOCX généré:', outputDocx);
