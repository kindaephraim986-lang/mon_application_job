const http = require('http');
const mysql = require('mysql2/promise');
const jwt = require('jsonwebtoken');

const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const DB_CONFIG = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'bddiane_sp',
};

const API_HOST = process.env.API_HOST || 'localhost';
const API_PORT = process.env.API_PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'afrijob_dev_secret';

async function httpRequest(path, method = 'GET', token = null, body = null) {
  const options = {
    hostname: API_HOST,
    port: API_PORT,
    path,
    method,
    headers: {}
  };
  if (token) options.headers['Authorization'] = `Bearer ${token}`;
  if (body) {
    const content = JSON.stringify(body);
    options.headers['Content-Type'] = 'application/json';
    options.headers['Content-Length'] = Buffer.byteLength(content);
  }

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        let parsed = null;
        try { parsed = JSON.parse(data); } catch (e) { parsed = data; }
        resolve({ statusCode: res.statusCode, body: parsed });
      });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

function randomEmail(prefix = 'test') {
  const timestamp = Date.now();
  return `${prefix}_${timestamp}@example.com`;
}

async function testRegistration(conn) {
  const email = randomEmail('test_register');
  const password = 'Password123!';
  const registerBody = {
    email,
    password,
    userType: 'candidat',
    nom: 'Test Candidat',
    telephone: '+22670000000',
    filiere: 'Développement',
    age: '25',
    domicile: 'Ouagadougou',
    sexe: 'Masculin'
  };

  console.log('Testing POST /api/auth/register with email', email);
  const registerResp = await httpRequest('/api/auth/register', 'POST', null, registerBody);
  console.log('Register response:', registerResp.statusCode, registerResp.body);

  if (registerResp.statusCode !== 201) {
    throw new Error(`Registration request failed with ${registerResp.statusCode}`);
  }
  if (!registerResp.body || !registerResp.body.user || !registerResp.body.user.id) {
    throw new Error('Registration response missing expected user data');
  }

  const userId = registerResp.body.user.id;
  const [userRows] = await conn.execute('SELECT * FROM utilisateurs WHERE id = ? AND email = ?', [userId, email]);
  if (userRows.length !== 1) {
    throw new Error('No matching utilisateur row found after registration');
  }

  const [candidateRows] = await conn.execute('SELECT * FROM candidats WHERE id = ?', [userId]);
  if (candidateRows.length !== 1) {
    throw new Error('No matching candidat row found after registration');
  }

  console.log('Registration test succeeded:', email, '-> user id', userId);

  await conn.execute('DELETE FROM candidats WHERE id = ?', [userId]);
  await conn.execute('DELETE FROM utilisateurs WHERE id = ?', [userId]);
}

