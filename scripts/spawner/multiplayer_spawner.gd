extends MultiplayerSpawner


@export var network_player: PackedScene

func _init() -> void:
	MultiplayerController.player_connected.connect(spawn_player)
	MultiplayerController.server_started.connect(server_started)
	MultiplayerController.properties_changed.connect(update_properties)
	MultiplayerController.property_changed.connect(update_property)

func spawn_player(id: int, player_info):
	if !multiplayer.is_server(): return
	var player: Node = network_player.instantiate()
	player.entity.set_name(player_info["name"])
	player.entity.setProperty("authority", id)
	get_node(spawn_path).call_deferred("add_child", player)
	
	Game.players.add_player(multiplayer.get_unique_id(), player.entity.get_authority(), player)

func server_started():
	# Spawn server player
	spawn_player(1, {"name":"Server"})

## Only at the first connection, sharing all properties at the same time instead of one by one
func update_properties(entity_id, properties):
	var entity = Game.entities.get_by_id(entity_id)
	entity.updateProperties(properties)
	entity.on_ready()

## Emitted when server send rpc_id with property that changed
func update_property(entity_id, name, value):
	var entity = Game.entities.get_by_id(entity_id)
	Game.entities.get_by_id(entity_id).setProperty(name, value)
	print(name, value)
