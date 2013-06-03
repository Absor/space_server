part of space_server;

class ConnectionManager {
  
  Map<WebSocket, int> _joinedPlayers;
  IdManager _idM;
  WorldController _wc;
  EventSink<dynamic> _messageSink;
  MessageChecker _mp;
  
  ConnectionManager(this._wc) {
    _joinedPlayers = new LinkedHashMap<WebSocket, int>();
    _idM = new IdManager();
    _mp = new MessageChecker();
    StreamController<dynamic> sc = new StreamController<dynamic>();
    sc.stream.listen((message) => message());
    _messageSink = sc.sink;
    new Timer.periodic(new Duration(milliseconds:100), (t) => _broadcastWorldStatus());
  }
  
  void onConnection(WebSocket connection) {
    logger.info("Client connecting.");
    connection.listen(
        (data) => _onData(data, connection),
        onError: (error) {
          logger.severe("Error with a connection. $error");
          _endConnection(connection);
        },
        onDone: () => _endConnection(connection),
        cancelOnError: true);
  }
  
  void _onData(var rawData, WebSocket connection) {
    JsonObject data;
    try {
      data = _parseData(rawData);
    } catch (error) {
      logger.severe("Error parsing JSON. $error");
      _endConnection(connection);
      return;
    }
    Type messageType = _mp.getMessageType(data);
    switch (messageType) {
      case InputMessage:
        _playerInput(connection, data);
        break;
      case PingMessage:
        if (connection.readyState == WebSocket.OPEN) {
          connection.add(rawData);
        }
        break;
      case JoinMessage:
        _playerJoin(connection, data);
        break;
      case MalformedMessage:
        logger.severe("Bad data received: $data");
        _endConnection(connection);
        break;
    }
  }

  void _playerInput(WebSocket connection, JsonObject data) {
    if (_joinedPlayers.containsKey(connection)) {
      _wc.playerInput(_joinedPlayers[connection], data.u);
    } else {
      _endConnection(connection);
    }
  }
  
  JsonObject _parseData(rawData) {
    var parsed = parse(rawData);
    if (!(parsed is Map)) throw new Exception("Wrong type of data sent: $parsed");
    return new JsonObject.fromMap(parsed);
  }
    
  void _playerJoin(WebSocket connection, JsonObject data) {
    var message = () {
      int id = _idM.getFreeId();
      _wc.createPlayer(id);
      logger.info("Id $id given.");
      var newPlayerData = stringify({"j":{"$id":_wc.joinData[id.toString()]}});
      for (WebSocket otherConnection in _joinedPlayers.keys) {
        if (otherConnection.readyState == WebSocket.OPEN) {
          otherConnection.add(newPlayerData);
        }
      }
      _joinedPlayers[connection] = id;
      if (connection.readyState == WebSocket.OPEN) {
        connection.add(stringify({"i":id}));
        connection.add(stringify({"j":_wc.joinData}));
      }
    };
    _messageSink.add(message);
  }
  
  void _endConnection(WebSocket connection) {
    connection.close();
    logger.info("Closed connection.");
    var message = () {
      int id = _joinedPlayers.remove(connection);
      if (id == null) return;
      _wc.removePlayer(id);
      _idM.releaseId(id);
      logger.info("Id $id released.");
    };
    _messageSink.add(message);
  }
  
  void _broadcastWorldStatus() {
    var message = () {
      if (_joinedPlayers.isEmpty) return;
      var worldData = stringify({"u":_wc.worldData});
      for (WebSocket connection in _joinedPlayers.keys) {
        if (connection.readyState == WebSocket.OPEN) {
          connection.add(worldData);
        }
      }
    };
    _messageSink.add(message);
  }
}