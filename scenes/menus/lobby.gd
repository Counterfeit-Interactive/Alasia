extends Node


func _enter_tree() -> void:
	multiplayer.connected_to_server.connect(hide_menu)
	MultiplayerController.server_started.connect(hide_menu)	

func _on_host_pressed() -> void:
	MultiplayerController._create_server()

func _on_join_pressed() -> void:
	MultiplayerController._create_client()

func hide_menu():
	
	self.visible = false
