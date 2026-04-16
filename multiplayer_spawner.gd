extends MultiplayerSpawner


@export var network_player: PackedScene

func _ready() -> void:
	MultiplayerController.player_connected.connect(spawn_player)
	pass
	
func spawn_player(id: int, player_info):
	if !multiplayer.is_server(): return
	var player: Node = network_player.instantiate()
	player.name = str(id)
	player.nickname = player_info["name"]
	
	get_node(spawn_path).call_deferred("add_child", player)
