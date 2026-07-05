extends Node

var players:PlayerManager
var entities:EntityManager
var items:ItemManager
var constants:Constant

var camera_controller:CameraController
var items_spawner:MultiplayerSpawner

var item_node

func _init() -> void:
	players = PlayerManager.new()
	entities = EntityManager.new()
	items = ItemManager.new()

	
func _ready() -> void:
	items_spawner = get_tree().get_first_node_in_group("ItemSpawner")
	items.load_items()
	
func is_server() -> bool:
	return multiplayer.is_server()
