const WebSocket = require("ws");
const wss = new WebSocket.Server({ port: 3000 });

wss.on("connection", (ws) => {
  console.log("New client connected, total clients: ");
  ws.on("message", (message) => {
    console.log(`sending message to client: ${message}`);
    // Broadcast received message to all connected clients
    wss.clients.forEach((client) => {
      console.log(
        `expression: ${client.readyState === WebSocket.OPEN}, client: ${
          client !== ws
        }`
      );
      if (
        //client !== ws &&
        client.readyState === WebSocket.OPEN
      ) {
        client.send(message.toString() + "");
      }
    });
  });
});
