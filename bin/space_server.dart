library space_server;

import 'dart:collection';
import 'dart:io';
import 'dart:json';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:json_object/json_object.dart';
import 'package:siege_engine/siege_engine.dart';
import 'package:space_shared/space_shared.dart';

part 'connection_manager.dart';
part 'log_writer.dart';
part 'id_manager.dart';
part 'world_controller.dart';
part 'world_runner.dart';
part 'message_checker.dart';

JsonObject settings;
Logger logger;

void main() {
  File file = new File(new Options().arguments.first);
  settings = new JsonObject.fromJsonString(file.readAsStringSync());
  
  // Setup logging
  logger = new Logger("space_server");
  LogWriter logWriter = new LogWriter();
  logger.onRecord.listen(logWriter.onRecord);
  
  new SpaceServer();
}

class SpaceServer {
  
  ConnectionManager _cm;
      
  SpaceServer() {
    WorldRunner wr = new WorldRunner();
    WorldController wc = new WorldController(wr.world);
    _cm = new ConnectionManager(wc);
    _setupServer();
  }
  
  void _setupServer() {
    HttpServer.bind(settings.serverIp, settings.serverPort).then((HttpServer server) {
      server.transform(new WebSocketTransformer()).listen(
          _cm.onConnection,
          onError: (error) {
            logger.info("Bad WebSocket request. $error");
          });
    }, onError: (error) {
      logger.severe("Error starting server. $error");
    });
  }
  
  // TODO file handling
}