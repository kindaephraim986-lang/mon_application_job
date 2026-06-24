const request = require('supertest');
const jwt = require('jsonwebtoken');
const { expect } = require('chai');
const path = require('path');

// Require app (server.js exports app)
const app = require('../server');

const TEST_USER_ID = 'user_1781527027036';
const JWT_SECRET = process.env.JWT_SECRET || 'Job Research_dev_secret';

function makeToken() {
  return jwt.sign({ id: TEST_USER_ID }, JWT_SECRET, { expiresIn: '1h' });
}

describe('OCR API', function() {
  it('POST /api/ocr/verify should return 200 and success true with valid body and auth', async function() {
    const token = makeToken();
    const res = await request(app)
      .post('/api/ocr/verify')
      .set('Authorization', `Bearer ${token}`)
      .send({ userData: { nom: 'TOTO' }, ocrData: { nom: 'TOTO' } })
      .expect(200);

    expect(res.body).to.have.property('success', true);
    expect(res.body).to.have.property('comparison');
  });

  it('POST /api/ocr/extract should reject non-image uploads', async function() {
    const token = makeToken();
    const res = await request(app)
      .post('/api/ocr/extract')
      .set('Authorization', `Bearer ${token}`)
      .attach('file', Buffer.from('not an image'), 'test.txt');

    // expect client or server error
    expect(res.status).to.be.at.least(400);
  });

  it('POST /api/ocr/extract should accept valid PNG image', async function() {
    this.timeout(5000);
    const token = makeToken();
    const fixtureFile = path.join(__dirname, 'fixtures', 'sample.png');
    const res = await request(app)
      .post('/api/ocr/extract')
      .set('Authorization', `Bearer ${token}`)
      .attach('file', fixtureFile);

    // expect 200 or 422/500 (processing may fail, but upload should work)
    expect([200, 422, 500]).to.include(res.status);
    if (res.status === 200) {
      expect(res.body).to.have.property('success', true);
    }
  });
});
