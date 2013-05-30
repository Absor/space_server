part of space_server;

class ServerConnectionManager {
  
  Map<WebSocket, int> _connections;
  IdManager _idM;
  
  MessageHandler _mh;
  
  ServerConnectionManager(this._mh) {
    _connections = new LinkedHashMap<WebSocket, int>();
    _idM = new IdManager();
    new Timer.periodic(new Duration(milliseconds: 100), (t) => _broadcast());
  }
  
  void onConnection(WebSocket connection) {
    logger.info("Client connecting.");
    connection.listen(
        (data) => _onData(data, connection),
        onError: (error) {
          logger.severe("Error with a connection." + " " + error);
          _endConnection(connection);
        },
        onDone: () => _endConnection(connection),
        cancelOnError: true);
  }
  
  void _onData(var data, WebSocket connection) {
    var jsonData;
    try {
      jsonData = parse(data);
    } catch (error) {
      logger.severe("Error parsing JSON." + " " + error);
      return;
    }
    
    if (jsonData == "requestId") {
      int id = _idM.getFreeId();
      connection.add(stringify({"newId":id}));
      _mh.createPlayer(id);
      _connections[connection] = id;
      logger.info("Id $id given.");
    }
    if (!(jsonData is Map)) return;
    if (jsonData["ping"] != null) {
      connection.add(data);
    } else if (_connections.containsKey(connection)) {
      _mh.handleUpdate(_connections[connection], jsonData);
    }
  }
  
  void _endConnection(WebSocket connection) {
    logger.info("Client connection ended.");
    int id = _connections.remove(connection);
    if (id == null) return;
    _mh.removePlayer(id);
    _idM.releaseId(id);
    logger.info("Id $id released.");
  }
  
  void _broadcast() {
    if (_connections.isEmpty) return;
    var data = stringify(_mh.worldData);
    for (WebSocket connection in _connections.keys) {
      connection.add(data);
    }
  }
}