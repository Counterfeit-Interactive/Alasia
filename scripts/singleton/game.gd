extends Node

var players:PlayerManager

var camera_controller:CameraController

func _init() -> void:
	players = PlayerManager.new()

func hit(target:Enemy) -> void:
	pass