(async () => {
  const conn = await mysql.createConnection(DB_CONFIG);
  console.log('Connected to DB for tests');
  await testRegistration(conn);

  // Create or reuse entreprise user
  let [rows] = await conn.execute('SELECT id FROM utilisateurs WHERE email = ?', ['test_ent@example.com']);
  let entrepriseId;
  if (rows.length > 0) {
    entrepriseId = rows[0].id;
    console.log('Reusing existing entreprise user', entrepriseId);
  } else {
    const [resUserEnt] = await conn.execute(
      'INSERT INTO utilisateurs (email, mot_de_passe, type_utilisateur) VALUES (?, ?, ?)',
      ['test_ent@example.com', 'testpass', 'entreprise']
    );
    entrepriseId = resUserEnt.insertId;
    await conn.execute(
      'INSERT INTO entreprises (id, nom_societe, domaine_activite) VALUES (?, ?, ?)',
      [entrepriseId, 'Test Entreprise', 'Tech']
    );
    console.log('Created entreprise', entrepriseId);
  }

  // Create or reuse candidat user
  [rows] = await conn.execute('SELECT id FROM utilisateurs WHERE email = ?', ['test_cand@example.com']);
  let candidatId;
  if (rows.length > 0) {
    candidatId = rows[0].id;
    console.log('Reusing existing candidat user', candidatId);
  } else {
    const [resUserCand] = await conn.execute(
      'INSERT INTO utilisateurs (email, mot_de_passe, type_utilisateur) VALUES (?, ?, ?)',
      ['test_cand@example.com', 'testpass', 'candidat']
    );
    candidatId = resUserCand.insertId;
    await conn.execute(
      'INSERT INTO candidats (id, nom_complet) VALUES (?, ?)',
      [candidatId, 'Test Candidat']
    );
    console.log('Created candidat', candidatId);
  }

  // Create or reuse an offer
  [rows] = await conn.execute('SELECT id FROM offres WHERE titre = ? AND entreprise_id = ?', ['Offre Test', entrepriseId]);
  let offreId;
  if (rows.length > 0) {
    offreId = rows[0].id;
    console.log('Reusing existing offre', offreId);
  } else {
    const [resOffer] = await conn.execute(
      `INSERT INTO offres (entreprise_id, titre, description) VALUES (?, ?, ?)`,
      [entrepriseId, 'Offre Test', 'Description test']
    );
    offreId = resOffer.insertId;
    console.log('Created offre', offreId);
  }

  // Generate token for candidat
  const token = jwt.sign({ id: candidatId }, JWT_SECRET, { expiresIn: '1d' });
  console.log('Generated token for candidat:', token);

  // 1) Call payments/apply if table exists
  const [tables] = await conn.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ?", [DB_CONFIG.database]);
  const tableNames = tables.map(r => r.TABLE_NAME);
  // If candidature_paiements table is missing, try to create it from migration SQL
  if (!tableNames.includes('candidature_paiements')) {
    console.log('candidature_paiements table missing — applying migration SQL');
    const fs = require('fs');
    const migrationPath = path.join(__dirname, '..', 'migrations', '001_add_candidature_paiements_table.sql');
    if (fs.existsSync(migrationPath)) {
      const sql = fs.readFileSync(migrationPath, 'utf8');
      try {
        await conn.query(sql);
        console.log('Migration applied: candidature_paiements created');
      } catch (e) {
        console.warn('Failed to apply migration SQL:', e.message);
      }
      // refresh table list
      const [tables2] = await conn.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ?", [DB_CONFIG.database]);
      tableNames.length = 0; tables2.forEach(r => tableNames.push(r.TABLE_NAME));
    } else {
      console.warn('Migration file not found:', migrationPath);
    }
  }
  if (tableNames.includes('candidature_paiements')) {
    console.log('Calling POST /api/payments/apply');
    const payResp = await httpRequest('/api/payments/apply', 'POST', token, { offreId, montant: 500, methode_paiement: 'mobile_money' });
    console.log('Payment response:', payResp.statusCode, payResp.body);

    // Verify in DB
    const [payments] = await conn.execute(
      'SELECT * FROM candidature_paiements WHERE candidat_id = ? AND offre_id = ?',
      [candidatId, offreId]
    );
    console.log('DB candidature_paiements rows:', payments.length);
  } else {
    console.log('Skipping payment test: table candidature_paiements does not exist');
  }

  // 2) Call applications POST
  console.log('Calling POST /api/applications');
  const appResp = await httpRequest('/api/applications', 'POST', token, { offreId });
  console.log('Application response:', appResp.statusCode, appResp.body);

  const [apps] = await conn.execute(
    'SELECT * FROM candidatures WHERE candidat_id = ? AND offre_id = ?',
    [candidatId, offreId]
  );
  console.log('DB candidatures rows:', apps.length);

  // Cleanup: delete created records (only if the tables exist)
  if (tableNames.includes('candidatures')) {
    await conn.execute('DELETE FROM candidatures WHERE candidat_id = ? AND offre_id = ?', [candidatId, offreId]);
  }
  if (tableNames.includes('candidature_paiements')) {
    await conn.execute('DELETE FROM candidature_paiements WHERE candidat_id = ? AND offre_id = ?', [candidatId, offreId]);
  }
  if (tableNames.includes('offres')) {
    await conn.execute('DELETE FROM offres WHERE id = ?', [offreId]);
  }
  if (tableNames.includes('entreprises')) {
    await conn.execute('DELETE FROM entreprises WHERE id = ?', [entrepriseId]);
  }
  if (tableNames.includes('candidats')) {
    await conn.execute('DELETE FROM candidats WHERE id = ?', [candidatId]);
  }
  if (tableNames.includes('utilisateurs')) {
    await conn.execute('DELETE FROM utilisateurs WHERE id IN (?, ?)', [entrepriseId, candidatId]);
  }

  console.log('Cleanup done');
  await conn.end();
})().catch(err => {
  console.error('Test error:', err);
  process.exit(1);
});
