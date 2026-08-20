class_name Entity

signal entity_ready

var multiplayer:MultiplayerAPI
var unique_id:int = -1

var object:Node
var entities_properties = {}
var _ready:bool = false

func init(_multiplayer:MultiplayerAPI, _object:Node):
	multiplayer = _multiplayer
	object = _object
	if multiplayer.is_server():
		set_id(Game.entities.generate_id())
		_object.name = str(get_id())
	else:
		set_id(int(_object.name))
		MultiplayerController.ask_properties.rpc(multiplayer.get_unique_id())
	
	Game.entities.add_entity(self)
	if multiplayer.is_server():
		call_deferred("on_ready")

func on_ready():
	if _ready:
		return
	if object is Player:
		Game.players.add_player(multiplayer.get_unique_id(), object.entity.get_authority(), object)
	
	_ready = true
	# Allow us to connect method after everything is ok
	entity_ready.emit()

func set_property(name:String, value):
	if name in entities_properties and entities_properties[name] == value:
		return
	if name == "authority":
		var object = get_object()
		if object and object.on_authority_change:
			object.on_authority_change()
		
	entities_properties[name] = value
	if multiplayer and multiplayer.is_server():
		MultiplayerController.share_property.rpc(self.get_id(), name, value)

func update_properties(properties):
	for property in properties:
		set_property(property, properties[property])

func is_authority():
	return multiplayer.get_unique_id() == get_property("authority")

func get_property(name:String):
	return entities_properties[name] if name in entities_properties else null
	
func set_id(id:int):
	unique_id = id
	
func get_authority():
	return get_property("authority")

func is_player() -> bool:
	return object is Player

func get_id():
	return unique_id
	
func get_health() -> int:
	return get_property("health") if get_property("health") else 0
	
func get_max_health() -> int:
	return get_property("max_health") if get_property("max_health") else 0
	
func set_health(value:int):
	set_property("health", value)
	
func set_max_health(value:int):
	set_property("max_health", value)
	
func get_name():
	var name = get_property("name") 
	return name if name else "Invalid"

func set_name(new_name: String):
	entities_properties["name"] = new_name

func take_damage(damage:int):
	if not multiplayer.is_server():
		return
	var current_health = get_health()
	var new_health = current_health - damage
	if new_health <= 0:
		new_health = 0
		set_property("died", true)
		
	set_property("health", new_health)
	
func alive() -> bool:
	return get_property("health") > 0

func get_object():
	"""Return parent object"""
	return object
