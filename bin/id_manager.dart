part of space_server;

class IdManager {
  
  int idCounter;
  Queue<int> _usedIds;
  
  IdManager() {
    idCounter = 0;
    _usedIds = new ListQueue<int>();
  }
  
  int getFreeId() {
    if (_usedIds.isEmpty) return idCounter++;
    else return _usedIds.removeFirst();
  }
  
  void releaseId(int id) {
    _usedIds.addLast(id);
  }
}