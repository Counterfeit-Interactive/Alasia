extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal server_started
signal player_is_ready(player_info)

var peer:ENetMultiplayerPeer = null
var players = {}

var is_server = false
var is_player = false
var players_loaded = 0

@export var scene:PackedScene = preload("res://scenes/main.tscn")

var player_info = {"name":"Unknown"}
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
	var peer_id = multiplayer.get_unique_id()
	player_ready.rpc(player_info)
	
	player_is_ready.emit(player_info)
#func _on_connected_fail():
	#print("connection failed")
	#remove_multiplayer_peer()

@rpc("any_peer")
func player_ready(player_info):
	_register_player(player_info)

	
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
