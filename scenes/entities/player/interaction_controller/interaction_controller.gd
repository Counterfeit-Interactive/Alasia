extends Node

class_name InteractionController

var player:Player = null

var interactables:Array[Node] = []

func _init(_player:Player) -> void:
	player = _player

func _input(event: InputEvent) -> void:
	pass

func interact_with(interactable:Variant):
	var interactable_index = interactables.find(interactable)
	if interactable_index > -1:
		interactables[interactable_index].interact(player)
		interactables.remove_at(interactable_index)

func get_nearest_interaction():
	var target:Variant = null
	var distance = -1
	for interactable in interactables:
		var node_distance = player.position.distance_to(interactable.global_transform.origin)
		if distance == - 1 or node_distance < distance:
			target = interactable
			distance = node_distance
	
	return target
