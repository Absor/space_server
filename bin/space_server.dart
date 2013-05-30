library space_server;

import 'dart:collection';
import 'dart:io';
import 'dart:json';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:siege_engine/siege_engine.dart';
import 'package:space_shared/space_shared.dart';

part 'server_connection_manager.dart';
part 'log_writer.dart';
part 'id_manager.dart';
part 'server_settings.dart';
part 'message_handler.dart';

Logger logger;

void main() {
  // Setup logging
  logger = new Logger("space_server");
  LogWriter logWriter = new LogWriter();
  logger.onRecord.listen(logWriter.onRecord);
  
  new SpaceServer();
}

class SpaceServer {
  
  World _world;
  num _lastTick;
      
  SpaceServer() {
    _setupWorld();
    MessageHandler mh = new MessageHandler(_world);
    ServerConnectionManager cm = new ServerConnectionManager(mh);
    _setupServer(cm);
    _lastTick = new DateTime.now().millisecondsSinceEpoch;
    new Timer.periodic(new Duration(milliseconds:15), (t) =>_runWorld());
  }
  
  void _setupWorld() {
    _world = new World();
    
    InputProcessingSystem inputProcessingSystem = new InputProcessingSystem();
    MovementSystem movementSystem = new MovementSystem();
    
    inputProcessingSystem.enabled = true;
    movementSystem.enabled = true;
    
    inputProcessingSystem.priority = 5;
    movementSystem.priority = 10;
    
    _world.addSystem(movementSystem);
    _world.addSystem(inputProcessingSystem);
  }
  
  void _runWorld() {
    num now = new DateTime.now().millisecondsSinceEpoch;
    _world.process(now - _lastTick);
    _lastTick = now;
  }
  
  void _setupServer(ServerConnectionManager cm) {
    HttpServer.bind(ServerSettings.serverIp, ServerSettings.serverPort).then((HttpServer server) {
      server.transform(new WebSocketTransformer()).listen(
          cm.onConnection,
          onError: (error) {
            logger.info(ServerSettings.webSocketTransformError + " " + error);
          });
    }, onError: (error) {
      logger.severe(ServerSettings.httpServerBindError + " " + error);
    });
  }
}