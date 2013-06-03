part of space_server;

class MessageChecker {
  Type getMessageType(JsonObject data) {
    try {
      if (data.u != null) {
        _validatePlayerInput(data.u);
        return InputMessage;
      }
    } catch (error) {}
    try {
      if (data.p != null) {
        return PingMessage;
      }
    } catch (error) {}
    try {
      if (data.j != null) {
        return JoinMessage;
      }
    } catch (error) {}
    return MalformedMessage;
  }

  void _validatePlayerInput(JsonObject input) {
    if ((input.th != 1 && input.th != 0 && input.th != -1) &&
        (input.tu != 1 && input.tu != 0 && input.tu != -1)) {
      throw new Exception();
    }
  }
}