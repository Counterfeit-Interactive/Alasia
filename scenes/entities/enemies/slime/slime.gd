extends Enemy

const JUMP_VELOCITY = 4.5

@onready var mesh: Node3D = $Mesh
@onready var jump_cooldown: Timer = $JumpCooldown

var direction: Vector3:
	set(value):
		direction = value
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	
var mesh_angle: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# jump_cooldown timer so the slime wait between jumps
	if jump_cooldown.is_stopped():
		# Only move when jumping => when jump_cooldown is stopped
		if move_and_slide() and not is_on_floor():
			direction = Vector3(-direction.x, direction.y, -direction.z)

		# On floor == not jumping
		if is_on_floor():
			# Setup next jump and start timer
			velocity.y = JUMP_VELOCITY
			direction = get_direction()
			mesh_angle = PI/2 + atan2(velocity.x,velocity.z)
			jump_cooldown.start()

	mesh.rotation.y = rotate_toward(mesh.rotation.y, mesh_angle, 5 * delta)

func get_direction() -> Vector3:
	# Avoid going too far from initial position
	if (global_position.distance_to(initial_position) > area_radius):
		return global_position.direction_to(initial_position)
	else:
		var rng = RandomNumberGenerator.new()
		var vector = Vector3(rng.randf_range(-1.0, 1.0), 0, rng.randf_range(-1.0, 1.0))
		return (transform.basis * vector).normalized()
