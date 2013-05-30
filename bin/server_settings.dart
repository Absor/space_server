part of space_server;

class ServerSettings {
  
  static String serverIp = "0.0.0.0";
  static int serverPort = 8080;
  
  
  // Log messages
  static String httpServerBindError = "Error starting server.";
  static String webSocketTransformError = "Bad WebSocket request.";
}