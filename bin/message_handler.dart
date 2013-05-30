part of space_server;

class MessageHandler {
  
  World _world;
  Map<String, Map<String, Component>> _worldData;
  Map<int, Component> _inputs;
  
  MessageHandler(this._world) {
    _worldData = new LinkedHashMap<String, Map<String, Component>>();
    _inputs = new HashMap<int, Component>();
  }
  
  Map<String, Map<String, Component>> get worldData => _worldData;
  
  void handleUpdate(int id, var jsonData) {
    InputComponent input = _inputs[id];
    input.thrust = jsonData["thrust"];
    input.turn = jsonData["turn"];
  }
  
  void createPlayer(int id) {
    Map<String, Component> components = new LinkedHashMap<String, Component>();
    _worldData[id.toString()] = components;
    Entity player = _world.createEntity(id);
    
    PositionComponent position = new PositionComponent();
    position.x = 0;
    position.y = 0;
    player.addComponent(position);
    components["position"] = position;
    
    RotationComponent rotation = new RotationComponent();
    rotation.angle = 0;
    player.addComponent(rotation);
    components["rotation"] = rotation;
    
    AccelerationComponent acceleration = new AccelerationComponent();
    acceleration.x = 0;
    acceleration.y = 0;
    player.addComponent(acceleration);
    components["acceleration"] = acceleration;
    
    VelocityComponent velocity = new VelocityComponent();
    velocity.x = 0;
    velocity.y = 0;
    player.addComponent(velocity);
    components["velocity"] = velocity;
    
    InputComponent input = new InputComponent();
    input.thrust = 0;
    input.turn = 0;
    player.addComponent(input);
    _inputs[id] = input;
    
    _world.activateEntity(id);
  }
  
  void removePlayer(int id) {
    _worldData.remove(id.toString());
    _inputs.remove(id);
  }
}