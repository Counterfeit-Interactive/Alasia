extends CharacterBody3D
class_name Enemy

@export var speed := 5.0
@export var area_radius := 10.0
@export var detection_radius := 10.0

@onready var detection_area_collision_shape: CollisionShape3D = $DetectionArea/CollisionShape3D
@onready var detection_area: Area3D = $DetectionArea

var initial_position: Vector3
var agressive: bool = false:
	set = _set_agressive

var target: CharacterBody3D:
	set(value):
		target = value
		if value == null:
			agressive = false
		elif not agressive:
			agressive = true

func _ready() -> void:
	initial_position = global_position
	detection_area_collision_shape.scale = Vector3(detection_radius, 1.0, detection_radius)

func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	set_closest_target()

func set_closest_target() -> void:
	var overlapping_bodies = detection_area.get_overlapping_bodies();
	if not overlapping_bodies:
		return

	var closest = overlapping_bodies[0]
	for body in overlapping_bodies.slice(1):
		if global_position.distance_squared_to(body.global_position) < global_position.distance_squared_to(closest.global_position):
			closest = body
	target = closest

func _set_agressive(value: bool) -> void:
	agressive = value
