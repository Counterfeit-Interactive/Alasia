class_name Entity


var multiplayer:MultiplayerAPI
var unique_id:int = -1
var health = 100:
	set(value):
		health = value
		#if health <= 0:
			##queue_free()
			#is_alive = false

var object:Node
var entities_properties = {}

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

func on_ready():
	if object is Player:
		Game.players.add_player(multiplayer.get_unique_id(), object.entity.get_authority(), object)

func setProperty(name:String, value):
	if name in entities_properties and entities_properties[name] == value:
		return
	if name == "authority":
		var object = get_object()
		if object and object.on_authority_change:
			object.on_authority_change()
		
	entities_properties[name] = value
	if multiplayer and multiplayer.is_server():
		MultiplayerController.share_property.rpc(self.get_id(), name, value)

func updateProperties(properties):
	for property in properties:
		setProperty(property, properties[property])

func is_authority():
	return multiplayer.get_unique_id() == getProperty("authority")

func getProperty(name:String):
	return entities_properties[name] if name in entities_properties else null
	
func set_id(id:int):
	unique_id = id
	
func get_authority():
	return getProperty("authority")

func is_player() -> bool:
	return object is Player

func get_id():
	return unique_id
	
func get_name():
	var name = getProperty("name") 
	return name if name else "Invalid"

func set_name(new_name: String):
	entities_properties["name"] = new_name

func take_damage(damage:int):
	var current_health = getProperty("health")
	print(current_health)
	setProperty("health", current_health - damage)

func get_object():
	"""Return parent object"""
	return object
