extends MultiplayerSpawner


@export var network_player: PackedScene

func _init() -> void:
	MultiplayerController.player_connected.connect(spawn_player)
	MultiplayerController.server_started.connect(server_started)
	
func spawn_player(id: int, player_info):
	if !multiplayer.is_server(): return
	var player: Node = network_player.instantiate()
	player.name = str(id)
	player.nickname = player_info["name"]
	
	MultiplayerController.player_spawn.rpc(id, player_info)
	get_node(spawn_path).call_deferred("add_child", player)
	

#Spawn server player
func server_started():
	spawn_player(1, {"name":"Server"})
