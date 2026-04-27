extends CharacterBody3D
class_name Enemy

@export var speed := 2.0
@export var damage := 1
@export var area_radius := 10.0 # The radius from the initial point the enemy roam in
@export var detection_radius := 10.0 # The radius in which the enemy detect the player
@export var chase_distance := 20.0 # The distance in which the enemy will chase the player

@onready var detection_area_collision_shape: CollisionShape3D = $DetectionArea/CollisionShape3D
@onready var detection_area: Area3D = $DetectionArea

var initial_position: Vector3

enum STATES { PASSIVE, AGRESSIVE, RETURN }
var state: STATES:
	set = set_state

var target: Player

func _ready() -> void:
	initial_position = global_position
	detection_area_collision_shape.scale = Vector3(detection_radius, 1.0, detection_radius)

func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	target = set_closest_target()
	state = get_state()

func set_closest_target() -> CharacterBody3D:
	var overlapping_bodies = detection_area.get_overlapping_bodies();
	if not overlapping_bodies or state == STATES.RETURN:
		return
	
	var closest = overlapping_bodies[0]
	for body in overlapping_bodies.slice(1):
		if global_position.distance_squared_to(body.global_position) < global_position.distance_squared_to(closest.global_position):
			closest = body
	return closest

@rpc("authority")
func hit(player: Player) -> void:
	if multiplayer.is_server():
		MultiplayerController._player_take_damage.rpc(int(player.name), damage)

func get_state() -> STATES:
	if state == STATES.RETURN:
		if global_position.distance_to(initial_position) < area_radius:
			return STATES.PASSIVE
		return STATES.RETURN
	
	if global_position.distance_to(initial_position) > chase_distance:
		return STATES.RETURN
	
	if target:
		return STATES.AGRESSIVE
	
	return STATES.PASSIVE

func set_state(value: STATES) -> void:
	state = value
