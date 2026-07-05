const fs = require('fs');
const path = require('path');
const { Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType, BorderStyle, Table, TableRow, TableCell, WidthType, ImageRun, ShadingType, PageBreak } = require('docx');

const outputPath = path.join(process.cwd(), 'documentation_application_job.docx');
const screenshotPath = path.join(process.cwd(), 'screenshots', 'app_home.png');

const doc = new Document({
  sections: [{
    properties: {},
    children: [
      new Paragraph({
        children: [new TextRun({ text: 'Documentation de l’application Job Research', bold: true, size: 28 })],
        spacing: { after: 240 },
        alignment: AlignmentType.CENTER,
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Présentation générale', bold: true, size: 24 })],
        spacing: { before: 120, after: 120 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Cette application est une plateforme de recherche d’emploi et de mise en relation entre candidats et recruteurs. Elle permet de consulter des offres, d’envoyer des candidatures, de communiquer, de gérer les profils et d’accéder à des fonctionnalités avancées telles que les notifications, l’upload de documents et la gestion des abonnements.' })],
        spacing: { after: 160 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Fonctionnalités principales', bold: true, size: 24 })],
        spacing: { before: 120, after: 120 },
      }),
      new Paragraph({
        children: [new TextRun({ text: '1. Authentification et gestion des comptes', bold: true })],
        spacing: { after: 80 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'L’application permet à un utilisateur de créer un compte, de se connecter et de gérer son profil. Les comptes sont associés à un rôle, candidat ou entreprise, afin de restreindre certaines actions selon le type d’utilisateur.' })],
        spacing: { after: 160 },
      }),
      new Paragraph({
        children: [new TextRun({ text: '2. Consultation des offres d’emploi', bold: true })],
        spacing: { after: 80 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Les utilisateurs peuvent parcourir les offres disponibles, consulter les détails, et postuler directement depuis l’interface. Cette partie est au cœur de l’expérience utilisateur.' })],
        spacing: { after: 160 },
      }),
      new Paragraph({
        children: [new TextRun({ text: '3. Gestion des candidatures', bold: true })],
        spacing: { after: 80 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Le système permet de suivre les candidatures, de visualiser leur état et d’interagir avec les recruteurs. Cela améliore la traçabilité et la fluidité du processus de recrutement.' })],
        spacing: { after: 160 },
      }),
      new Paragraph({
        children: [new TextRun({ text: '4. Messagerie et échanges', bold: true })],
        spacing: { after: 80 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'L’application intègre une logique de messagerie pour faciliter les échanges entre candidats et entreprises. Cette fonctionnalité favorise une communication directe et rapide.' })],
        spacing: { after: 160 },
      }),
      new Paragraph({
        children: [new TextRun({ text: '5. Notifications en temps réel', bold: true })],
        spacing: { after: 80 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Les utilisateurs reçoivent des notifications relatives à leurs actions, à l’évolution des candidatures et aux événements importants. Les notifications sont visibles depuis la barre de navigation.' })],
        spacing: { after: 160 },
      }),
      new Paragraph({
        children: [new TextRun({ text: '6. Upload de documents et de photos', bold: true })],
        spacing: { after: 80 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'L’application permet d’ajouter des documents, des photos de profil et de gérer leur affichage. Cette fonction est utile pour personnaliser les comptes et transmettre des informations complémentaires.' })],
        spacing: { after: 160 },
      }),
      new Paragraph({
        children: [new TextRun({ text: '7. Abonnement et accès premium', bold: true })],
        spacing: { after: 80 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Certaines sections sont protégées selon l’abonnement actif. Cela permet d’offrir un accès différencié et d’encadrer l’utilisation de fonctionnalités sensibles.' })],
        spacing: { after: 200 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Capture d’écran de l’interface principale', bold: true, size: 20 })],
        spacing: { before: 120, after: 120 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'La capture ci-dessous montre la page d’accueil de l’application et l’organisation générale de l’interface utilisateur.' })],
        spacing: { after: 120 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Vue d’ensemble de l’interface', bold: true })],
        spacing: { after: 80 },
      }),
      new Paragraph({
        children: [
          new ImageRun({
            data: fs.readFileSync(screenshotPath),
            transformation: { width: 450, height: 250 },
          })
        ],
        alignment: AlignmentType.CENTER,
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Résumé fonctionnel', bold: true, size: 24 })],
        spacing: { before: 180, after: 120 },
      }),
      new Table({
        rows: [
          new TableRow({
            children: [
              new TableCell({ children: [new Paragraph({ children: [new TextRun({ text: 'Fonctionnalité', bold: true })] })], shading: { fill: 'D9EAF7' } }),
              new TableCell({ children: [new Paragraph({ children: [new TextRun({ text: 'Description', bold: true })] })], shading: { fill: 'D9EAF7' } }),
            ],
          }),
          new TableRow({
            children: [
              new TableCell({ children: [new Paragraph({ text: 'Authentification' })] }),
              new TableCell({ children: [new Paragraph({ text: 'Connexion, inscription et gestion des profils.' })] }),
            ],
          }),
          new TableRow({
            children: [
              new TableCell({ children: [new Paragraph({ text: 'Offres' })] }),
              new TableCell({ children: [new Paragraph({ text: 'Consultation et candidature aux offres d’emploi.' })] }),
            ],
          }),
          new TableRow({
            children: [
              new TableCell({ children: [new Paragraph({ text: 'Notifications' })] }),
              new TableCell({ children: [new Paragraph({ text: 'Alertes et suivi des événements importants.' })] }),
            ],
          }),
          new TableRow({
            children: [
              new TableCell({ children: [new Paragraph({ text: 'Documents' })] }),
              new TableCell({ children: [new Paragraph({ text: 'Upload, visualisation et gestion des fichiers.' })] }),
            ],
          }),
        ],
        width: { size: 100, type: WidthType.PERCENTAGE },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Conclusion', bold: true, size: 24 })],
        spacing: { before: 180, after: 120 },
      }),
      new Paragraph({
        children: [new TextRun({ text: 'Cette application propose une expérience complète pour la recherche d’emploi, avec un accès simple aux offres, une gestion claire des candidatures et des fonctionnalités modernes orientées utilisateur.' })],
        spacing: { after: 120 },
      }),
    ],
  }],
});

(async () => {
  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync(outputPath, buffer);
  console.log(`Document créé : ${outputPath}`);
})();
