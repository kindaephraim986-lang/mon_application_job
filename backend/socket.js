let ioInstance = null;

function init(server, options = {}) {
  const { Server } = require('socket.io');
  ioInstance = new Server(server, {
    cors: {
      origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : true,
      methods: ['GET', 'POST']
    },
    ...options,
  });

  ioInstance.on('connection', (socket) => {
    console.log('Socket connected:', socket.id);

    socket.on('joinConversation', (convId) => {
      try {
        const room = `conversation_${convId}`;
        socket.join(room);
        console.log(`Socket ${socket.id} joined ${room}`);
      } catch (e) {
        // ignore
      }
    });

    socket.on('leaveConversation', (convId) => {
      try {
        const room = `conversation_${convId}`;
        socket.leave(room);
      } catch (e) {}
    });

    socket.on('disconnect', () => {
      // nothing special for now
    });
  });

  return ioInstance;
}

function getIo() {
  if (!ioInstance) throw new Error('Socket.IO not initialized');
  return ioInstance;
}

module.exports = { init, getIo };
