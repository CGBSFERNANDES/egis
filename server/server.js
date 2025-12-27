const http = require('http');
const app = require('./index'); // importa o app já configurado no index.js
const socketIo = require('socket.io');


// ✅ Importa corretamente a função do Monitor
const { configurarSocket } = require('../src/modules/monitor/monitor.controller');
const { configurarChatSocket } = require('../src/modules/chat/chat.socket');
const { configurarOperadorSocket } = require('../src/modules/chat/chat.operator');


const PORT = process.env.PORT || 3000;

// Se ainda quiser socket.io ativo para outros módulos:
const server = http.createServer(app);

const io = socketIo(server, {
  cors: {
    origin: "*"
  }
});

// Você pode ativar outros sockets aqui, exceto do monitor
// Exemplo (se tiver outro módulo socket): require('../src/modules/algumModulo').configurarSocket(io);

configurarSocket(io); // ← ESSENCIAL
configurarChatSocket(io); // ✅ Chat
configurarOperadorSocket(io);

server.listen(PORT, () => {
  console.log(`✅ Servidor rodando com Express + socket.io em http://localhost:${PORT}`);
});
