const test = require('node:test');
const assert = require('node:assert/strict');
const { isValidPhoneInput } = require('../middleware/validation');

test('accepts common phone formats', () => {
  assert.equal(isValidPhoneInput('+22670123456'), true);
  assert.equal(isValidPhoneInput('0701234567'), true);
  assert.equal(isValidPhoneInput('226 70 12 34 56'), true);
  assert.equal(isValidPhoneInput('0022670123456'), true);
  assert.equal(isValidPhoneInput('not-a-phone'), false);
});
