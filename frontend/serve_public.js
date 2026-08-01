const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const publicDir = path.join(__dirname, 'public');
const port = process.env.PORT || 8080;
const host = '0.0.0.0';

const mime = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.apk': 'application/vnd.android.package-archive',
  '.zip': 'application/zip',
  '.ico': 'image/x-icon',
};

const server = http.createServer((req, res) => {
  try {
    const parsed = url.parse(req.url);
    let pathname = decodeURIComponent(parsed.pathname);
    if (pathname === '/') pathname = '/';
    const filePath = path.join(publicDir, pathname);

    if (!filePath.startsWith(publicDir)) {
      res.statusCode = 403;
      return res.end('Forbidden');
    }

    fs.stat(filePath, (err, stats) => {
      if (err) {
        res.statusCode = 404;
        return res.end('Not found');
      }
      if (stats.isDirectory()) {
        // show listing
        fs.readdir(filePath, (err, files) => {
          if (err) { res.statusCode = 500; return res.end('Error'); }
          res.setHeader('Content-Type', 'text/html');
          res.end('<h1>Index of ' + pathname + '</h1><ul>' + files.map(f => `<li><a href="${path.join(pathname, f)}">${f}</a></li>`).join('') + '</ul>');
        });
      } else {
        const ext = path.extname(filePath).toLowerCase();
        const ct = mime[ext] || 'application/octet-stream';
        res.setHeader('Content-Type', ct);
        res.setHeader('Access-Control-Allow-Origin', '*');
        const stream = fs.createReadStream(filePath);
        stream.on('error', () => { res.statusCode = 500; res.end('Error'); });
        stream.pipe(res);
      }
    });
  } catch (e) {
    res.statusCode = 500; res.end('Server error');
  }
});

server.listen(port, host, () => {
  console.log(`Serving ${publicDir} on http://${host}:${port}`);
});
