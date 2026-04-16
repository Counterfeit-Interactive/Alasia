extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 6.5
const FALL_VELOCITY = 1.5

@onready var mesh: Node3D = $Mesh
@onready var camera: Camera3D = $CameraController/Camera3D

var nickname: String = ""
var health = 5:
	set(value):
		health = value
		if health <= 0:
			get_tree().quit()


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	$CameraController.set_multiplayer_authority(name.to_int())

	# Hide HUD

func _physics_process(delta: float) -> void:
	
	if !is_multiplayer_authority(): return
	if not is_on_floor():
		velocity += get_gravity() * delta * FALL_VELOCITY

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var target_angle = PI/2 - input_dir.angle()
		mesh.rotation.y = rotate_toward(mesh.rotation.y, target_angle, 20 * delta)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
