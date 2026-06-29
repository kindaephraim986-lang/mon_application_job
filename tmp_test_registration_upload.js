const fs = require('fs');
const path = require('path');
(async () => {
  try {
    const regRes = await fetch('http://127.0.0.1:3001/api/auth/register', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        email: `test.upload.${Date.now()}@example.com`,
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
    const regBody = await regRes.json();
    console.log('register status', regRes.status, JSON.stringify(regBody));
    if (!regRes.ok) return;
    const token = regBody.token;
    const tempPath = path.join(process.cwd(), 'temp-upload.pdf');
    fs.writeFileSync(tempPath, 'Dummy PDF content for test');
    const buffer = fs.readFileSync(tempPath);
    const formData = new FormData();
    formData.append('file', new Blob([buffer], { type: 'application/pdf' }), 'test-cv.pdf');
    const uploadRes = await fetch('http://127.0.0.1:3001/api/upload', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`
      },
      body: formData
    });
    const uploadBody = await uploadRes.json();
    console.log('upload status', uploadRes.status, JSON.stringify(uploadBody));
    if (!uploadRes.ok) return;
    const updateRes = await fetch('http://127.0.0.1:3001/api/auth/profile', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        nom: 'Test Upload',
        telephone: '0700000000',
        filiere: 'Informatique',
        age: '25',
        domicile: 'Dakar',
        sexe: 'Masculin',
        cvUrl: uploadBody.url,
        cnibRectoUrl: uploadBody.url,
        cnibVersoUrl: uploadBody.url
      })
    });
    const updateBody = await updateRes.json();
    console.log('update status', updateRes.status, JSON.stringify(updateBody));
    if (!updateRes.ok) return;
    const meRes = await fetch('http://127.0.0.1:3001/api/auth/me', {
      headers: {'Authorization': `Bearer ${token}`}
    });
    const meBody = await meRes.json();
    console.log('me status', meRes.status, JSON.stringify(meBody));
  } catch (e) {
    console.error('ERROR', e);
  }
})();
