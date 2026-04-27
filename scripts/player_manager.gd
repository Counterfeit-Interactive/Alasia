class_name PlayerManager

signal local_player_ready

var _local:Player
var players:Dictionary[int, Player] = {}

# The signal player_spawn is called before spawning
var _player_informations:Dictionary[int, Dictionary] = {}

func _init() -> void:
	MultiplayerController.player_take_damage.connect(_on_player_take_damage)

func get_all():
	return players.values()

func get_by_id(id:int):
	if players.get(id):
		return players[id]

func remove_player(player:Player):
	players.erase(player.name)

func get_local():
	if is_instance_valid(_local):
		return _local
	
	return null

func add_player(local_player_id:int, peer_id:int, player:Player):
	players[peer_id] = player
	if local_player_id == peer_id:
		_local = player

		local_player_ready.emit()

func _on_player_take_damage(peer_id, new_hp):
	players[peer_id].health = new_hp

func player_init(peer_id:int):
	if _player_informations.get(peer_id):
		var player_info = _player_informations[peer_id]
		var player = self.get_by_id(peer_id)
		player.nickname = player_info['name']
