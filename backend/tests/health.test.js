const assert = require('assert');
const http = require('http');
const app = require('../server');

const server = app.listen(0, '127.0.0.1', () => {
  const { port } = server.address();
  http.get({ host: '127.0.0.1', port, path: '/api/health' }, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      try {
        assert.strictEqual(res.statusCode, 200);
        const body = JSON.parse(data);
        assert.strictEqual(body.status, 'OK');
        console.log('health endpoint OK');
      } catch (error) {
        console.error(error);
        process.exitCode = 1;
      } finally {
        server.close();
      }
    });
  }).on('error', (error) => {
    console.error(error);
    server.close();
    process.exitCode = 1;
  });
});
