extends Node3D

enum {IDLE,RUN, JUMP}
var curAnim = IDLE

@export var blend_speed = 15

@onready var anim_tree = $AnimationTree

var run_val = 0
var sit_val = 0
var jump_val = 0

func _physics_process(delta: float) -> void:
	handle_animation(delta)
	
	curAnim = RUN

func handle_animation(delta):
	run_val = 0
	jump_val = 0
	match curAnim:
		IDLE:
			run_val = lerpf(run_val, 0, blend_speed * delta)
			jump_val = lerpf(jump_val, 0, blend_speed * delta)
		RUN:
			run_val = lerpf(run_val, 1, blend_speed * delta)
			jump_val = lerpf(jump_val, 0, blend_speed * delta)
		JUMP:
			run_val = lerpf(run_val, 0, blend_speed * delta)
			jump_val = lerpf(jump_val, 1, blend_speed * delta)
	
	update_tree()
func update_tree():
	anim_tree["parameters/Run/blend_amount"] = run_val
	anim_tree["parameters/Jump/blend_amount"] = jump_val
