extends CharacterBody3D
class_name Player

const SPEED = 6.0
const JUMP_VELOCITY = 6.5
const FALL_VELOCITY = 1.5

@onready var camera: Camera3D = $CameraController/Camera3D

@onready var animation_tree:AnimationTree = $Character/AnimationTree
@onready var state_machine = $Character/AnimationTree.get("parameters/Player/playback")

@onready var player_node:Node3D = $Character

@export var is_jumping:bool = false
@export var is_running:bool = false
@export var is_attacking:bool = false

var entity:Entity = Entity.new()
var nickname: String = ""
var is_alive:bool = true

@export var unique_id:int = -1

var health = 5:
	set(value):
		health = value
		if health <= 0:
			is_alive = false

func _enter_tree() -> void:
	entity.init(multiplayer, self)
	
func on_authority_change():
	if entity.get_authority(): 
		set_multiplayer_authority(entity.get_authority())
		$CameraController.set_multiplayer_authority(entity.get_authority())
		

func init_player():
	if entity.get_authority() == multiplayer.get_unique_id():
		Game.players._local = self
	entity.setProperty("health", 100)

func _ready():
	animation_tree.connect("animation_finished", _animation_finished)
	if multiplayer.is_server():
		call_deferred("init_player")

func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() != entity.get_authority():
		on_authority_change()
	
	_update_animation_tree()
	if !is_multiplayer_authority():
		return
	
	$HitBox/CollisionShape3D.disabled = !animation_tree.enable_hitbox
	
	if not is_on_floor():
		velocity += get_gravity() * delta * FALL_VELOCITY
	else:
		is_jumping = false

	if Input.is_action_just_pressed("mouse_left"):
		attack()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var target_angle = PI/2 - input_dir.angle()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		player_node.rotation.y = rotate_toward(player_node.rotation.y, target_angle, 20 * delta)
		is_running = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	
	if velocity.x == 0 and velocity.z == 0:
		is_running = false
		
	
	move_and_slide()

func attack():
	if is_multiplayer_authority():
		MultiplayerController.player_attack.rpc()
	
func attack_animation():
	# It also enable collision box
	is_attacking = true
	state_machine.travel("Attack")
	
func _animation_finished(anim_name):
	if anim_name == "Player/Melee_1H_Attack_Slice_Horizontal":
		is_attacking = false

func _update_animation_tree():
	animation_tree["parameters/Player/conditions/is_running"] = is_running && !is_jumping && !is_attacking
	animation_tree["parameters/Player/conditions/is_jumping"] = is_jumping
	animation_tree["parameters/Player/conditions/is_attacking"] = is_attacking

	animation_tree["parameters/Player/conditions/idle"] = !is_running and !is_jumping and !is_attacking
	
func is_local_player() -> bool:
	return multiplayer.get_unique_id() == int(name)
	
func _on_hit_box_body_entered(body: Node3D) -> void:
	if multiplayer.is_server():
		print(body)
