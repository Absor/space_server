part of space_server;

class LogWriter {
  
  void onRecord(LogRecord record) {
    print(record.message);
  }
}