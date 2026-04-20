extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal server_started
signal player_is_ready(player_info)

signal player_take_damage(peer_id, damage)


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
	

@rpc("any_peer")
func player_ready(new_player_info):
	player_info['health'] = 100
	_register_player(new_player_info)

	
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	player_connected.emit(new_player_id, new_player_info)


@rpc("authority", "call_local")
func _player_take_damage(peer_id:int, damage:int):
	Game.players.get_by_id(peer_id).health -= damage
	player_take_damage.emit(peer_id, Game.players.get_by_id(peer_id).health)
	
	
@rpc("call_local", "authority")
func player_spawn(peer_id:int, player_info):
	Game.players._player_informations[peer_id] = player_info
