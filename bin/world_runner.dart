part of space_server;

class WorldRunner {
  
  World world;
  int _lastTick;
  
  WorldRunner() {
    _setupWorld();
    _lastTick = new DateTime.now().millisecondsSinceEpoch;
    new Timer.periodic(new Duration(milliseconds:15), (t) =>_runWorld());
  }
    
  void _setupWorld() {
    world = new World();
    
    InputProcessingSystem inputProcessingSystem = new InputProcessingSystem();
    MovementSystem movementSystem = new MovementSystem();
    
    inputProcessingSystem.enabled = true;
    movementSystem.enabled = true;
    
    inputProcessingSystem.priority = 5;
    movementSystem.priority = 10;
    
    world.addSystem(movementSystem);
    world.addSystem(inputProcessingSystem);
  }
  
  void _runWorld() {
    num now = new DateTime.now().millisecondsSinceEpoch;
    world.process(now - _lastTick);
    _lastTick = now;
  }
}