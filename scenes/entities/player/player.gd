extends CharacterBody3D
class_name Player

const SPEED = 6.0
const JUMP_VELOCITY = 6.5
const FALL_VELOCITY = 1.5

@onready var camera: Camera3D = $CameraController/Camera3D
@onready var animation_tree: AnimationTree = $Character/AnimationTree
@onready var state_machine = $Character/AnimationTree.get("parameters/Player/playback")
@onready var player_node: Node3D = $Character
@export var is_jumping: bool = false
@export var is_running: bool = false
@export var is_attacking: bool = false
@export var unique_id: int = -1

var inventory_controller: PackedScene = load("res://scenes/entities/player/inventory_controller/inventory_controller.tscn")
var inventory_manager:InventoryManager


var inventory: InventoryController
var entity: Entity = Entity.new()
var nickname: String = ""
var is_alive: bool = true
var max_health: int = 100


func _enter_tree() -> void:
	entity.entity_ready.connect(init_player)
	entity.init(multiplayer, self)
	
func on_authority_change():
	if entity.get_authority(): 
		set_multiplayer_authority(entity.get_authority())
		$CameraController.set_multiplayer_authority(entity.get_authority())

func init_player():
	inventory_manager = InventoryManager.new(self)
	if entity.get_authority() == multiplayer.get_unique_id():
		
		Game.players._local = self
		inventory = inventory_controller.instantiate()
		inventory.set_player(self)
		inventory.connect_consumable.connect(connect_consumable)
		inventory.drop_item.connect(drop_item)
		inventory.set_multiplayer_authority(multiplayer.get_unique_id())
		inventory_manager.inventory_updated.connect(inventory.inventory_updated)

		add_child(inventory)
	if multiplayer.is_server():
		entity.set_health(max_health)
	

func _ready():
	animation_tree.connect("animation_finished", _animation_finished)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority(): return

	if Input.is_action_just_pressed("inventory"):
		$CameraController.disabled = !$CameraController.disabled
		inventory.inventory.visible = !inventory.inventory.visible
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	
	# The server need to check the hitbox for updating health
	$HitBox/CollisionShape3D.disabled = !animation_tree.enable_hitbox
	
	if get_multiplayer_authority() != entity.get_authority():
		on_authority_change()
	
	_update_animation_tree()
	if !is_multiplayer_authority():
		return
	
	
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
		print("test", body)

func _on_hit_box_area_entered(area: Area3D) -> void:
	var parent = area.get_parent_node_3d()
	parent.entity.take_damage(10)

func loot(item: Item, amount:int=1) -> void:
	if not Game.is_server():
		return
	inventory_manager.add_item(item, amount)
	MultiplayerController.inventory_multiplayer_controller.loot_item.rpc(self.multiplayer.get_unique_id(), item.item_name)
	#if !is_multiplayer_authority(): return false

func connect_consumable(inventory_slot_id:int) -> void:
	if !is_multiplayer_authority(): return
	#consumable.consume_item.connect(func(callable: Callable): callable.call(self))
	MultiplayerController.inventory_multiplayer_controller.on_player_use.rpc(inventory_slot_id)

func drop_item(slot: InventorySlot, quantity: int) -> void:
	if !is_multiplayer_authority(): return
	if not slot.inventory_item:
		return
	
	MultiplayerController.inventory_multiplayer_controller.drop_item.rpc(slot.inventory_item.unique_id)
