const fs = require('fs');
const path = require('path');
const {
  Document,
  Packer,
  Paragraph,
  TextRun,
  HeadingLevel,
  AlignmentType,
  Table,
  TableRow,
  TableCell,
  WidthType,
  ImageRun,
  PageBreak,
} = require('docx');

const outputPath = path.join(process.cwd(), 'documentation_application_job.docx');
const screenshotPath = path.join(process.cwd(), 'screenshots', 'app_home.png');

const doc = new Document({
  sections: [
    {
      properties: {},
      children: [
        new Paragraph({
          text: 'Documentation de l’application Job Research',
          heading: HeadingLevel.TITLE,
          alignment: AlignmentType.CENTER,
          spacing: { after: 240 },
        }),

        new Paragraph({ text: 'Chapitre 1 : Présentation générale', heading: HeadingLevel.HEADING_1, spacing: { after: 120 } }),
        new Paragraph({ text: 'Job Research est une application de mise en relation entre candidats et entreprises. Elle fournit un espace sécurisé pour s’inscrire, se connecter, gérer un profil, consulter des offres, envoyer des candidatures, échanger des messages et recevoir des notifications en temps réel.' }),
        new Paragraph({ text: 'Le système distingue les rôles suivants :', spacing: { before: 120, after: 80 } }),
        new Paragraph({ text: '• Candidat : recherche des offres, postule, gère son profil et ses documents.', bullet: { level: 0 } }),
        new Paragraph({ text: '• Entreprise : publie des offres, consulte les candidatures et communique avec les candidats.', bullet: { level: 0 } }),
        new Paragraph({ text: '• Administrateur : supervise la plateforme, gère les utilisateurs et les offres.', bullet: { level: 0 } }),
        new Paragraph({ text: 'L’application intègre les modules suivants : authentification, offre d’emploi, candidature, messagerie, notifications, upload de fichiers, gestion de profil et administration.', spacing: { after: 160 } }),

        new Paragraph({ text: 'Chapitre 2 : Fonctionnement et flux principaux', heading: HeadingLevel.HEADING_1, spacing: { before: 180, after: 120 } }),
        new Paragraph({ text: '2.1 Inscription et connexion' }),
        new Paragraph({ text: 'Lorsqu’un utilisateur s’inscrit, il fournit un email, un mot de passe et des informations supplémentaires selon son rôle. Le backend valide les données puis crée un compte dans la base. Lors de la connexion, l’utilisateur envoie ses identifiants au backend qui renvoie un jeton d’authentification en cas de succès.' }),
        new Paragraph({ text: '2.2 Consultation des offres' }),
        new Paragraph({ text: 'Les offres sont récupérées depuis l’API et affichées dans une liste. L’utilisateur peut filtrer et sélectionner une offre pour en voir les détails et postuler.' }),
        new Paragraph({ text: '2.3 Candidature et suivi' }),
        new Paragraph({ text: 'Une candidature est envoyée via un appel API. Le système peut enregistrer l’état de la candidature, permettre au recruteur de la consulter et mettre à jour le statut.' }),
        new Paragraph({ text: '2.4 Messagerie et notifications' }),
        new Paragraph({ text: 'La messagerie permet l’échange direct entre candidats et entreprises. Les notifications alertent l’utilisateur lorsqu’une action importante survient, comme une nouvelle offre ou un message reçu.' }),
        new Paragraph({ text: '2.5 Upload de documents' }),
        new Paragraph({ text: 'Le candidat ou l’entreprise peut téléverser des documents et des photos de profil. Ces fichiers sont stockés et accessibles via l’interface, et utilisés pour enrichir le profil ou compléter une candidature.' }),

        new Paragraph({ text: 'Chapitre 3 : Diagrammes', heading: HeadingLevel.HEADING_1, spacing: { before: 180, after: 120 } }),
        new Paragraph({ text: '3.1 Diagramme de classes', heading: HeadingLevel.HEADING_2, spacing: { after: 120 } }),
        new Paragraph({ text: 'Classes principales :', spacing: { after: 80 } }),
        new Paragraph({ text: '• Utilisateur (id, email, motDePasse, role, nom, telephone, type, statut, token)', bullet: { level: 0 } }),
        new Paragraph({ text: '• Offre (id, titre, description, entrepriseId, lieu, typeContrat, salaire)', bullet: { level: 0 } }),
        new Paragraph({ text: '• Candidature (id, offreId, candidatId, statut, dateSoumission)', bullet: { level: 0 } }),
        new Paragraph({ text: '• Message (id, conversationId, expediteurId, destinataireId, contenu, dateEnvoi)', bullet: { level: 0 } }),
        new Paragraph({ text: '• Notification (id, utilisateurId, titre, message, lu, date)', bullet: { level: 0 } }),
        new Paragraph({ text: '• Document (id, utilisateurId, type, url, dateUpload)', bullet: { level: 0 } }),
        new Paragraph({ text: 'Relations : un utilisateur peut avoir plusieurs offres (si entreprise), plusieurs candidatures, plusieurs messages et notifications.', spacing: { after: 160 } }),
        new Paragraph({ text: '3.2 Diagramme de cas d’utilisation', heading: HeadingLevel.HEADING_2, spacing: { after: 120 } }),
        new Paragraph({ text: 'Cas d’utilisation principaux :', spacing: { after: 80 } }),
        new Paragraph({ text: '• S’inscrire', bullet: { level: 0 } }),
        new Paragraph({ text: '• Se connecter', bullet: { level: 0 } }),
        new Paragraph({ text: '• Consulter les offres', bullet: { level: 0 } }),
        new Paragraph({ text: '• Postuler à une offre', bullet: { level: 0 } }),
        new Paragraph({ text: '• Envoyer un message', bullet: { level: 0 } }),
        new Paragraph({ text: '• Gérer son profil', bullet: { level: 0 } }),
        new Paragraph({ text: '• Recevoir des notifications', bullet: { level: 0 } }),
        new Paragraph({ text: '• Gérer les utilisateurs et les offres (admin)', bullet: { level: 0 } }),
        new Paragraph({ text: 'Ce diagramme montre les acteurs : Candidat, Entreprise, Administrateur et Système.', spacing: { after: 160 } }),
        new Paragraph({ text: '3.3 Diagramme de séquence', heading: HeadingLevel.HEADING_2, spacing: { after: 120 } }),
        new Paragraph({ text: 'Exemple : séquence de connexion', spacing: { after: 80 } }),
        new Paragraph({ text: '1. L’utilisateur saisit son email et son mot de passe dans l’application.', bullet: { level: 0 } }),
        new Paragraph({ text: '2. Le client envoie la requête POST /api/auth/login au backend.', bullet: { level: 0 } }),
        new Paragraph({ text: '3. Le backend valide les informations puis interroge la base de données.', bullet: { level: 0 } }),
        new Paragraph({ text: '4. Le backend renvoie un jeton d’authentification et les données utilisateur.', bullet: { level: 0 } }),
        new Paragraph({ text: '5. Le client stocke le jeton et redirige l’utilisateur vers le tableau de bord approprié.', bullet: { level: 0 } }),
        new Paragraph({ text: 'Ce flux illustre l’interaction entre l’utilisateur, le front-end, le back-end et la base de données.', spacing: { after: 160 } }),

        new Paragraph({ text: 'Chapitre 4 : Captures nécessaires et scénarios', heading: HeadingLevel.HEADING_1, spacing: { before: 180, after: 120 } }),
        new Paragraph({ text: 'Les captures essentielles couvrent les usages suivants :', spacing: { after: 80 } }),
        new Paragraph({ text: '• Page d’inscription / connexion', bullet: { level: 0 } }),
        new Paragraph({ text: '• Tableau de bord candidat', bullet: { level: 0 } }),
        new Paragraph({ text: '• Tableau de bord entreprise', bullet: { level: 0 } }),
        new Paragraph({ text: '• Page de détails d’une offre', bullet: { level: 0 } }),
        new Paragraph({ text: '• Page de messagerie', bullet: { level: 0 } }),
        new Paragraph({ text: '• Interface de gestion des documents', bullet: { level: 0 } }),
        new Paragraph({ text: '• Page d’administration', bullet: { level: 0 } }),
        new Paragraph({ text: 'Ces captures permettent de documenter les parcours utilisateurs et de vérifier la conformité des écrans avec les exigences fonctionnelles.', spacing: { after: 160 } }),
        new Paragraph({ text: 'Capture de l’interface principale', bold: true, size: 20, spacing: { before: 120, after: 120 } }),
        new Paragraph({
          children: [
            new ImageRun({
              data: fs.readFileSync(screenshotPath),
              transformation: { width: 500, height: 280 },
            }),
          ],
          alignment: AlignmentType.CENTER,
        }),
        new Paragraph({ text: 'Le screenshot ci-dessus montre l’écran d’accueil avec le formulaire de connexion, les onglets de rôle et une identité visuelle sombre.', spacing: { after: 160 } }),
        new Paragraph({ text: 'Conclusion', heading: HeadingLevel.HEADING_1, spacing: { before: 180, after: 120 } }),
        new Paragraph({ text: 'Ce document présente les principaux chapitres de l’application Job Research, son fonctionnement, ses diagrammes de conception et les captures essentielles. Il peut servir de livrable pour une soutenance ou une revue fonctionnelle.', spacing: { after: 120 } }),
      ],
    },
  ],
});

(async () => {
  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync(outputPath, buffer);
  console.log(`Document créé : ${outputPath}`);
})();
