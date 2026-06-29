const assert = require('assert');
const { authorize } = require('../middleware/auth');

const middleware = authorize('candidat');
let nextCalled = false;
const req = { user: { type_utilisateur: 'admin' } };
const res = {
  statusCode: 200,
  status(code) {
    this.statusCode = code;
    return this;
  },
  json() {}
};

middleware(req, res, () => {
  nextCalled = true;
});

assert.strictEqual(nextCalled, true, 'Un administrateur doit pouvoir passer les protections de rôle');
assert.strictEqual(res.statusCode, 200, 'Aucun refus ne doit être retourné pour l’admin');
console.log('admin authorization test passed');
