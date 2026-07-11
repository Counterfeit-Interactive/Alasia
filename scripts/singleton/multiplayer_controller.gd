extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal server_started
signal player_is_ready(player_info)

signal player_take_damage(peer_id, damage)
signal entity_spawn(id)

signal properties_changed(entity_id, properties)
signal property_changed(entity_id, properties)

#Entity
signal on_entity_attack(entity_id)

var peer:ENetMultiplayerPeer = null

var is_server = false
var is_player = false
var players_loaded = 0

@export var scene:PackedScene = preload("res://scenes/main.tscn")

var player_info = {"name":"Unknown","health":100}
var players_connected = 0

var DEFAULT_PORT = 7000
var DEFAULT_IP = "127.0.0.1"


func _ready():
	multiplayer.connected_to_server.connect(_on_connected_ok)
	
	var args = OS.get_cmdline_args()	
	is_server = "--server" in args
	for arg in args:
		is_player = "--player" in arg
		if is_player:
			break
	
	if is_server:
		_create_server()
		player_info["name"] = "Server"
	elif is_player:
		player_info["name"] = _extract_player_name_from_args(args)
		_create_client()
		
func _create_server(selected_port=DEFAULT_PORT):
	var port = int(selected_port)
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	server_started.emit()

func _extract_player_name_from_args(args):
	for arg in args:
		if "--player" in arg:
			return args[-1].split("=", true)[-1]
	
	return "Unknown"
	
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	player_connected.emit(new_player_id, new_player_info)

func _create_client(selected_ip=DEFAULT_IP, selected_port=DEFAULT_PORT):
	var ip = selected_ip
	var port = int(selected_port)
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error:
		return error
	
	multiplayer.multiplayer_peer = peer

func _on_connected_ok():
	player_ready.rpc(player_info)

# ---------------------- SERVER SIDE ---------------------- #
@rpc("call_local", "authority")
func share_properties(entity_id:int, properties):
	properties_changed.emit(entity_id, properties)

#Server side
@rpc("call_local", "authority")
func share_property(entity_id:int, name: String, value):
	property_changed.emit(entity_id, name, value)

#Server side
@rpc("call_local", "authority")
func player_spawn(peer_id:int, entity_id:int):
	#Game.players._player_informations[peer_id] = player_info
	pass
	
# ---------------------- END SERVER SIDE -------------------- #

# ---------------------- SHARED SIDE ------------------------ #
@rpc("any_peer")
func player_ready(new_player_info):
	_register_player(new_player_info)

@rpc("any_peer", "call_local", "reliable")
func player_attack():
	var player_id = multiplayer.get_remote_sender_id()
	var player = Game.players.get_by_id(player_id)
	entity_attack(player.entity.get_id())

# Common function to play animation for an entity that attacked
@rpc("any_peer", "call_local", "reliable")
func entity_attack(entity_id):
	Game.entities.get_by_id(entity_id).object.attack_animation()

## It's usefull when we want to synchronize all data of an entity (like for the initial player spawn)
@rpc("any_peer", "reliable")
func ask_properties(peer_id:int):
	if multiplayer.is_server():
		for entity in Game.entities.get_all():
			if entity is Player:
				entity.object.on_authority_change()
			share_properties.rpc_id(peer_id, entity.get_id(), entity.entities_properties)
			
# ---------------------- END SHARED SIDE ---------------------- #
