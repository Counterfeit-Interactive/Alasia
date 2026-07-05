class_name PlayerManager

signal local_player_ready

var _local:Player
var players:Dictionary[int, Player] = {}

var _player_informations:Dictionary[int, Dictionary] = {}

func refresh_local_player(entity_id:int, local_peer_id:int):
	var entity = Game.entities.get_by_id(entity_id)
	if entity.get_authority() == local_peer_id:
		_local = entity.object

func add_player(local_peer_id, peer_id, player:Player):
	players[peer_id] = player
	if local_peer_id == peer_id:
		_local = player

func get_all():	return players.values()

func get_by_id(id:int):
	if players.get(id):
		return players[id]
	return null

func remove_player(player:Player):
	players.erase(player.name)

func get_local():
	if is_instance_valid(_local):
		return _local
	
	return null
	
func get_remote_player(multiplayer) -> Player:
	var player_id = multiplayer.get_remote_sender_id()
	var player:Player = Game.players.get_by_id(player_id)
	
	return player
