extends Node

var players:PlayerManager
var entities:EntityManager

var camera_controller:CameraController

func _init() -> void:
	players = PlayerManager.new()
	entities = EntityManager.new()

#func hit(target:Enemy) -> void:
	#pass
