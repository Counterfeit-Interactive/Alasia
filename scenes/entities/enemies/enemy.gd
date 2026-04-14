extends CharacterBody3D
class_name Enemy

@export var speed := 5.0
var initial_position
@export var area_radius := 10.0

func _ready() -> void:
	initial_position = global_position
