const fs = require('fs');
const fetch = global.fetch || require('node-fetch');
(async () => {
  try {
    const regRes = await fetch('http://127.0.0.1:3001/api/auth/register', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        email: 'test.upload1@example.com',
        password: 'Password123',
        userType: 'candidat',
        nom: 'Test Upload',
        telephone: '0700000000',
        age: '25',
        domicile: 'Dakar',
        filiere: 'Informatique',
        sexe: 'Masculin'
      })
    });
    console.log('register status', regRes.status);
    console.log(await regRes.text());
  } catch (err) {
    console.error(err);
  }
})();
