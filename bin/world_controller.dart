part of space_server;

class WorldController {
  
  World _world;
  Map<String, Map<String, Component>> worldData;
  Map<String, Map<String, Component>> joinData;
  Map<int, Component> _inputs;
  
  WorldController(this._world) {
    worldData = new LinkedHashMap<String, Map<String, Component>>();
    joinData = new LinkedHashMap<String, Map<String, Component>>();
    _inputs = new HashMap<int, Component>();
  }
    
  void playerInput(int id, JsonObject input) {
    InputComponent ic = _inputs[id];
    ic.thrust = input.th;
    ic.turn = input.tu;
  }
  
  void createPlayer(int id) {
    Map<String, Component> updateComponents = new LinkedHashMap<String, Component>();
    worldData[id.toString()] = updateComponents;
    Map<String, Component> joinComponents = new LinkedHashMap<String, Component>();
    joinData[id.toString()] = joinComponents;
    
    Entity player = _world.createEntity(id);
    
    PositionComponent position = new PositionComponent();
    position.x = 0;
    position.y = 0;
    player.addComponent(position);
    updateComponents["p"] = position;
    joinComponents["p"] = position;
    
    RotationComponent rotation = new RotationComponent();
    rotation.angleInDegrees = 0;
    player.addComponent(rotation);
    updateComponents["r"] = rotation;
    joinComponents["r"] = rotation;
    
    AccelerationComponent acceleration = new AccelerationComponent();
    acceleration.x = 0;
    acceleration.y = 0;
    player.addComponent(acceleration);
    updateComponents["a"] = acceleration;
    joinComponents["a"] = acceleration;
    
    VelocityComponent velocity = new VelocityComponent();
    velocity.x = 0;
    velocity.y = 0;
    player.addComponent(velocity);
    updateComponents["v"] = velocity;
    joinComponents["v"] = velocity;
    
    InputComponent input = new InputComponent();
    input.thrust = 0;
    input.turn = 0;
    player.addComponent(input);
    _inputs[id] = input;
    
    _world.activateEntity(id);
  }
  
  void removePlayer(int id) {
    worldData.remove(id.toString());
    joinData.remove(id.toString());
    _inputs.remove(id);
    _world.destroyEntity(id);
  }
}