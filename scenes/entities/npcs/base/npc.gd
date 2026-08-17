class_name NPC
extends Node3D

@export var dialogue_resource:Resource

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		var player:Player = body
		player.interaction_controller.interactables.append(self)

func interact(_player:Player):
	print(_player, Game.is_server())


func get_dialogue():
	return dialogue_resource


func _on_detection_area_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		var player:Player = body
		player.interaction_controller.interactables.append(self)
