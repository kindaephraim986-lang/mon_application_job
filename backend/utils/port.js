const net = require('net');

async function getAvailablePort(startPort, host = '0.0.0.0', maxAttempts = 5) {
  for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
    const candidatePort = startPort + attempt;
    const server = net.createServer();

    try {
      await new Promise((resolve, reject) => {
        server.once('error', reject);
        server.listen(candidatePort, host, resolve);
      });

      await new Promise((resolve, reject) => {
        server.close((err) => {
          if (err) {
            reject(err);
          } else {
            resolve();
          }
        });
      });

      return candidatePort;
    } catch (error) {
      if (error && error.code !== 'EADDRINUSE') {
        throw error;
      }
    }
  }

  throw new Error(`No available port found starting from ${startPort}`);
}

module.exports = {
  getAvailablePort,
};
